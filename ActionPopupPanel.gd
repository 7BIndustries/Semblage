extends PopupPanel

signal preview_signal

var ContextHandler = load("res://ContextHandler.gd")

var action_type = "None"
var action_args = {}
var context_handler # Handles the situation where the context Action menu needs to be populated
var cur_controls = {} # Keeps handles to all current controls for use 
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
	popup(Rect2(mouse_pos[0], mouse_pos[1], 1.0, 1.0))
	
	# Make way for the new controls
	clear_popup()

	# Get the controls for the popup based on the context
	var action = context_handler.get_next_action(context)
	populate_context_controls(action)

	# Make sure the panel is the correct size to contain all controls
	rect_size = get_node("VBoxContainer").rect_size

"""
Builds up the dynamic controls in the popup.
"""
func populate_context_controls(action):
	# Let the user know what Action is currently selected
	self.get_node("VBoxContainer/ActionLabel").set_text(action.name)

	for group_key in action.control_groups.keys():
		var cur_group = action.control_groups[group_key]

		# Add the label for this control group
		var lbl1 = Label.new()
		lbl1.set_text(cur_group.label)
		get_node("VBoxContainer/PVBoxContainer").add_child(lbl1)
		
		# Add the controls from the group
		var ctrls = cur_group.controls
		var cont1 = HBoxContainer.new()
		for ctrl in ctrls.keys():
			# Add the label for this specific control, if needed
			if ctrls[ctrl].label != "None":
				var lbl2 = Label.new()
				lbl2.set_text(ctrls[ctrl].label)
				cont1.add_child((lbl2))

			# Add the control based on its type
			if ctrls[ctrl].type == "OptionButton":
				var new_ctrl = OptionButton.new()
				new_ctrl.set_name(ctrl)
				
				# Add the values to the OptionButton as items
				for item in ctrls[ctrl].values:
					new_ctrl.add_item(item)

				cont1.add_child(new_ctrl)
			elif ctrls[ctrl].type == "LineEdit":
				var new_ctrl = LineEdit.new()
				new_ctrl.set_name(ctrl)
				new_ctrl.text = ctrls[ctrl].values[0]
				cont1.add_child(new_ctrl)

		get_node("VBoxContainer/PVBoxContainer").add_child(cont1)


"""
Clears the previous dynamic controls from this popup.
"""
func clear_popup():
	# We only want to remove the contents of the dynamic VBoxContainer
	var par = get_node("VBoxContainer/PVBoxContainer")

	# Clear the previous items from the popup
	var children = par.get_children()
	for child in children:
		par.remove_child(child)

	# Clear all controls from the collection
	cur_controls.clear()


"""
Makes it possible to get the updated code context after changes have been applied.
"""
func get_new_context():
	return new_context


"""
Turns the control values for the Action into a dictionary of names and
associated values.
"""
func collect_action_settings():
	action_args = {}

	var child_ctrls = get_node("VBoxContainer/PVBoxContainer").get_children()

	# Collect the names of all the child controls
	for child_ctrl in child_ctrls:
		if child_ctrl.get_name().begins_with("@"):
			for new_child in child_ctrl.get_children():
				if new_child.get_name().begins_with("@"):
					for sub_child in new_child.get_children():
						action_args[sub_child.get_name()] = _get_control_value(sub_child)
				else:
					action_args[new_child.get_name()] = _get_control_value(new_child)
		else:
			action_args[child_ctrl.get_name()] = _get_control_value(child_ctrl)

	return action_args

"""
Figures out what type of control was passed in and attempts to get a value from it.
"""
func _get_control_value(ctrl):
	if ctrl.get_class() == "OptionButton":
		return ctrl.get_item_text(ctrl.get_selected_id())
	elif ctrl.get_class() == "LineEdit":
		return ctrl.get_text()

"""
Called when the Preview button is pressed so that it can collect the relevant data.
"""
func _on_PreviewButton_button_down():
	action_args = collect_action_settings()
	new_context = context_handler.update_context(original_context, action_args)
	emit_signal("preview_signal")
