extends WindowDialog

signal ok_signal
signal cancel
signal error

var components = []
var new_context = null
var new_template = null
var prev_template = null
var edit_mode = false
var action_filter = "3D"
var three_d_actions = null
var two_d_actions = null
var wp_actions = null
var selector_actions = null


"""
Called when this control is ready to display.
"""
func _ready():
	var three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton

	# Make sure 3D is selected by default
	three_d_btn.pressed = true

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	# Add the tooltips to the group buttons
	$VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton.hint_tooltip = tr("WORKPLANE_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton.hint_tooltip = tr("THREE_D_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton.hint_tooltip = tr("SKETCH_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SelectorButton.hint_tooltip = tr("SELECTOR_BUTTON_HINT_TOOLTIP")

	# Add a tooltip to the modify operation buttons
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.hint_tooltip = tr("ADD_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer/UpdateButton.hint_tooltip = tr("UPDATE_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer/DeleteButton.hint_tooltip = tr("DELETE_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer/MoveUpButton.hint_tooltip = tr("MOVE_UP_BUTTON_HINT_TOOLTIP")
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer/MoveDownButton.hint_tooltip = tr("MOVE_DOWN_BUTTON_HINT_TOOLTIP")

	# Create the root of the object tree
	var action_tree_root = action_tree.create_item()
	action_tree_root.set_text(0, "Actions")

	# The sketch control does not need to be taking up space by default
	$VBoxContainer/HBoxContainer/CanvasMarginContainer.hide()

	# Work-around to make sure we unlock the mouse controls for the 3D view again
	var btn = self.get_close_button()
	btn.visible = false


"""
Sets the Action control based on what is selected in the option button.
"""
func _set_action_control():
	var aob = $VBoxContainer/ActionOptionButton

	# Make sure to free the previous control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()
	if cont.size() > 0:
		var cont_current = cont[0]
		if cont_current != null:
			cont_current.free()

	# Get the currently selected item
	var selected = aob.get_item_text(aob.get_selected_id())

	# Get the action for the name
	var act = ContextHandler.get_action_for_name(selected)

	# Set the action control
	_clear_popup()
	$VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.add_child(load(act.action.control).new())


"""
Clears the previous dynamic controls from this popup.
"""
func _clear_popup():
	# Clear the previous control item(s) from the DynamicContainer
	for child in $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children():
		$VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.remove_child(child)
		child.free()


"""
Finds out which trigger was selected by the user.
"""
func _get_selected_trigger():
	var aob = self.get_node("VBoxContainer/ActionOptionButton")
	return aob.get_item_text(aob.get_selected_id())


"""
Sets the ActionPopupPanel up for an edit of a history item.
"""
func activate_edit_mode(component_text, item_text, components):
	prev_template = item_text
	self.components = components

	# Get the control that matches the edit trigger for the history code, if any
	var popup_action = ContextHandler.find_matching_edit_trigger(item_text)

	# If the returned control is null, there is not need continuing
	if popup_action == null:
		return

	# Show the popup
	activate_popup(component_text, true, components)

	# Select the correct group button based on the next action
	_select_group_button(popup_action.values()[0].group)

	# Make sure the correct item is selected
	Common.set_option_btn_by_text($VBoxContainer/ActionOptionButton, popup_action.values()[0].name)

	_set_action_control()

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	# Check to see if there are multiple actions in the item_text
	# and fill the actions tree with them
	var parts = item_text.split(").")

	# See if this is a binary (i.e. boolean) item
	var is_binary = ContextHandler.is_binary(item_text)

	# Fille the 2D history tree, if needed
	if parts.size() > 1 and not is_binary and \
			item_text.begins_with(".Workplane(") == false and \
			item_text.begins_with(".workplane(") == false and \
			item_text.begins_with(".faces(") == false and \
			item_text.begins_with(".edges(") == false and \
			item_text.begins_with(".vertices(") == false:
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
func activate_popup(component_text, edit_mode_new, components):
	# Save the incoming components for binary operations and duplicate checks
	self.components = components

	# Save edit mode for when the user hits the OK button
	self.edit_mode = edit_mode_new

	# Setup and show the dialog
	show_modal(true)
	popup_centered()
	_on_VBoxContainer_resized()

	# Make sure the Update button is hidden
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer.hide()

	var next_action = null

	# Get the next action based on whether edit mode is engaged
	if self.edit_mode:
		next_action = ContextHandler.find_matching_edit_trigger(prev_template)
	else:
		next_action = ContextHandler.get_next_action(component_text)

	# If we did not get a matching action, the user might be doing something like defining parameters
	if next_action.empty():
		next_action["Workplane"] = Triggers.get_triggers()["Workplane"].action

	# Select the correct group button based on the next action
	_select_group_button(next_action[next_action.keys()[0]].group)

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	# Clear any left-over actions from the action tree
	if action_tree != null:
		action_tree.clear()

		# Create the root of the object tree
		action_tree_root = action_tree.create_item()
		action_tree_root.set_text(0, "Actions")

"""
Selects the correct group button based on an Action's group.
"""
func _select_group_button(group):
	var wp_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton
	var three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton
	var sketch_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton
	var selector_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SelectorButton

	if group == "WP":
		wp_btn.pressed = true
		_on_WorkplaneButton_toggled(wp_btn)
	elif group == "3D":
		three_d_btn.pressed = true
		_on_ThreeDButton_toggled(three_d_btn)
	elif group == "SELECTORS":
		selector_btn.pressed = true
	else:
		sketch_btn.pressed = true
		_on_SketchButton_toggled(sketch_btn)

	_on_VBoxContainer_resized()


"""
Called when the Ok button is pressed so that the GUI can collect the changed context.
"""
func _on_OkButton_button_down():
	# Current control loaded
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]

	# Make sure the form is valid
	if not cont.is_valid():
		emit_signal("error", "There are errors on the form, please correct them.")

		return

	# Get the completed template from the current control
	new_template = cont.get_completed_template()

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	# Used if the user added multiple actions to the actions tree
	var cur_item = action_tree_root.get_children()
	if cur_item != null:
		new_template = _update_multiple_actions(cur_item)

	# Make sure the user has not specified a duplicate component name
	if not edit_mode:
		var new_comp_name = ContextHandler.get_objects_from_context(new_template)
		if new_comp_name in components:
			# Let the user know they have entered a duplicate name
			emit_signal("error", "The component/workplane name has already been used.\nPlease select another one.")
			return

	# Handle binary controls
	var combine_map = null
	if cont.is_binary:
		combine_map = cont.get_combine_map()

	emit_signal("ok_signal", edit_mode, new_template, new_context, combine_map)
	hide()


"""
Checks whether or not the component name has been used before.
"""
func _is_component_dup(original_context, new_template):
	# Regex to search for tags, which are used for component names
	var rgx = RegEx.new()
	rgx.compile("\\.tag\\(.*\\)")
	var res = rgx.search_all(new_template)

	# If there is no match at all, then we cannot have a duplicate
	if not res:
		return false
	else:
		# Search all of the results to see if there is a match from the original context
		for r in res:
			if original_context.find(r.get_string()) > 0:
				return true

	return false


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
	emit_signal("cancel")

	hide()


"""
Called when the user selects a different trigger from the top option button.
"""
func _on_ActionOptionButton_item_selected(_index):
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

	# Work-around to force the size changes to take effect
	if visible == true:
		hide()
		show()
	else:
		show()
		hide()


"""
Called when the user clicks the 3D button and toggles it.
"""
func _on_ThreeDButton_toggled(_button_pressed):
	var three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton

	# Make sure that the other buttons are not toggled
	if three_d_btn.pressed:
		# Untoggle all other group buttons
		_untoggle_all_group_buttons(three_d_btn)

		action_filter = "3D"

		# Fill the 3D actions list up the first time it is requested
		if three_d_actions == null:
			three_d_actions = ContextHandler.get_3d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, three_d_actions)

		# Set the help tooltips for all the items in the dropdown
		_set_tooltips()

		_set_action_control()

		# Hide any previously shown sketch tools
		_hide_sketch_controls()

		# Make sure the dialog is sized correctly
		_on_VBoxContainer_resized()


"""
Called when the user clicks the Sketch button and toggles it.
"""
func _on_SketchButton_toggled(_button_pressed):
	var sketch_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton

	if sketch_btn.pressed:
		# Untoggle all other group buttons
		_untoggle_all_group_buttons(sketch_btn)

		action_filter = "2D"

		# Fill the 2D actions list up the first time it is requested
		if two_d_actions == null:
			two_d_actions = ContextHandler.get_2d_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, two_d_actions)

		# Set the help tooltips for all the items in the dropdown
		_set_tooltips()

		_set_action_control()

		# Show preview controls
		$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.show()
		$VBoxContainer/HBoxContainer/ActionContainer/ActionTree.show()
		$VBoxContainer/HBoxContainer/CanvasMarginContainer.show()

		# Make sure the dialog is sized correctly
		_on_VBoxContainer_resized()


"""
Called when the user clicks on the Workplane button and toggles it.
"""
func _on_WorkplaneButton_toggled(_button_pressed):
	var wp_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton

	if wp_btn.pressed:
		# Untoggle all other group buttons
		_untoggle_all_group_buttons(wp_btn)

		action_filter = "WP"

		# Fill in the workplane action list the first time it is requested
		if wp_actions == null:
			wp_actions = ContextHandler.get_wp_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, wp_actions)

		# Set the help tooltips for all the items in the dropdown
		_set_tooltips()

		_set_action_control()

		# Hide any previously shown sketch tools
		_hide_sketch_controls()

		# Make sure the dialog is sized correctly
		_on_VBoxContainer_resized()


"""
Called when the user clicks on the selector button to display
the selector controls.
"""
func _on_SelectorButton_toggled(_button_pressed):
	var selector_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SelectorButton

	if selector_btn.pressed:
		# Untoggle all other group buttons
		_untoggle_all_group_buttons(selector_btn)

		action_filter = "SELECTORS"

		# Fill the selector actions listup the first time it is requested
		if selector_actions == null:
			selector_actions = ContextHandler.get_selector_actions()

		# Repopulate the action option button
		$VBoxContainer/ActionOptionButton.clear()
		Common.load_option_button($VBoxContainer/ActionOptionButton, selector_actions)

		_set_action_control()

		# Hide any previously shown sketch tools
		_hide_sketch_controls()

		# Make sure the dialog is sized correctly
		_on_VBoxContainer_resized()


"""
Called when switching to another group control and needing to hide
any previously displayed sketch controls.
"""
func _hide_sketch_controls():
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/AddButton.hide()
	$VBoxContainer/HBoxContainer/ActionContainer/ActionTree.hide()
	$VBoxContainer/HBoxContainer/CanvasMarginContainer.hide()
	$VBoxContainer/HBoxContainer/ActionContainer/ActionButtonContainer/ItemSelectedContainer.hide()


"""
Called when a new group button is toggled so that all
others can be untoggled.
"""
func _untoggle_all_group_buttons(except):
	var wp_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton
	var three_d_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton
	var sketch_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton
	var selector_btn = $VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SelectorButton

	# Untoggle all buttons except the one that was passed
	if except != wp_btn:
		wp_btn.pressed = false
	if except != three_d_btn:
		three_d_btn.pressed = false
	if except != sketch_btn:
		sketch_btn.pressed = false
	if except != selector_btn:
		selector_btn.pressed = false


"""
Called when the Add button is clicked.
"""
func _on_AddButton_button_down():
	# Get the template from the active control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	var preview_context = cont.get_completed_template()

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	# Add the item to the action tree
	Common.add_item_to_tree(preview_context, $VBoxContainer/HBoxContainer/ActionContainer/ActionTree, action_tree_root)

	_render_action_tree()


"""
Collects all of the completed templates in the Action tree and
renders them on the 2D canvas.
"""
func _render_action_tree():
	# Start to build the preview string based on what is in the actions list
	var script_text = "import cadquery as cq\nresult=cq.Workplane()"

	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	# Search the tree and update the matchine entry in the tree
	var cur_item = action_tree_root.get_children()
	while true:
		if cur_item == null:
			break
		else:
			script_text += cur_item.get_text(0)

			cur_item = cur_item.get_next()

	script_text += ".consolidateWires()\nshow_object(result)"

	# Export the file to the user data directory temporarily
	var json_string = cqgipy.build(script_text)

	if json_string.begins_with("error~"):
		# Let the user know there was an error
		var err = json_string.split("~")[1]
		emit_signal("error", err)
	else:
		var component_json = JSON.parse(json_string).result

		for component in component_json["components"]:
			# If we've found a larger dimension, save the safe scaling, which is the maximum dimension of any component
			var max_dim = component["largestDim"]
			$VBoxContainer/HBoxContainer/CanvasMarginContainer/Canvas2D.set_max_dim(max_dim)

			# Add the edge representations
			for edge in component["cqEdges"]:
				# Add the current line
				$VBoxContainer/HBoxContainer/CanvasMarginContainer/Canvas2D.lines.append([Vector2(edge[0], edge[1]), Vector2(edge[3], edge[4])])

		# Have the 2D canvas re-render the lines that are set for it
		$VBoxContainer/HBoxContainer/CanvasMarginContainer/Canvas2D.update()


"""
Allows action items to be edited by selecting the correct control.
"""
func _on_ActionTree_item_activated():
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	# Get the action name so that we can set the action option correctly
	var item_text = action_tree.get_selected().get_text(0)
	var action_key = item_text.split(".")[1].split("(")[0]

	# Make sure the correct item is selected
#	Common.set_option_btn_by_text($VBoxContainer/ActionOptionButton, action_key)

#	_set_action_control()


"""
Updates the selected action tree item with new settings.
"""
func _on_UpdateButton_button_down():
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	var orig_text = action_tree.get_selected().get_text(0)

	# Get the template from the active control
	var cont = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	var new_text = cont.get_completed_template()

	# Update the old action template to reflect the new settings
	Common.update_tree_item(action_tree, orig_text, new_text)

	# Re-render everything in the action tree
	_update_preview()


"""
Called when an item is selected in the Action tree.
"""
func _on_ActionTree_item_selected():
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	var selected = action_tree.get_selected()

	# Make sure there is an item to work with
	if selected == null:
		return

	# Figure out which control needs to be loaded from the operations list
	var selected_text = selected.get_text(0)
	var ctrl_text = "(" + selected_text.split(".")[1].split("(")[0] + ")"

	# Set the control in the operations drop down based on our partial text
	Common.set_option_btn_by_partial_text($VBoxContainer/ActionOptionButton, ctrl_text)

	# Make sure the matching control is loaded
	_on_ActionOptionButton_item_selected(0)

	# Repopulate the control with the previous settings
	var cur_control = $VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer.get_children()[0]
	cur_control.set_values_from_string(selected_text)

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
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree
	var action_tree_root = action_tree.get_root()

	var selected = action_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Remove the item from the history tree
	action_tree_root.remove_child(selected)
	selected.free()

	# Force an update of the tree
	action_tree.update()

	# Updated the 2D preview
	_update_preview()

"""
Called when the move action item up button is pressed.
"""
func _on_MoveUpButton_button_down():
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

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
	var action_tree = $VBoxContainer/HBoxContainer/ActionContainer/ActionTree

	var selected = action_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Move the item up in the action tree one position
	Common.move_tree_item_down(action_tree, selected)


"""
Called whenever the 2D preview needs to be updated.
"""
func _update_preview():
	# Reset and update the 2D preview
	$VBoxContainer/HBoxContainer/CanvasMarginContainer/Canvas2D.reset()
	$VBoxContainer/HBoxContainer/CanvasMarginContainer/Canvas2D.update()
	self._render_action_tree()

"""
Called when the control loaded in the dynamic contrainer
is changed.
"""
func _on_DynamicContainer_resized():
	_on_VBoxContainer_resized()

"""
Allows a child control to pop up the error dialog.
"""
func _on_error(error_msg):
	emit_signal("error", error_msg)


"""
Allows tooltips to be set for each of the operation items.
"""
func _set_tooltips():
	var popup = $VBoxContainer/ActionOptionButton.get_popup()

	# Step through all of the items in the popup, adding their tooltips
	for i in range(0, popup.get_item_count()):
		# Match the item that is being hovered over to a tooltip
		var child_name = popup.get_item_text(i)

		# Figure out the prefix of the tooltip based on the text in the dropdown popup item
		var child_name_upper = child_name.to_upper()
		if child_name_upper.find("(") > 0:
			child_name_upper = child_name_upper.split("(")[1].split(")")[0]

		# Combine the prefix with the postfix to dynamically find the correct tooltip text
		popup.set_item_tooltip(i, tr(child_name_upper) + "_TOOLTIP")
