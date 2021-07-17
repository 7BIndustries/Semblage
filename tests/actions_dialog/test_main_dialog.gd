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

	# Give the file time to be written
#	yield(yield_to(wp_btn, "toggled", 5), YIELD)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "New Component")

	wp_btn.free()
	popup.free()
