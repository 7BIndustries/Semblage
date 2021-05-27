extends "res://addons/gut/test.gd"

var gui_scene = load("res://GUI.tscn")


"""
Tests as if the user clicked the Open button.
"""
func test_open_button():
	# Grab an instance of the main GUI and make sure we got it
	var gui = gui_scene.instance()
	assert_not_null(gui)
	add_child_autoqfree(gui)

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

	remove_child(gui)
	gui.free()

"""
Simulates the user clicking the Save button.
"""
func test_save_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = gui_scene.instance()
	assert_not_null(gui)
	add_child_autoqfree(gui)

	# Get a reference to the Save button and make sure we got something
	var save_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton")
	assert_not_null(save_btn, "Can access the Save button.")

	# Get a reference to the toolbar popup container
	var popup = gui.get_node("ToolbarPopupPanel")
	assert_not_null(popup, "Can access the toolbar popup.")

	# Start watching signals so we know if something happened that should have
	watch_signals(save_btn)
	watch_signals(popup)

	# Simulate a mouse click
	save_btn.emit_signal("button_down")

	yield(yield_to(save_btn, "button_down", 2), YIELD)

	# Make sure that the proper signals were fired
	assert_signal_emitted(save_btn, 'button_down', "Make sure the event fires from the Save button.")

	# Make sure the popup dialog has the proper buttons in them
	var save_sub_btn = popup.get_child(0).get_child(0)
	assert_eq(save_sub_btn.get_text(), "Save", "Make sure the save button is present.")

	# Get a reference to the SaveDialog so we can check it
	var save_dlg = gui.get_node("SaveDialog")
	watch_signals(save_dlg)

	# Simulate a mouse click of the save sub button
	save_sub_btn.emit_signal("button_down")

	yield(yield_to(save_sub_btn, "button_down", 2), YIELD)

	assert_signal_emitted(save_dlg, "about_to_show")
	assert_eq(save_dlg.filters[0], "*.py", "Dialog filter set for Python files.")

	# Try to save a file and make sure the correct event is fired
#	save_dlg.current_dir = "/tmp"
#	save_dlg.current_file = "test.py"
#	save_dlg.current_path = "/tmp"
#	save_dlg.get_line_edit().set_text("/tmp/test.py")
#	print(save_dlg.get_children()[2].get_children()[2].get_text())
#	save_dlg.get_children()[2].get_children()[3].emit_signal("button_down")

#	yield(yield_to(save_dlg.get_children()[2].get_children()[3], "button_down", 5), YIELD)

#	assert_true(File.new().file_exists("user://test.py"), "Make sure that the file was saved.")

	remove_child(gui)
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
