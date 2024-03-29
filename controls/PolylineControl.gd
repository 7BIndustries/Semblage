extends VBoxContainer

class_name PolylineControl

signal new_tuple

var template = ".polyline(listOfXYTuple={listOfXYTuple},forConstruction={forConstruction},includeCurrent={includeCurrent})"

var prev_template = null

const tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,forConstruction)"
const construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
const current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\\))"

var valid = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add this control to a group so that we can broadcast messages
	add_to_group("new_tuple")

	# Pull the parameters from the action popup panel
	var app = find_parent("ActionPopupPanel")
	var filtered_param_names = app.get_tuple_param_names()

	# The default selection of None, and an item to add a New list parameter
	filtered_param_names.insert(0, "None")
	filtered_param_names.append("New")

	# POINTS
	var new_tuple_lbl = Label.new()
	new_tuple_lbl.set_text("Polyline Points Parameter")
	add_child(new_tuple_lbl)

	# Add the points parameter option button
	var points_param_opt = OptionButton.new()
	points_param_opt.name = "points_param_opt"
	points_param_opt.connect("item_selected", self, "_on_item_selected")
	add_child(points_param_opt)

	# Load up both component option buttons with the names of the found components
	Common.load_option_button(points_param_opt, filtered_param_names)


	# FOR CONSTRUCTION
	var construction_group = HBoxContainer.new()
	var construction_lbl = Label.new()
	construction_lbl.set_text("For Construction: ")
	construction_group.add_child(construction_lbl)
	var construction_ctrl = CheckBox.new()
	construction_ctrl.name = "construction_ctrl"
	construction_ctrl.pressed = false
	construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	construction_group.add_child(construction_ctrl)
	add_child(construction_group)

	# INCLUDE CURRENT
	var current_group = HBoxContainer.new()
	var current_lbl = Label.new()
	current_lbl.set_text("Include Current: ")
	current_group.add_child(current_lbl)
	var current_ctrl = CheckBox.new()
	current_ctrl.name = "current_ctrl"
	current_ctrl.pressed = false
	current_ctrl.hint_tooltip = tr("INCLUDE_CTRL_HINT_TOOLTIP")
	current_group.add_child(current_ctrl)
	add_child(current_group)

	# Create the button that lets the user know that there is an error on the form
	var error_btn_group = HBoxContainer.new()
	error_btn_group.name = "error_btn_group"
	var error_btn = Button.new()
	error_btn.name = "error_btn"
	error_btn.set_text("!")
	error_btn_group.add_child(error_btn)
	error_btn_group.hide()
	add_child(error_btn_group)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	_validate_form()


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Broadcast received by all controls in the new_tuple group.
"""
func new_tuple_added(new_parameter):
	# Get the option button so we can set it
	var opt = get_node("points_param_opt")

	# Set the first item, which should be blank, to the new parameter name
	opt.add_item(new_parameter[0])

	# Make sure the new parameter is selected
	opt.select(opt.get_item_count() - 1)

	_validate_form()


"""
Called when the user selects an item from the parameter list.
"""
func _on_item_selected(index):
	var opt = get_node("points_param_opt")

	var sel = opt.get_item_text(index)

	# Handle the user wanting to add a new tuple list parameter
	if sel == "New":
		# Switch back to the blank item at the beginning of the option button
		opt.select(0)

		# Fire the event that launches the add parameter dialog set up to do the tuple
		var _ret = connect("new_tuple", self.find_parent("Control"), "_on_new_tuple")
		emit_signal("new_tuple")

	_validate_form()


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return valid


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var points_opt = get_node("points_param_opt")
	var error_btn_group = get_node("error_btn_group")
	var error_btn = get_node("error_btn_group/error_btn")

	# Start with the error button hidden
	error_btn_group.hide()

	# A points list parameter must be selected
	if points_opt.get_item_text(points_opt.selected) == "None":
		error_btn_group.show()
		error_btn.hint_tooltip = tr("POINTS_LIST_PARAMETER_SELECTION_ERROR")
		valid = false
	else:
		valid = true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var points_opt = get_node("points_param_opt")
	var construction_ctrl = find_node("construction_ctrl", true, false)
	var current_ctrl = find_node("current_ctrl", true, false)

	var complete = template.format({
		"listOfXYTuple": points_opt.get_item_text(points_opt.selected),
		"forConstruction": construction_ctrl.pressed,
		"includeCurrent": current_ctrl.pressed
		})

	return complete


"""
When in edit mode, returns the previous template string that needs to
be replaced.
"""
func get_previous_template():
	return prev_template


"""
Loads values into the control's sub-controls based on a code string.
"""
func set_values_from_string(text_line):
	var points_opt = get_node("points_param_opt")
	var construction_ctrl = find_node("construction_ctrl", true, false)
	var current_ctrl = find_node("current_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Tuples
	rgx.compile(tuple_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Set the points option button to have the tuple selected
		Common.set_option_btn_by_text(points_opt, res.get_string())

	# For construction
	rgx.compile(construction_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		construction_ctrl.pressed = true if constr == "True" else false

	# Include current
	rgx.compile(current_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cur = res.get_string()
		current_ctrl.pressed = true if cur == "True" else false
