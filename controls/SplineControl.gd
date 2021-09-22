extends VBoxContainer

class_name SplineControl

signal error
signal new_tuple

var template = ".spline(listOfXYTuple={listOfXYTuple},tangents={tangents},periodic={periodic},forConstruction={forConstruction},includeCurrent={includeCurrent},makeWire={makeWire})"

var prev_template = null

const tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,tangents)"
const tangents_edit_rgx = "(?<=tangents\\=)(.*?)(?=\\,periodic)"
const periodic_edit_rgx = "(?<=periodic\\=)(.*?)(?=\\,forConstruction)"
const construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
const current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\\,makeWire)"
const wire_edit_rgx = "(?<=makeWire\\=)(.*?)(?=\\))"

var valid = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add this control to a group so that we can broadcast messages
	add_to_group("new_tuple")

	# Pull the parameters from the action popup panel
	var app = find_parent("ActionPopupPanel")
	var filtered_param_names = app.get_tuple_param_names()
	var filtered_param_names_orig = filtered_param_names

	# If there are no parameters, we insert a blank one at the top to force the user to select "New"
	if filtered_param_names.size() == 0:
		filtered_param_names.append("")

	# Allow the user to create a new tuple list variable
	filtered_param_names.append("New")

	# SPLINE POINTS
	var new_tuple_lbl = Label.new()
	new_tuple_lbl.set_text("Spline Points")
	add_child(new_tuple_lbl)

	# Add the points parameter option button
	var points_param_opt = OptionButton.new()
	points_param_opt.name = "points_param_opt"
	points_param_opt.connect("item_selected", self, "_on_item_selected")
	add_child(points_param_opt)

	# Load up both component option buttons with the names of the found components
	Common.load_option_button(points_param_opt, filtered_param_names)

	# TANGENTS
	var new_tangent_lbl = Label.new()
	new_tangent_lbl.set_text("Tangent Points")
	add_child(new_tangent_lbl)

	# Add the points parameter option button
	var tangents_param_opt = OptionButton.new()
	tangents_param_opt.name = "tangents_param_opt"
	tangents_param_opt.connect("item_selected", self, "_on_tangent_item_selected")
	add_child(tangents_param_opt)

	filtered_param_names_orig.insert(0, "None")

	# Load up both component option buttons with the names of the found components
	Common.load_option_button(tangents_param_opt, filtered_param_names_orig)

	# Make sure that "None" is selected by default
	tangents_param_opt.select(0)

	# PERIODIC
	var periodic_group = HBoxContainer.new()
	var periodic_lbl = Label.new()
	periodic_lbl.set_text("Periodic: ")
	periodic_group.add_child(periodic_lbl)
	var periodic_ctrl = CheckBox.new()
	periodic_ctrl.name = "periodic_ctrl"
	periodic_ctrl.pressed = false
	periodic_ctrl.hint_tooltip = tr("SPLINE_PERIODIC_CTRL_HINT_TOOLTIP")
	periodic_group.add_child(periodic_ctrl)
	add_child(periodic_group)

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

	# MAKE WIRE
	var wire_group = HBoxContainer.new()
	var wire_lbl = Label.new()
	wire_lbl.set_text("Make Wire: ")
	wire_group.add_child(wire_lbl)
	var wire_ctrl = CheckBox.new()
	wire_ctrl.name = "wire_ctrl"
	wire_ctrl.pressed = false
	wire_ctrl.hint_tooltip = tr("ARC_MAKE_WIRE_CTRL_HINT_TOOLTIP")
	wire_group.add_child(wire_ctrl)
	add_child(wire_group)

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
	# Get the option buttons so we can set them
	var points_param_opt = get_node("points_param_opt")
	var tan_param_opt = get_node("tangents_param_opt")

	# Set the first item, which should be blank, to the new parameter name
	if points_param_opt.get_item_text(points_param_opt.selected).empty():
		points_param_opt.set_item_text(0, new_parameter[0])
	elif tan_param_opt.get_item_text(tan_param_opt.selected).empty():
		tan_param_opt.set_item_text(0, new_parameter[0])

	_validate_form()


"""
Called when the user selects an item from the parameter list.
"""
func _on_item_selected(index):
	var opt = get_node("points_param_opt")

	var sel = opt.get_item_text(index)

	# Handle the user wanting to add a new tuple list parameter
	if sel == "":
		return
	elif sel == "New":
		# Switch back to the blank item at the beginning of the option button
		opt.select(0)

		# Fire the event that launches the add parameter dialog set up to do the tuple
		connect("new_tuple", self.find_parent("Control"), "_on_new_tuple")
		emit_signal("new_tuple")


"""
Called when the user selects an item from the tangent parameter list.
"""
func _on_tangent_item_selected(index):
	var opt = get_node("tangents_param_opt")

	var sel = opt.get_item_text(index)

	# Handle the user wanting to add a new tuple list parameter
	if sel == "":
		return
	elif sel == "New":
		# Switch back to the blank item at the beginning of the option button
		opt.select(0)

		# Fire the event that launches the add parameter dialog set up to do the tuple
		connect("new_tuple", self.find_parent("Control"), "_on_new_tuple")
		emit_signal("new_tuple")


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
	if points_opt.get_item_text(points_opt.selected).empty():
		error_btn_group.show()
		error_btn.hint_tooltip = tr("POINTS_LIST_PARAMETER_SELECTION_ERROR")
		valid = false
	else:
		valid = true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var points_param_opt = get_node("points_param_opt")
	var tan_param_opt = get_node("tangents_param_opt")
	var periodic_ctrl = find_node("periodic_ctrl", true, false)
	var construction_ctrl = find_node("construction_ctrl", true, false)
	var current_ctrl = find_node("current_ctrl", true, false)
	var wire_ctrl = find_node("wire_ctrl", true, false)

	# See if the tangent vector list needs to be None
	var tan_param_name = tan_param_opt.get_item_text(tan_param_opt.selected)
	if tan_param_name.empty():
		tan_param_name = "None"

	var complete = template.format({
		"listOfXYTuple": points_param_opt.get_item_text(points_param_opt.selected),
		"tangents": tan_param_name,
		"periodic": periodic_ctrl.pressed,
		"forConstruction": construction_ctrl.pressed,
		"includeCurrent": current_ctrl.pressed,
		"makeWire": wire_ctrl.pressed,
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
	var points_param_opt = get_node("points_param_opt")
	var tan_param_opt = get_node("tangents_param_opt")
	var periodic_ctrl = find_node("periodic_ctrl", true, false)
	var construction_ctrl = find_node("construction_ctrl", true, false)
	var current_ctrl = find_node("current_ctrl", true, false)
	var wire_ctrl = find_node("wire_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Spline points
	rgx.compile(tuple_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Set the spline points parameter
		Common.set_option_btn_by_text(points_param_opt, res.get_string())

	# Tangents
	rgx.compile(tangents_edit_rgx)
	res = rgx.search(text_line)
	if res:
		if res.get_string() != "None":
			Common.set_option_btn_by_text(tan_param_opt, res.get_string())

	# Periodic
	rgx.compile(periodic_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var per = res.get_string()
		periodic_ctrl.pressed = true if per == "True" else false

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

	# Make wire
	rgx.compile(wire_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var wire = res.get_string()
		wire_ctrl.pressed = true if wire == "True" else false
