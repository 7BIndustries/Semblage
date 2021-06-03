extends "res://addons/gut/test.gd"


"""
Simulates the user clicking the Save button.
"""
func test_save_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)

	# Make sure there is default component text to work with
	gui.component_text = "# Semblage v0.2.0-alpha\nimport cadquery as cq\n"

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

	# This is left here in case there are race conditions with the tests
#	yield(yield_to(save_btn, "button_down", 2), YIELD)

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
#
	assert_signal_emitted(save_dlg, "about_to_show")
	assert_eq(save_dlg.filters[0], "*.py", "Dialog filter set for Python files.")

	# Try to save a file and fire the file selected event to perform the save
	save_dlg.current_dir = "/tmp"
	save_dlg.current_file = "test.py"
	save_dlg.current_path = "/tmp"
	save_dlg.get_line_edit().set_text("/tmp/test.py")
	save_dlg.emit_signal("file_selected", "/tmp/test.py")

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.py"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.py", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content, gui.component_text + "\nshow_object(result)", "Make sure that the saved file has the correct contents.")


"""
Tests as if the user clicked the Open button.
"""
func test_open_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	gui._ready()

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

	# Make sure that the component text is blank to start with
	assert_null(gui.component_text, "Make sure that no component text is set.")

	# Set the file path and attempt an open
	open_dlg.current_dir = "/tmp"
	open_dlg.current_file = "test.py"
	open_dlg.current_path = "/tmp"
	open_dlg.get_line_edit().set_text("/tmp/test.py")
	open_dlg.emit_signal("file_selected", "/tmp/test.py")

	# Make sure that the proper script text was loaded
	assert_eq(gui.component_text, "# Semblage v0.2.0-alpha\nimport cadquery as cq\n# start_params\n# end_params\nresult=cq\n", "Make sure the proper component text was loaded")
