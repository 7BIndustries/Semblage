extends WindowDialog

signal error

signal add_parameter
signal edit_parameter

var edit_mode = false
var params = []
var old_param_name = null
var old_param_value = null


func _ready():
	_reset_tuple_tree()

	# Make sure that the spacer is visible
	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.show()


"""
Resets the tuple tree to its initial condition.
"""
func _reset_tuple_tree():
	# Create the tuple list root item
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")
	tuple_list.clear()
	var root_item = tuple_list.create_item()

	# Add a default entry to the tuple list
	var new_item = tuple_list.create_item(root_item)
	new_item.set_text(0, "0.0")
	new_item.set_text(1, "0.0")
	new_item.set_text(2, "0.0")

	# Make sure the columns are editable
	new_item.set_editable(0, true)
	new_item.set_editable(1, true)
	new_item.set_editable(2, true)


"""
Called when the user clicks the OK button.
"""
func _on_OKButton_button_down():
	var param_name_txt = get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
	var param_value_txt = get_node("MarginContainer/VBoxContainer/ParamValueTextEdit")
	var param_value_num = get_node("MarginContainer/VBoxContainer/NumberEdit")

	# Get the radio buttons to determine the data type
	var string_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/StringCheckBox")
	var num_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/NumCheckBox")
	var tuple_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/TupleListCheckBox")

	# Check to make sure the user changed the default name text
	if param_name_txt.get_text() == "":
		emit_signal("error", "Please input a parameter name")
		return

	# Check to see if the user is trying to add a duplicate parameter name
	for param in params:
		if not edit_mode and param[0] == param_name_txt.get_text():
			emit_signal("error", "Parameter name already exists.")
			return

	# Check to make sure that the parameter name starts with a character
	var rgx = RegEx.new()
	rgx.compile("^[a-zA-Z][a-zA-Z0-9_]*$")
	if not rgx.search(param_name_txt.get_text()):
		emit_signal("error", "Name must start with a letter and can contain letters, numbers and underscores.")
		return

	# Check to make sure the user changed the default value text
	if string_radio.pressed and param_value_txt.get_text() == "":
		emit_signal("error", "Please input a valid parameter value.")
		return

	# Check to see if a valid numeric value has been set
	if num_radio.pressed and not param_value_num.is_valid:
		emit_signal("error", "Please input a valid parameter value.")
		return

	# Get the comment, if any, that is to be attached to the parameter
	var param_comment = get_node("MarginContainer/VBoxContainer/CommentLineEdit")
	param_comment = param_comment.get_text()

	# Determine the data type of the parameter
	var param_data_type = "string"
	var param_value = param_value_txt.get_text()
	if num_radio.pressed:
		param_data_type = "number"
		param_value = param_value_num.get_text()
	elif tuple_radio.pressed:
		param_data_type = "tuple"
		param_value = _get_tuple_list()

	var new_param = []

	# Send the appropriate signal for add vs edit
	if edit_mode:
		# Collect the new parameter and send the signal to add it
		new_param = [ old_param_name, param_value ]
		emit_signal("edit_parameter", new_param, param_data_type, param_comment)

		# Turn edit mode back off
		edit_mode = false
	else:
		# Collect the new parameter and send the signal to add it
		new_param = [ param_name_txt.get_text(), param_value ]
		emit_signal("add_parameter", new_param, param_data_type, param_comment)

	# Broadcast the message that lets any controls know that a tuple has been created
	# The get_tree call is a work-around for the testing framework
	if param_data_type == "tuple" and get_tree() != null:
		get_tree().call_group("new_tuple", "new_tuple_added", new_param)

	# Reset the status text and editable status
	var text_edit = get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
	text_edit.editable = true

	# Reset the edit mode flag in case the next parameter request is a new one
	edit_mode = false

	self.hide()


"""
Called when the user clicks the Cancel button.
"""
func _on_CancelButton_button_down():
	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.set_text("")

	var text_edit = get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
	text_edit.editable = true

	# Reset the edit mode flag in case the next parameter request is a new one
	edit_mode = false

	self.hide()


"""
Walk the tuple table and collect it into the string list.
"""
func _get_tuple_list():
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")
	var cur_item = tuple_list.get_root().get_children()
	var list = "["

	# Search the tree and return only the last item
	while true:
		if cur_item == null:
			break
		else:
			if cur_item.get_text(0) == "":
				break

			list += "(" + cur_item.get_text(0) + "," + cur_item.get_text(1) + "," + cur_item.get_text(2) + "),"

			cur_item = cur_item.get_next()

	list += "]"

	return list


"""
Used to set any existing parameters so that duplicates can be checked for.
"""
func set_existing_parameters(items):
	params = items


"""
Fills in the controls to allow a parameter name and value
to be edited.
"""
func activate_edit_mode(param_name, param_value, data_type, comment):
	# Tell the rest of the logic that we are in edit mode
	edit_mode = true

	var string_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/StringCheckBox")
	var num_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/NumCheckBox")
	var tuple_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/TupleListCheckBox")

	var param_name_txt = get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
	var param_value_txt = get_node("MarginContainer/VBoxContainer/ParamValueTextEdit")
	var param_num_txt = get_node("MarginContainer/VBoxContainer/NumberEdit")
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")

	# Reset the controls to the default
	param_name_txt.set_text("parameter_name")
	param_value_txt.set_text("parameter_value")
	param_num_txt.set_text("0.0")
	_reset_tuple_tree()

	# Set the selected data type
	if data_type == "string":
		string_radio.emit_signal("button_down")
	elif data_type == "number":
		num_radio.emit_signal("button_down")
	elif data_type == "tuple":
		tuple_radio.emit_signal("button_down")

	# Set the comment field to what it was before
	var comment_txt = get_node("MarginContainer/VBoxContainer/CommentLineEdit")
	comment_txt.set_text(comment)

	# Disable the name text box since if the user changes it, we cannot find the value to replace
	param_name_txt.editable = false

	# Save the old name and value so we can update the right ones
	old_param_name = param_name
	old_param_value = param_value

	# Clear the status indicator
	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.set_text("")

	# Fill in the values of the controls
	param_name_txt.set_text(param_name)

	# Set the value in the appropriate control based on the datatype
	if data_type == "string":
		param_value_txt.set_text(param_value)
	elif data_type == "number":
		param_num_txt.set_text(param_value)
	elif data_type == "tuple":
		# Clear the tuple list tree to re-populate it
		tuple_list.clear()
		tuple_list.create_item()

		# Populate the tuple list with the items from the parameter declaration
		_populate_tuple_list(param_value)

	self.popup_centered()


"""
Parses the string tuple list back into something that can
be added to the tuple list.
"""
func _populate_tuple_list(tuple_list_str):
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")

	# Break the square brackets from the tuple list
	var list = tuple_list_str.split("[")[1].split("]")[0]

	# Add all of the vectors in turn
	var list_parts = list.split("),")

	for list_part in list_parts:
		if list_part.empty():
			break

		# Get rid of the leading tuple character
		list_part = list_part.replace("(", "")

		# Extract the X, Y and Z parts out of the current tuple
		var xyz = list_part.split(",")

		# Add the current set of X, Y and Z points
		var item = tuple_list.create_item(tuple_list.get_root())
		item.set_text(0, xyz[0])
		item.set_text(1, xyz[1])
		item.set_text(2, xyz[2])

		# Make sure the columns are editable
		item.set_editable(0, true)
		item.set_editable(1, true)
		item.set_editable(2, true)


"""
Called when the user clicks the String parameter type radio button.
"""
func _on_StringCheckBox_button_down():
	# Hide all other controls
	_unset_all_input_controls()

	# String parameter type radio button
	var str_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/StringCheckBox")
	str_radio_btn.pressed = true

	# Show only the string control
	var param_value_txt = get_node("MarginContainer/VBoxContainer/ParamValueTextEdit")
	param_value_txt.show()

	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.show()


"""
Called when the user clicks the Number parameter type radio button.
"""
func _on_NumCheckBox_button_down():
	# Hide all other controls
	_unset_all_input_controls()

	# Number parameter type radio button
	var num_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/NumCheckBox")
	num_radio_btn.pressed = true

	var param_value_num = get_node("MarginContainer/VBoxContainer/NumberEdit")
	param_value_num.show()

	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.show()


"""
Called when the user clicks the Tuple List parameter type radio button.
"""
func _on_TupleListCheckBox_button_down():
	# Hide all other controls
	_unset_all_input_controls()

	# Tuple list parameter type radio button
	var tuple_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/TupleListCheckBox")
	tuple_radio_btn.pressed = true

	# Show the tuple list control
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")
	tuple_list.show()

	# Hide the status label spacer control
	var status_lbl = get_node("MarginContainer/VBoxContainer/StatusLabel")
	status_lbl.hide()


"""
Allows all parameter input controls to be hidden so that only the needed one can be shown.
"""
func _unset_all_input_controls():
	# String parameter type radio button
	var str_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/StringCheckBox")
	str_radio_btn.pressed = false

	# Number parameter type radio button
	var num_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/NumCheckBox")
	num_radio_btn.pressed = false

	# Tuple list parameter type radio button
	var tuple_radio_btn = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/TupleListCheckBox")
	tuple_radio_btn.pressed = false

	# Hide the string field
	var param_value_txt = get_node("MarginContainer/VBoxContainer/ParamValueTextEdit")
	param_value_txt.hide()

	# Hide the number field
	var param_value_num = get_node("MarginContainer/VBoxContainer/NumberEdit")
	param_value_num.hide()

	# Hide the tuple list table
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")
	tuple_list.hide()


"""
Called when the user right clicks on the tuple list.
"""
func _on_TupleList_activate_data_popup():
	var tl = get_node("MarginContainer/VBoxContainer/TupleList")
	var global_pos = tl.get_global_mouse_position()
	var vb = get_node("TuplePopupPanel/TupleVBox")

	var popup_height = 75

	# Clear any previous items
	_clear_tuple_popup()

	# Toggle the visiblity of the popup
	var tuple_popup = $TuplePopupPanel
	if tuple_popup.visible:
		tuple_popup.hide()
	else:
		tuple_popup.rect_position = Vector2(global_pos.x, global_pos.y)
		tuple_popup.rect_size = Vector2(100, popup_height)
		tuple_popup.show()

	# Add the Add button
	var add_item = Button.new()
	add_item.set_text("Add")
	add_item.connect("button_down", self, "_add_tuple_point")
	vb.add_child(add_item)

	# Add the Remove button
	var remove_item = Button.new()
	remove_item.set_text("Remove")
	remove_item.connect("button_down", self, "_remove_tuple_point")
	vb.add_child(remove_item)

	# Add the Cancel item
	var cancel_item = Button.new()
	cancel_item.set_text("Cancel")
	cancel_item.connect("button_down", self, "_cancel_tuple_popup")
	vb.add_child(cancel_item)


"""
Clear the previous items from the data popup.
"""
func _clear_tuple_popup():
	var vb = get_node("TuplePopupPanel/TupleVBox")

	# Clear the previous control item(s) from the DynamicContainer
	for child in vb.get_children():
		vb.remove_child(child)

"""
Allows the user to add a list item to the table.
"""
func _add_tuple_point():
	var tpp = get_node("TuplePopupPanel")
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")

	var last_item = tuple_list.get_selected()

	# If the last item is blank, just fill it in and do not create a new line
	if last_item != null and last_item.get_text(0).empty():
		last_item.set_text(0, "0.0")
		last_item.set_text(1, "0.0")
		last_item.set_text(2, "0.0")
	else:
		var new_item = tuple_list.create_item(tuple_list.get_root())

		# Set the current row to be all 0.0
		new_item.set_text(0, "0.0")
		new_item.set_text(1, "0.0")
		new_item.set_text(2, "0.0")

		# Make sure the fields are edited
		new_item.set_editable(0, true)
		new_item.set_editable(1, true)
		new_item.set_editable(2, true)

	# Hide the popup panel
	tpp.hide()


"""
Removes a tuple point from the list.
"""
func _remove_tuple_point():
	var tpp = get_node("TuplePopupPanel")
	var tuple_list = get_node("MarginContainer/VBoxContainer/TupleList")

	var sel = tuple_list.get_selected()

	# Remove the selected item from the tree
	tuple_list.get_root().remove_child(sel)
	sel.free()

	# Work-around to force the tree to updated visually
	tuple_list.hide()
	tuple_list.show()

	# Hide the popup panel
	tpp.hide()


"""
Close the popup without doing anything.
"""
func _cancel_tuple_popup():
	var tuple_popup = get_node("TuplePopupPanel")
	tuple_popup.hide()


"""
Called when this dialog is about to pop up.
"""
func _on_AddParameterDialog_about_to_show():
	# Only reset the controls if we are not working with edit mode
	if not edit_mode:
		var param_name_txt = get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
		var param_value_txt = get_node("MarginContainer/VBoxContainer/ParamValueTextEdit")
		var param_value_num = get_node("MarginContainer/VBoxContainer/NumberEdit")

		# Get the radio buttons to determine the data type
		var string_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/StringCheckBox")
		var num_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/NumCheckBox")
		var tuple_radio = get_node("MarginContainer/VBoxContainer/ParamTypeContainer/TupleListCheckBox")

		# The parameter comment text field
		var comment_txt = get_node("MarginContainer/VBoxContainer/CommentLineEdit")

		# Set the default values of the controls
		param_name_txt.set_text('parameter_name')
		param_value_txt.set_text('parameter_value')
		param_value_num.set_text('0.0')
		string_radio.pressed = true
		num_radio.pressed = false
		tuple_radio.pressed = false
		_on_StringCheckBox_button_down()
		comment_txt.set_text('')
		_clear_tuple_popup()

		# Clear the tuple list
		_reset_tuple_tree()
