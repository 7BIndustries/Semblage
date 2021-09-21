extends VBoxContainer

class_name PushPointsControl

signal error
signal new_tuple

var prev_template = null

var template = ".pushPoints({point_list})"

const point_list_edit_rgx = "(?<=.pushPoints\\()(.*?)(?=\\))"

var filtered_param_names = []
var filtered_params = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add this control to a group so that we can broadcast messages
	add_to_group("new_tuple")

	# Pull the parameters from the action popup panel
	var param_names = find_parent("ActionPopupPanel")
	param_names = param_names.parameters

	# Filter the paramters down to only tuple lists
	var filtered_params = {}
	for param_name in param_names.keys():
		# The parameter is a tuple list
		if param_names[param_name].begins_with("["):
			filtered_params[param_name] = param_names[param_name]
			filtered_param_names.append(param_name)

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

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())


"""
Broadcast received by all controls in the new_tuple group.
"""
func new_tuple_added(new_parameter):
	# Get the option button so we can set it
	var opt = get_node("param_group/param_opt")

	# Set the first item, which should be blank, to the new parameter name
	opt.set_item_text(0, new_parameter[0])

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
		connect("new_tuple", self.find_parent("Control"), "_on_new_tuple")
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
	return true


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


"""
Adds the current values of the left-to-right and top-to-bottom fields as points.
"""
func _add_current_point_to_list():
	var point_list_ctrl = find_node("point_list_ctrl", true, false)
	var point_lr_ctrl = find_node("point_lr_ctrl", true, false)
	var point_tb_ctrl = find_node("point_tb_ctrl", true, false)

	if not is_valid():
		var res = connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		if res != 0:
			print("Error connecting a signal: " + str(res))
		else:
			emit_signal("error", "There is invalid tuple data in the form.")

		return

	point_list_ctrl.add_item(point_lr_ctrl.get_text() + "," + point_tb_ctrl.get_text())


"""
Allows the user to edit the currently selected point.
"""
func _edit_current_point():
	var point_list_ctrl = find_node("point_list_ctrl", true, false)
	var point_lr_ctrl = find_node("point_lr_ctrl", true, false)
	var point_tb_ctrl = find_node("point_tb_ctrl", true, false)

	if not is_valid():
		var res = connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		if res != 0:
			print("Error connecting a signal: " + str(res))
		else:
			emit_signal("error", "There is invalid tuple data in the form.")

		return

	# Item to edit
	var selected_id = point_list_ctrl.get_selected_items()[0]

	# Replacement text
	var item_text = point_lr_ctrl.get_text() + "," + point_tb_ctrl.get_text()

	point_list_ctrl.set_item_text(selected_id, item_text)


"""
Allows the user to delete the currently selected point.
"""
func _delete_current_point():
	var point_list_ctrl = find_node("point_list_ctrl", true, false)

	# Item to delete
	var selected_id = point_list_ctrl.get_selected_items()[0]
	point_list_ctrl.remove_item(selected_id)


"""
Fills in the point controls from an item that is selected in the list
"""
func _populate_point_controls_from_list(id):
	var point_list_ctrl = find_node("point_list_ctrl", true, false)
	var point_lr_ctrl = find_node("point_lr_ctrl", true, false)
	var point_tb_ctrl = find_node("point_tb_ctrl", true, false)

	# Extract the points from the selected item
	var points = point_list_ctrl.get_item_text(id).split(",")

	# Set the point input controls
	point_lr_ctrl.set_text(points[0])
	point_tb_ctrl.set_text(points[1])
