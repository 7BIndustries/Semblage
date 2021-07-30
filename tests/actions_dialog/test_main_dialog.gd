extends "res://addons/gut/test.gd"


"""
Tests as if the user clicks the workplane group button.
"""
func test_workplane_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	var popup = gui.get_node("ActionPopupPanel")
	assert_not_null(popup)

	# Simulate a click of the workplane button
	var wp_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/WorkplaneButton")
	assert_not_null(wp_btn)
	wp_btn.pressed = true
	wp_btn.emit_signal("toggled", wp_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "New Component")


"""
Tests as if the user clicked the 3D button.
"""
func test_threed_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	var popup = gui.get_node("ActionPopupPanel")
	assert_not_null(popup)

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "Blind Cut (cutBlind)")


"""
Tests as if the user clicked the Sketch button.
"""
func test_sketch_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	var popup = gui.get_node("ActionPopupPanel")
	assert_not_null(popup)

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SketchButton")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "Circle (circle)")


"""
Tests as if the user clicked the Selectors button.
"""
func test_selector_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	var popup = gui.get_node("ActionPopupPanel")
	assert_not_null(popup)

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/SelectorButton")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "selectors")
