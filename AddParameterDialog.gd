extends WindowDialog

signal add_parameter
signal edit_parameter

var edit_mode = false
var params = []
var old_param_name = null
var old_param_value = null


"""
Called when the user clicks the OK button.
"""
func _on_OKButton_button_down():
	var param_name_txt = $VBoxContainer/ParamNameTextEdit
	var param_value_txt = $VBoxContainer/ParamValueTextEdit
	var status_txt = $VBoxContainer/StatusLabel
	
	# Check to make sure the user changed the default name text
	if param_name_txt.get_text() == "parameter_name" or param_name_txt.get_text() == "":
		status_txt.set_text("Please input a parameter name")
		return

	# Check to make sure the user changed the default value text
	if param_value_txt.get_text() == "parameter_value" or param_value_txt.get_text() == "":
		status_txt.set_text("Please input a parameter value")
		return

	# Check to see if the user is trying to add a duplicate parameter name
	for param in params:
		if not edit_mode and param[0] == param_name_txt.get_text():
			status_txt.set_text("Parameter name already exists.")
			return

	# Check to make sure that the parameter name starts with a character
	var rgx = RegEx.new()
	rgx.compile("^[a-zA-Z][a-zA-Z0-9_]*$")
	if not rgx.search(param_name_txt.get_text()):
		status_txt.set_text("Name must start with a letter and can contain letters, numbers and underscores.")
		return

	# Check to see if the parameter includes a formula
#	if param_value_txt.get_text().find("%") > 0 or\
#	   param_value_txt.get_text().find("/") > 0 or\
#	   param_value_txt.get_text().find("*") > 0 or\
#	   param_value_txt.get_text().find("+") > 0 or\
#	   param_value_txt.get_text().find("-") > 0:
		# Check to make sure any variables 

#	rgx = RegEx.new()
#	rgx.compile("^.*[\\/\\*\\+\\-\\%]*.*$")
#	if rgx.search(param_value_txt.get_text()):
#		print("Uses a formula.")

	# Send the appropriate signal for add vs edit
	if edit_mode:
		# Collect the new parameter and send the signal to add it
		var new_param = [ old_param_name, param_value_txt.get_text() ]
		emit_signal("edit_parameter", new_param)

		# Turn edit mode back off
		edit_mode = false
	else:
		# Collect the new parameter and send the signal to add it
		var new_param = [ param_name_txt.get_text(), param_value_txt.get_text() ]
		emit_signal("add_parameter", new_param)

	# Reset the status text and editable status
	status_txt.set_text("")
	var text_edit = $VBoxContainer/ParamNameTextEdit
	text_edit.editable = true

	self.hide()


"""
Called when the user clicks the Cancel button.
"""
func _on_CancelButton_button_down():
	var status_lbl = $VBoxContainer/StatusLabel
	status_lbl.set_text("")

	var text_edit = $VBoxContainer/ParamNameTextEdit
	text_edit.editable = true

	self.hide()


"""
Used to set any existing parameters so that duplicates can be checked for.
"""
func set_existing_parameters(items):
	params = items


"""
Fills in the controls to allow a parameter name and value
to be edited.
"""
func activate_edit_mode(param_name, param_value):
	# Tell the rest of the logic that we are in edit mode
	edit_mode = true

	var param_name_txt = $VBoxContainer/ParamNameTextEdit
	var param_value_txt = $VBoxContainer/ParamValueTextEdit

	# Disable the name text box since if the user changes it, we cannot find the value to replace
	param_name_txt.editable = false

	# Save the old name and value so we can update the right ones
	old_param_name = param_name
	old_param_value = param_value

	# Clear the status indicator
	var status_lbl = $VBoxContainer/StatusLabel
	status_lbl.set_text("")

	# Fill in the values of the controls
	param_name_txt.set_text(param_name)
	param_value_txt.set_text(param_value)

	self.popup_centered()
