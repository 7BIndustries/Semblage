extends WindowDialog

signal ok_signal

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

var action_tree = null
var action_tree_root = null


"""
Called when this control is ready to display.
"""
func _ready():
	three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton
	sketch_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton
	wp_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton

	# Make sure 3D is selected by default
	three_d_btn.pressed = true

	action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	# Create the root of the object tree
	action_tree_root = action_tree.create_item()
	action_tree_root.set_text(0, "Actions")


"""
Sets the Action control based on what is selected in the option button.
"""
func _set_action_control():
	var aob = $VBoxContainer/ActionOptionButton

	# Get the currently selected item
	var selected = aob.get_item_text(aob.get_selected_id())

	# Get the action for the name
	var act = ContextHandler.get_action_for_name(selected)

	# Set the action control
	_clear_popup()
	$VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.add_child(act.action.control)


"""
Clears the previous dynamic controls from this popup.
"""
func _clear_popup():
	# Clear the previous control item(s) from the DynamicContainer
	for child in $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children():
		$VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.remove_child(child)


"""
Finds out which trigger was selected by the user.
"""
func _get_selected_trigger():
	var aob = self.get_node("VBoxContainer/ActionOptionButton")
	return aob.get_item_text(aob.get_selected_id())


"""
Sets the ActionPopupPanel up for an edit of a history item.
"""
func activate_edit_mode(component_text, item_text):
	prev_template = item_text

	# Get the control that matches the edit trigger for the history code, if any
	var popup_action = ContextHandler.find_matching_edit_trigger(item_text)

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

	# Check to see if there are multiple actions in the item_text
	# and fill the actions tree with them
	var parts = item_text.split(").")
	if parts.size() > 1 and item_text.begins_with(".Workplane(") == false:
		# Walk through all the actions
		var i = 0
		for part in parts:
			# If we are past the first action, prepend the period
			if i > 0:
				part = "." + part

			# If not at the last action, append the closing parenthesis
			if i < parts.size() - 1:
				part += ")"

			# Add the current Action string back to the Action tree
			Common.add_item_to_tree(part, action_tree, action_tree_root)

			i += 1

		_render_action_tree()

	# Set the values of the control being edited
	$VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0].set_values_from_string(item_text)


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

	# Make sure the Update button is hidden
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer.hide()

	var next_action = null

	# Get the next action based on whether edit mode is engaged
	if edit_mode:
		next_action = ContextHandler.find_matching_edit_trigger(prev_template)
	else:
		next_action = ContextHandler.get_next_action(component_text)

	# Select the correct group button based on the next action
	_select_group_button(next_action[next_action.keys()[0]].group)

	# Clear any left-over actions from the action tree
	if self.action_tree != null:
		self.action_tree.clear()

		# Create the root of the object tree
		action_tree_root = action_tree.create_item()
		action_tree_root.set_text(0, "Actions")

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
	# Get the completed template from the current control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	new_template = cont.get_completed_template()

	# Used if the user added multiple actions to the actions tree
	var cur_item = action_tree_root.get_children()
	if cur_item != null:
		new_template = _update_multiple_actions(cur_item)

	# Edit mode
	if edit_mode:
		new_context = ContextHandler.edit_context_string(original_context, prev_template, new_template)
	# New mode
	else:
		new_context = ContextHandler.update_context_string(original_context, new_template)

	emit_signal("ok_signal", edit_mode, new_template, new_context)
	hide()


"""
Pull multiple items from the action tree to update the context string.
"""
func _update_multiple_actions(tree_children):
	var updated_context = ""
	while true:
		if tree_children == null:
			break
		else:
			updated_context += tree_children.get_text(0)

			tree_children = tree_children.get_next()

	return updated_context


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
	_clear_popup()

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
func _load_image(path, globalize):
	var texture = ImageTexture.new()
	var image = Image.new()

	# Static images will not be exported correctly unless the path is globalized
	if globalize:
		image.load(ProjectSettings.globalize_path(path))
	else:
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
			three_d_actions = ContextHandler.get_3d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, three_d_actions)

		_set_action_control()

		# Hide preview controls
		$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.hide()
		$VBoxContainer/HBoxContainer/ActionContainer/ActionTree.hide()
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
			two_d_actions = ContextHandler.get_2d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, two_d_actions)

		_set_action_control()

		# Show preview controls
		$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.show()
		$VBoxContainer/HBoxContainer/ActionContainer/ActionTree.show()
		$VBoxContainer/HBoxContainer/Preview.show()
		_load_image("res://assets/samples/sample_2D_render.svg", true)


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
			wp_actions = ContextHandler.get_wp_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, wp_actions)

		_set_action_control()

		# Hide preview controls
		$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.hide()
		$VBoxContainer/HBoxContainer/ActionContainer/ActionTree.hide()
		$VBoxContainer/HBoxContainer/Preview.hide()


"""
Called when the Add button is clicked.
"""
func _on_AddButton_button_down():
	# Get the template from the active control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	var preview_context = cont.get_completed_template()

	# Add the item to the action tree
	Common.add_item_to_tree(preview_context, $VBoxContainer/HBoxContainer/ActionContainer/ActionTree, action_tree_root)

	_render_action_tree()


"""
Collects all of the completed templates in the Action tree and
renders them as an SVG image.
"""
func _render_action_tree():
	# Start to build the preview string based on what is in the actions list
	var script_text = "import cadquery as cq\nresult=cq.Workplane()"

	# Search the tree and update the matchine entry in the tree
	var cur_item = action_tree_root.get_children()
	while true:
		if cur_item == null:
			break
		else:
			script_text += cur_item.get_text(0)

			cur_item = cur_item.get_next()

	script_text += ".consolidateWires()\nshow_object(result)"

	# The currently rendered component should be here
	var temp_path = OS.get_user_data_dir() + "/temp_component_svg.py"
	FileSystem.save_component(temp_path, script_text)

	# The temporary SVG file path
	var svg_path = OS.get_user_data_dir() + "/temp_component_svg.svg"

	# Set up our command line parameters
	var cur_error_file = OS.get_user_data_dir() + "/error_svg.txt"
	var array = ["--codec", "svg", "--infile", temp_path, "--outfile", svg_path, "--errfile", cur_error_file, "--outputopts", "width:400;height:400;marginLeft:50;marginTop:50;showAxes:False;projectionDir:(0,0,1);strokeWidth:0.5;strokeColor:(255,255,255);hiddenColor:(0,0,255);showHidden:False;"]
	var args = PoolStringArray(array)

	# Execute the render script
	var success = OS.execute(Settings.get_cq_cli_path(), args, true)

	# Track whether or not execution happened successfully
	if success == -1:
		# Let the user know there was an SVG export error
		$ErrorDialog.dialog_text = "There was an error exporting the SVG"
		$ErrorDialog.popup_centered()
	else:
		_load_image(svg_path, false)


"""
Allows action items to be edited by selecting the correct control.
"""
func _on_ActionTree_item_activated():
	# Get the action name so that we can set the action option correctly
	var item_text = action_tree.get_selected().get_text(0)
	var action_key = item_text.split(".")[1].split("(")[0]

	# Make sure the correct item is selected
	Common.set_option_btn_by_text($VBoxContainer/ActionOptionButton, action_key)

	_set_action_control()


"""
Updates the selected action tree item with new settings.
"""
func _on_UpdateButton_button_down():
	var orig_text = action_tree.get_selected().get_text(0)

	# Get the template from the active control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	var new_text = cont.get_completed_template()

	# Update the old action template to reflect the new settings
	Common.update_tree_item(action_tree, orig_text, new_text)

	# Re-render everything in the action tree
	_render_action_tree()


"""
Called when an item is selected in the Action tree.
"""
func _on_ActionTree_item_selected():
	# Unhide the item editing controls so the user can change the selected tree item
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer.show()


"""
Called when nothing is selected in the action tree.
"""
func _on_ActionTree_nothing_selected():
	# Hide the item editing controls so that the user can no longer change the selected tree item
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer.hide()


"""
Called when the user clicks the delete tree item button.
"""
func _on_DeleteButton_button_down():
	var selected = action_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Remove the item from the history tree
	selected.free()

	# Make sure there is something left to render
	if action_tree_root.get_children() == null:
		_load_image("res://assets/samples/sample_2D_render.svg", true)
	else:
		self._render_action_tree()


"""
Called when the move action item up button is pressed.
"""
func _on_MoveUpButton_button_down():
	var selected = action_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Move the item up in the action tree one position
	Common.move_tree_item_up(action_tree, selected)


"""
Called when the move action item down button is pressed.
"""
func _on_MoveDownButton_button_down():
	var selected = action_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Move the item up in the action tree one position
	Common.move_tree_item_down(action_tree, selected)
