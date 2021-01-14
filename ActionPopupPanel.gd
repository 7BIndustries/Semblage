extends WindowDialog

signal preview_signal
signal ok_signal

var ContextHandler = load("res://ContextHandler.gd")

var actions = null
var context_handler # Handles the situation where the context Action menu needs to be populated
var original_context = null
var new_context = null
var new_template = null
var prev_template = null
var edit_mode = false
var action_filter = "All"


"""
Called when this control is ready to display.
"""
func _ready():
	# Instantiate the context handler which tells us what type of Action we are dealing with
	context_handler = ContextHandler.new()


"""
Called to prepare the popup to be viewed by the user, complete with controls
appropriate to the Action(s) that can be taken next.
"""
func activate_popup(mouse_pos, context, action, action_filter):
	self.action_filter = action_filter

	# Save the incoming context to revert back to it later
	original_context = context

	# Locate the popup at the mouse position and make it a minimum size to be resized later
	set_position(mouse_pos)

	# Make way for the new controls
	clear_popup(true)

	# If an action was not supplied, find one from the context
	if action == null:
		action = context_handler.get_next_action(context)
		
		# Track whether or not we should add to the context or update it
		edit_mode = false
	else:
		# Track whether or not we should add to the context or update it
		edit_mode = true

	# Get the controls for the popup based on the context
	populate_context_controls(action)


"""
Allows Action items to be filtered based on what group is picked.
"""
func refresh_actions(context, action_filter):
	self.action_filter = action_filter

	# Make way for the new controls
	clear_popup(true)

	# Populate the new controls given the context
	var action = context_handler.get_next_action(context)
	populate_context_controls(action)


"""
Builds up the dynamic controls in the popup.
"""
func populate_context_controls(actions):
	# Save the actions so we can change control groups later
	self.actions = actions

	# Track the first action that we found that matches the group
	var first_action = null

	# Add all matching actions to the dropdown
	for action in actions.keys():
		var filter = actions[action].group

		if filter == "All" or self.action_filter == "All" or filter == self.action_filter:
			# See if we need to save this as the first action
			if first_action == null:
				first_action = action

			self.get_node("VBoxContainer/ActionOptionButton").add_item(action)

	# Populate the default controls
	if first_action == null:
		first_action = actions.keys()[0]
	_set_up_action_controls(actions, first_action)


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
Makes it possible to get the previous context addition so that it can be edited.
"""
func get_prev_template():
	return prev_template


"""
During an edit, returns the newly updated template.
"""
func get_new_template():
	return new_template

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
Get the previous object addition tot he context for this popup panel.
"""
func get_prev_object_addition():
	return self.context_handler.get_prev_object_addition()

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
	if edit_mode:
		var cont = $VBoxContainer/DynamicContainer.get_children()[0]
		new_template = cont.get_completed_template()
		
		# Save the old context when editing to allow replacement in the history tree
		prev_template = cont.get_previous_template()

		# Have the context handler edit the current context
		new_context = context_handler.edit_context_string(original_context, prev_template, new_template)
	else:
		var cont = $VBoxContainer/DynamicContainer.get_children()[0]
		new_context = context_handler.update_context_string(original_context, cont.get_completed_template())

	emit_signal("ok_signal", edit_mode)
	hide()


"""
Allows the main GUI to essentially replay the context additions from a loaded file.
"""
func update_context_string(incoming_context, context_addition):
	original_context = incoming_context
	new_context = context_handler.update_context_string(original_context, context_addition)

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
