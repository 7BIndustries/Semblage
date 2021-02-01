extends WindowDialog

signal ok_signal

var ContextHandler = load("res://ContextHandler.gd")

var context_handler # Handles the situation where the context Action menu needs to be populated
var original_context = null
var new_context = null
var new_template = null
var prev_template = null
var edit_mode = false
var action_filter = "3D"
var three_d_actions = null
var two_d_actions = null
var wp_actions = null

# The group buttons at the top of the dialog
var three_d_btn = null
var sketch_btn = null
var wp_btn = null

"""
Called when this control is ready to display.
"""
func _ready():
	# Instantiate the context handler which tells us what type of Action we are dealing with
	context_handler = ContextHandler.new()

	three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton
	sketch_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton
	wp_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton

	# Make sure 3D is selected by default
	three_d_btn.pressed = true


"""
Sets the Action control based on what is selected in the option button.
"""
func _set_action_control():
	var aob = $VBoxContainer/ActionOptionButton

	# Get the currently selected item
	var selected = aob.get_item_text(aob.get_selected_id())

	# Get the action for the name
	var act = context_handler.get_action_for_name(selected)

	# Set the action control
	clear_popup()
	$VBoxContainer/HBoxContainer/DynamicContainer.add_child(act.action.control)


"""
Clears the previous dynamic controls from this popup.
"""
func clear_popup():
	# Clear the previous control item(s) from the DynamicContainer
	for child in $VBoxContainer/HBoxContainer/DynamicContainer.get_children():
		$VBoxContainer/HBoxContainer/DynamicContainer.remove_child(child)


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
Gets script objects (like Workplanes) that will not be displayed.
"""
func get_untessellateds():
	return self.context_handler.get_untessellateds(self.get_new_context())


"""
Sets the ActionPopupPanel up for an edit of a history item.
"""
func activate_edit_mode(component_text, item_text):
	prev_template = item_text

	# Get the control that matches the edit trigger for the history code, if any
	var popup_action = context_handler.find_matching_edit_trigger(item_text)

	# If the returned control is null, there is not need continuing
	if popup_action == null:
		return

	var action_key = item_text.split(".")[1].split("(")[0]

	# Show the popup
	activate_popup(component_text, true)

	# Select the correct group button based on the next action
	_select_group_button(popup_action[action_key].group)

	# Make sure the correct item is selected
	Common.set_option_btn_by_text($VBoxContainer/ActionOptionButton, popup_action[action_key].name)

	_set_action_control()


"""
Attempt to contain popup actions in one place.
"""
func activate_popup(component_text, edit_mode):
	# Save the incoming context to revert back to it later
	original_context = component_text

	# Save edit mode for when the user hits the OK button
	self.edit_mode = edit_mode

	# Setup and show the dialog
	show_modal(true)
	popup_centered()
	_on_VBoxContainer_resized()

	var next_action = null

	# Get the next action based on whether edit mode is engaged
	if edit_mode:
		next_action = context_handler.find_matching_edit_trigger(prev_template)
	else:
		next_action = context_handler.get_next_action(component_text)

	# Select the correct group button based on the next action
	_select_group_button(next_action[next_action.keys()[0]].group)


"""
Selects the correct group button based on an Action's group.
"""
func _select_group_button(group):
	if group == "WP":
		wp_btn.pressed = true
		_on_WorkplaneButton_toggled(wp_btn)
	elif group == "3D":
		three_d_btn.pressed = true
		_on_ThreeDButton_toggled(three_d_btn)
	else:
		sketch_btn.pressed = true
		_on_SketchButton_toggled(sketch_btn)


"""
Called when the Ok button is pressed so that the GUI can collect the changed context.
"""
func _on_OkButton_button_down():
	if edit_mode:
		var cont = $VBoxContainer/HBoxContainer/DynamicContainer.get_children()[0]
		new_template = cont.get_completed_template()

		if not edit_mode:
			# Save the old context when editing to allow replacement in the history tree
			prev_template = cont.get_previous_template()

		# Have the context handler edit the current context
		new_context = context_handler.edit_context_string(original_context, prev_template, new_template)
	else:
		var cont = $VBoxContainer/HBoxContainer/DynamicContainer.get_children()[0]
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
	var trig = $VBoxContainer/ActionOptionButton.get_item_text($VBoxContainer/ActionOptionButton.get_selected_id())

	# Clear the dynamic action items from the popup
	clear_popup()

	# Populate the appropriate action control
	_set_action_control()


"""
Called whenever the contents of the main VBoxContainer require a size change.
"""
func _on_VBoxContainer_resized():
	# Make sure the panel is the correct size to contain all controls
	rect_size = Vector2($VBoxContainer.rect_size[0] + 7, $VBoxContainer.rect_size[1] + 7)


"""
Allows an image to be loaded into the 2D preview.
"""
func load_image(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	$VBoxContainer/HBoxContainer/Preview.set_texture(texture)


"""
Called when the user clicks the 3D button and toggles it.
"""
func _on_ThreeDButton_toggled(button_pressed):
	# Make sure that the other buttons are not toggled
	if three_d_btn.pressed:
		sketch_btn.pressed = false
		wp_btn.pressed = false

		action_filter = "3D"

		# Fill the 3D actions list up the first time it is requested
		if three_d_actions == null:
			three_d_actions = context_handler.get_3d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, three_d_actions)

		_set_action_control()

		# Hide preview controls
		$VBoxContainer/AddButton.hide()
		$VBoxContainer/HBoxContainer/Preview.hide()


"""
Called when the user clicks the Sketch button and toggles it.
"""
func _on_SketchButton_toggled(button_pressed):
	if sketch_btn.pressed:
		# Make sure that the other buttons are not toggled
		three_d_btn.pressed = false
		wp_btn.pressed = false

		action_filter = "2D"

		# Fill the 2D actions list up the first time it is requested
		if two_d_actions == null:
			two_d_actions = context_handler.get_2d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, two_d_actions)

		_set_action_control()

		# Show preview controls
		$VBoxContainer/AddButton.hide()
		$VBoxContainer/HBoxContainer/Preview.show()
#		load_image("/home/jwright/Downloads/sample_2D_render.svg")


"""
Called when the user clicks on the Workplane button and toggles it.
"""
func _on_WorkplaneButton_toggled(button_pressed):
	if wp_btn.pressed:
		# Make sure that the other buttons are not toggled
		three_d_btn.pressed = false
		sketch_btn.pressed = false

		action_filter = "WP"

		# Fill in the workplane action list the first time it is requested
		if wp_actions == null:
			wp_actions = context_handler.get_wp_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, wp_actions)

		_set_action_control()

		# Hide preview controls
		$VBoxContainer/AddButton.hide()
		$VBoxContainer/HBoxContainer/Preview.hide()
