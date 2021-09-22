extends VBoxContainer

class_name PushPointsControl

signal new_tuple

var prev_template = null

var template = ".pushPoints({point_list})"

const point_list_edit_rgx = "(?<=.pushPoints\\()(.*?)(?=\\))"

var valid = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add this control to a group so that we can broadcast messages
	add_to_group("new_tuple")

	# Pull the parameters from the action popup panel
	var app = find_parent("ActionPopupPanel")
	var filtered_param_names = app.get_tuple_param_names()

	# If there are no parameters, we insert a blank one at the top to force the user to select "New"
	if filtered_param_names.size() == 0:
		filtered_param_names.append("")

	# Allow the user to create a new tuple list variable
	filtered_param_names.append("New")

	# Add the option button to display the list of available tuple list parameters
	var param_group = VBoxContainer.new()
	var param_lbl = Label.new()
	param_lbl.set_text("Point List Parameter")
	param_group.name = "param_group"
	param_group.add_child(param_lbl)
	var param_opt = OptionButton.new()
	param_opt.name = "param_opt"
	param_opt.connect("item_selected", self, "_on_item_selected")
	param_group.add_child(param_opt)
	add_child(param_group)

	# Load up both component option buttons with the names of the found components
	Common.load_option_button(param_opt, filtered_param_names)

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
Broadcast received by all controls in the new_tuple group.
"""
func new_tuple_added(new_parameter):
	# Get the option button so we can set it
	var opt = get_node("param_group/param_opt")

	# Set the first item, which should be blank, to the new parameter name
	opt.set_item_text(0, new_parameter[0])

	_validate_form()


"""
Called when the user selects an item from the parameter list.
"""
func _on_item_selected(index):
	var opt = get_node("param_group/param_opt")

	var sel = opt.get_item_text(index)

	# Handle the user wanting to add a new tuple list parameter
	if sel == "":
		return
	elif sel == "New":
		# Switch back to the blank item at the beginning of the option button
		opt.select(0)

		# Fire the event that launches the add parameter dialog set up to do the tuple
		var _success = connect("new_tuple", self.find_parent("Control"), "_on_new_tuple")
		emit_signal("new_tuple")


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return valid


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var points_opt = get_node("param_group/param_opt")
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
	var opt = get_node("param_group/param_opt")

	var points = opt.get_item_text(opt.selected)

	var complete = template.format({
		"point_list": points
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
	var opt = get_node("param_group/param_opt")

	# Point list
	var rgx = RegEx.new()
	rgx.compile(point_list_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Extract the points
		var points = res.get_string()
		Common.set_option_btn_by_text(opt, points)
