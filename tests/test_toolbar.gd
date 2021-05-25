extends "res://addons/gut/test.gd"

var gui_scene = load("res://GUI.tscn")


"""
Tests as if the user clicked the Open button.
"""
func test_open_button():
	var gui = gui_scene.instance()

	# Make sure we got the scene instance
	assert_not_null(gui)

	# Get a reference to the open button and make sure we got something
	var open_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/OpenButton")
	assert_not_null(open_btn, "Can access the Open button.")

	# Watch the signals on the open button
	watch_signals(open_btn)

	# Get a reference to the open dialog
	var open_dlg = gui.get_node("OpenDialog")
	assert_not_null(open_dlg, "Can access the Open component dialog.")

	# Watch the signals for the open dialog
	watch_signals(open_dlg)

	# Simulate a mouse click
	open_btn.emit_signal("button_down")

	# Make sure that the Open dialog is set up properly
	assert_eq(open_dlg.filters[0], "*.py", "Dialog filter set for Python files.")

	# Make sure that the proper signals were fired
	assert_signal_emitted(open_btn, 'button_down', "Make sure the event fires from the Open button.")
	assert_signal_emitted(open_dlg, "about_to_show")

	gui.free()

# func before_all():
# 	gut.p("Runs once before all tests")

# func before_each():
# 	gut.p("Runs before each test.")func after_all():
# 	gut.p("Runs once after all tests")
# 	gui.free()
# 	assert_no_new_orphans('There should not be any orphaned objects.')

# func after_each():
# 	gut.p("Runs after each test.")

# func after_all():
# 	gut.p("Runs once after all tests")
# 	gui.free()
# 	assert_no_new_orphans('There should not be any orphaned objects.')

# func test_assert_eq_number_not_equal():
# 	assert_eq(1, 2, "Should fail.  1 != 2")

# func test_assert_eq_number_equal():
# 	assert_eq('asdf', 'asdf', "Should pass")
