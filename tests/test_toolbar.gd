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

	# Give the file time to be writte
	yield(yield_to(save_dlg, "file_selected", 2), YIELD)

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

	# Give the file time to be read
	yield(yield_to(open_dlg, "file_selected", 2), YIELD)

	# Make sure that the proper script text was loaded
	assert_eq(gui.component_text, "# Semblage v0.2.0-alpha\nimport cadquery as cq\n# start_params\n# end_params\nresult=cq\n", "Make sure the proper component text was loaded")


"""
Tests as if the user were interacting with the Make button to create a DXF.
"""
func test_make_button_dxf():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	gui._ready()

	# Make sure there is default component text to work with
	gui.component_text = "# Semblage v0.2.0-alpha\nimport cadquery as cq\nresult=cq.Workplane().box(1,1,1)\n"

	# Get a reference to the make button so we can simulate user interaction with it
	var make_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton")
	assert_not_null(make_btn, "Can access the Make/Export button.")

	# Get a reference to the toolbar popup container
	var popup = gui.get_node("ToolbarPopupPanel")
	assert_not_null(popup, "Can access the toolbar popup.")

	# Start watching signals so we know if something happened that should have
	watch_signals(make_btn)
	watch_signals(popup)

	# Simulate a mouse click
	make_btn.emit_signal("button_down")

	# Make sure the popup dialog has the proper buttons in it
	var make_sub_btn = popup.get_child(0).get_child(3)
	assert_eq(make_sub_btn.get_text(), "DXF", "Make sure the DXF button is present.")

	# Get a reference to the ExportSVGDialog so we can check it
	var dxf_dlg = gui.get_node("ExportDXFDialog")
	watch_signals(dxf_dlg)

	# Simulate a mouse click of the export DXF sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the DXF export dialog shows up
	assert_signal_emitted(dxf_dlg, "about_to_show")

	# Set the export directory manually
	var path_txt = dxf_dlg.get_node("MainVBoxContainer/HBoxContainer/PathText")
	path_txt.set_text("/tmp/test.dxf")

	# Export the DXF file
	var ok_btn = dxf_dlg.get_node("MainVBoxContainer/OkButton")
	assert_not_null(ok_btn)
	watch_signals(ok_btn)
	ok_btn.emit_signal("button_down")
	assert_signal_emitted(ok_btn, "button_down")

	# Give the file time to be writte
	yield(yield_to(ok_btn, "button_down", 2), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.dxf"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.dxf", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], "  0", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "SECTION", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "EOF", "Make sure that the saved file has the correct contents.")


"""
Tests as if the user were interacting with the Make button to create a DXF.
"""
func test_make_button_dxf_section():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	gui._ready()

	# Make sure there is default component text to work with
	gui.component_text = "# Semblage v0.2.0-alpha\nimport cadquery as cq\nresult=cq.Workplane().box(1,1,1)\n"

	# Get a reference to the make button so we can simulate user interaction with it
	var make_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton")
	assert_not_null(make_btn, "Can access the Make/Export button.")

	# Get a reference to the toolbar popup container
	var popup = gui.get_node("ToolbarPopupPanel")
	assert_not_null(popup, "Can access the toolbar popup.")

	# Start watching signals so we know if something happened that should have
	watch_signals(make_btn)
	watch_signals(popup)

	# Simulate a mouse click
	make_btn.emit_signal("button_down")

	# Make sure the popup dialog has the proper buttons in it
	var make_sub_btn = popup.get_child(0).get_child(3)
	assert_eq(make_sub_btn.get_text(), "DXF", "Make sure the DXF button is present.")

	# Get a reference to the ExportSVGDialog so we can check it
	var dxf_dlg = gui.get_node("ExportDXFDialog")
	watch_signals(dxf_dlg)

	# Simulate a mouse click of the export DXF sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the DXF export dialog shows up
	assert_signal_emitted(dxf_dlg, "about_to_show")

	# Set the export directory manually
	var path_txt = dxf_dlg.get_node("MainVBoxContainer/HBoxContainer/PathText")
	path_txt.set_text("/tmp/test.dxf")

	# Enable the seciton controls
	var section_btn = dxf_dlg.get_node("MainVBoxContainer/CheckContainer/CheckButton")
	assert_not_null(section_btn)
	section_btn.emit_signal("toggled", true)
	section_btn.pressed = true
	dxf_dlg._on_CheckButton_toggled(section_btn)
	var section_cont = dxf_dlg.get_node("MainVBoxContainer/SectionContainer")
	assert_true(section_cont.visible, "Make sure the section controls are visible.")

	# Export the DXF file
	var ok_btn = dxf_dlg.get_node("MainVBoxContainer/OkButton")
	assert_not_null(ok_btn)
	watch_signals(ok_btn)
	ok_btn.emit_signal("button_down")
	assert_signal_emitted(ok_btn, "button_down")

	# Give the file time to be writte
	yield(yield_to(ok_btn, "button_down", 2), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test_0.dxf"), "Make sure that the first file was saved.")
	assert_true(File.new().file_exists("/tmp/test_1.dxf"), "Make sure that the second file was saved.")
	assert_true(File.new().file_exists("/tmp/test_2.dxf"), "Make sure that the third file was saved.")
	assert_true(File.new().file_exists("/tmp/test_3.dxf"), "Make sure that the forth file was saved.")
	assert_true(File.new().file_exists("/tmp/test_4.dxf"), "Make sure that the fifth file was saved.")

	# Make sure that the first saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test_0.dxf", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], "  0", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "SECTION", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "EOF", "Make sure that the saved file has the correct contents.")

	# Make sure that the first saved file has the correct contents
	file.open("/tmp/test_4.dxf", File.READ)
	content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], "  0", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "SECTION", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "EOF", "Make sure that the saved file has the correct contents.")

#var make_sub_btn = popup.get_child(0).get_child(0)
#	assert_eq(make_sub_btn.get_text(), "STL", "Make sure the STL button is present.")
#	make_sub_btn = popup.get_child(0).get_child(1)
#	assert_eq(make_sub_btn.get_text(), "STEP", "Make sure the STEP button is present.")
#	make_sub_btn = popup.get_child(0).get_child(2)
#	assert_eq(make_sub_btn.get_text(), "SVG", "Make sure the SVG button is present.")
