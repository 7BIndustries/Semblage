extends WindowDialog

signal preview_signal
signal ok_signal

var ContextHandler = load("res://ContextHandler.gd")

var actions = null
var action_type = "None"
var action_args = {}
var context_handler # Handles the situation where the context Action menu needs to be populated
var original_context = null
var new_context = null

"""
Called to prepare the popup to be viewed by the user, complete with controls
appropriate to the Action(s) that can be taken next.
"""
func activate_popup(mouse_pos, context):
	# Save the incoming context to revert back to it later
	original_context = context

	# Instantiate the context handler which tells us what type of Action we are dealing with
	context_handler = ContextHandler.new()

	# Locate the popup at the mouse position and make it a minimum size to be resized later
	set_position(mouse_pos)

	# Make way for the new controls
	clear_popup(true)

	# Get the controls for the popup based on the context
	var action = context_handler.get_next_action(context)
	populate_context_controls(action)


"""
Builds up the dynamic controls in the popup.
"""
func populate_context_controls(actions):
	# Save the actions so we can change control groups later
	self.actions = actions

	# Add all matching actions to the dropdown
	for action in actions.keys():
		self.get_node("VBoxContainer/ActionOptionButton").add_item(action)

	# Populate the default controls
	_set_up_action_controls(actions, actions.keys()[0])


"""
Used to add the controls for the currently selected action's control groups.
"""
func _set_up_action_controls(actions, selected):
	# If there is a control defined in GDScript use that, otherwise populate from the control_group
	if actions[selected].control != null:
		var cont1 = actions[selected].control
		$VBoxContainer/DynamicContainer.add_child(cont1)


"""
Clears the previous dynamic controls from this popup.
"""
func clear_popup(clear_all):
	# Clear the previous control item(s) from the DynamicContainer
	for child in $VBoxContainer/DynamicContainer.get_children():
		$VBoxContainer/DynamicContainer.remove_child(child)

	# Clear the triggers dropdown, but only if the caller wanted a complete refresh
	if clear_all:
		self.get_node("VBoxContainer/ActionOptionButton").clear()


"""
Makes it possible to get the updated code context after changes have been applied.
"""
func get_new_context():
	return new_context


"""
Finds out which trigger was selected by the user.
"""
func _get_selected_trigger():
	var aob = self.get_node("VBoxContainer/ActionOptionButton")
	return aob.get_item_text(aob.get_selected_id())


"""
Gets the latest addition to the context for this popup panel.
"""
func get_latest_context_addition():
	return self.context_handler.get_latest_context_addition()


"""
Get the latest object addition to the context for this popup panel.
"""
func get_latest_object_addition():
	return self.context_handler.get_latest_object_addition()


"""
Called when the Preview button is pressed so that it can collect the relevant data.
"""
func _on_PreviewButton_button_down():
	var cont = $VBoxContainer/DynamicContainer.get_children()[0]
	new_context = context_handler.update_context_string(original_context, cont.get_completed_template())

	emit_signal("preview_signal")


"""
Called when the Ok button is pressed so that the GUI can collect the changed context.
"""
func _on_OkButton_button_down():
	var cont = $VBoxContainer/DynamicContainer.get_children()[0]
	new_context = context_handler.update_context_string(original_context, cont.get_completed_template())

	emit_signal("ok_signal")
	hide()


"""
Called when the Cancel button is pressed so that this popup can just be closed.
"""
func _on_CancelButton_button_down():
	hide()


"""
Called when the user selects a different trigger from the top option button.
"""
func _on_ActionOptionButton_item_selected(index):
	var trig = _get_selected_trigger()

	# Clear the dynamic action items from the popup
	clear_popup(false)

	# Populate the default controls
	_set_up_action_controls(self.actions, trig)


"""
Called whenever the contents of the main VBoxContainer require a size change.
"""
func _on_VBoxContainer_resized():
	# Make sure the panel is the correct size to contain all controls
	rect_size = Vector2($VBoxContainer.rect_size[0] + 7, $VBoxContainer.rect_size[1] + 7)
