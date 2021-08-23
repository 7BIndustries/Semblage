extends "res://addons/gut/test.gd"


"""
Simulates the user clicking the Save button.
"""
func test_save_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

	# Make sure the objects tree has items in it
	var component_tree = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	var component_tree_root = component_tree.get_root()
	Common.add_item_to_tree("change_me", component_tree, component_tree_root)

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

	# Give the file time to be written
	yield(yield_to(save_dlg, "file_selected", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.py"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.py", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content, gui._convert_component_tree_to_script(true), "Make sure that the saved file has the correct contents.")


"""
Tests as if the user saved multiple components to file.
"""
func test_save_multi_component():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_component("box2", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)
	Common.add_operation("box2", '.Workplane().tag("box2")', ct)
	Common.add_operation("box2", '.center(5, 5)', ct)
	Common.add_operation("box2", '.box(10,10,10)', ct)

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

	assert_signal_emitted(save_dlg, "about_to_show")
	assert_eq(save_dlg.filters[0], "*.py", "Dialog filter set for Python files.")

	# Try to save a file and fire the file selected event to perform the save
	save_dlg.current_dir = "/tmp"
	save_dlg.current_file = "test.py"
	save_dlg.current_path = "/tmp"
	save_dlg.get_line_edit().set_text("/tmp/test.py")
	save_dlg.emit_signal("file_selected", "/tmp/test.py")

	# Give the file time to be written
	yield(yield_to(save_dlg, "file_selected", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.py"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.py", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content, gui._convert_component_tree_to_script(true), "Make sure that the saved file has the correct contents.")


"""
Tests as if the user clicked the Open button.
"""
func test_open_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
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

	# Set the file path and attempt an open
	open_dlg.current_dir = "res://samples"
	open_dlg.current_file = "basic_box.py"
	open_dlg.current_path = "res://samples"
	open_dlg.get_line_edit().set_text("res://samples/basic_box.py")
	open_dlg.emit_signal("file_selected", "res://samples/basic_box.py")

	# Give the file time to be read
	yield(yield_to(open_dlg, "file_selected", 5), YIELD)

	# Make sure that the component was loaded into the component tree properly
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	assert_eq(ct.get_root().get_children().get_text(0), "change_me", "Make sure the proper component text was loaded")


"""
Tests as if the user opened a file with multiple components in it.
"""
func test_open_multi_component():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
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

	# Set the file path and attempt an open
	open_dlg.current_dir = "res://samples"
	open_dlg.current_file = "basic_multi_comp.py"
	open_dlg.current_path = "res://samples"
	open_dlg.get_line_edit().set_text("res://samples/basic_multi_comp.py")
	open_dlg.emit_signal("file_selected", "res://samples/basic_multi_comp.py")

	# Give the file time to be read
	yield(yield_to(open_dlg, "file_selected", 5), YIELD)

	# Make sure that the component was loaded into the component tree properly
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	assert_eq(ct.get_root().get_children().get_text(0), "change_me", "Make sure the proper first component text was loaded")
	assert_eq(ct.get_root().get_children().get_next().get_text(0), "change_me2", "Make sure the proper second component text was loaded")


"""
Tests as if the user were interacting with the Make button to create a DXF.
"""
func test_make_button_dxf():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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

	# Get a reference to the ExportDXFDialog so we can check it
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

	# Give the file time to be written
	yield(yield_to(ok_btn, "button_down", 5), YIELD)

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
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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

	# Get a reference to the ExportDXFDialog so we can check it
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

	# Give the file time to be written
	yield(yield_to(ok_btn, "button_down", 5), YIELD)

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


"""
Tests as if the user were interacting with the Make button to create an SVG file.
"""
func test_make_button_svg():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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
	var make_sub_btn = popup.get_child(0).get_child(2)
	assert_eq(make_sub_btn.get_text(), "SVG", "Make sure the SVG button is present.")

	# Get a reference to the ExportSVGDialog so we can check it
	var svg_dlg = gui.get_node("ExportSVGDialog")
	watch_signals(svg_dlg)

	# Simulate a mouse click of the export SVG sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the SVG export dialog shows up
	assert_signal_emitted(svg_dlg, "about_to_show")

	# Set the export directory manually
	var path_txt = svg_dlg.get_node("MarginContainer/VBoxContainer/PathContainer/PathText")
	path_txt.set_text("/tmp/test.svg")

	# Export the SCG file
	var ok_btn = svg_dlg.get_node("MarginContainer/VBoxContainer/OkButton")
	assert_not_null(ok_btn)
	watch_signals(ok_btn)
	ok_btn.emit_signal("button_down")
	assert_signal_emitted(ok_btn, "button_down")

	# Give the file time to be written
	yield(yield_to(ok_btn, "button_down", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.svg"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.svg", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], '<?xml version="1.0" encoding="UTF-8" standalone="no"?>', "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "<svg", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "</svg>", "Make sure that the saved file has the correct contents.")


"""
Tests as if the user were interacting with the Make button to create a set
of SVG files.
"""
func test_make_button_svg_section():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.rect(10,10)', ct)
	Common.add_operation("box1", '.extrude(10)', ct)

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
	var make_sub_btn = popup.get_child(0).get_child(2)
	assert_eq(make_sub_btn.get_text(), "SVG", "Make sure the SVG button is present.")

	# Get a reference to the ExportSVGDialog so we can check it
	var svg_dlg = gui.get_node("ExportSVGDialog")
	watch_signals(svg_dlg)

	# Simulate a mouse click of the export SVG sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the SVG export dialog shows up
	assert_signal_emitted(svg_dlg, "about_to_show")

	# Set the export directory manually
	var path_txt = svg_dlg.get_node("MarginContainer/VBoxContainer/PathContainer/PathText")
	path_txt.set_text("/tmp/test.svg")

	# Enable the seciton controls
	var section_btn = svg_dlg.get_node("MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton")
	assert_not_null(section_btn)
	section_btn.emit_signal("toggled", true)
	section_btn.pressed = true
	svg_dlg._on_CheckButton_toggled(section_btn)
	var section_cont = svg_dlg.get_node("MarginContainer/VBoxContainer/SectionContainer")
	assert_true(section_cont.visible, "Make sure the section controls are visible.")

	# Export the SVG files
	var ok_btn = svg_dlg.get_node("MarginContainer/VBoxContainer/OkButton")
	assert_not_null(ok_btn)
	watch_signals(ok_btn)
	ok_btn.emit_signal("button_down")
	assert_signal_emitted(ok_btn, "button_down")

	# Give the file time to be written
	yield(yield_to(ok_btn, "button_down", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test_0.svg"), "Make sure that the first file was saved.")
	assert_true(File.new().file_exists("/tmp/test_1.svg"), "Make sure that the second file was saved.")
	assert_true(File.new().file_exists("/tmp/test_2.svg"), "Make sure that the third file was saved.")
	assert_true(File.new().file_exists("/tmp/test_3.svg"), "Make sure that the forth file was saved.")
	assert_true(File.new().file_exists("/tmp/test_4.svg"), "Make sure that the fifth file was saved.")

	# Make sure that the first saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test_0.svg", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], '<?xml version="1.0" encoding="UTF-8" standalone="no"?>', "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "<svg", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "</svg>", "Make sure that the saved file has the correct contents.")

	# Make sure that the first saved file has the correct contents
	file.open("/tmp/test_4.svg", File.READ)
	content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], '<?xml version="1.0" encoding="UTF-8" standalone="no"?>', "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[1], "<svg", "Make sure that the saved file has the correct contents.")
	assert_eq(content.split("\n")[-2], "</svg>", "Make sure that the saved file has the correct contents.")


"""
Tests as if the user were interacting with the Make button to create a set
of SVG files.
"""
func test_make_button_svg_section_error():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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
	var make_sub_btn = popup.get_child(0).get_child(2)
	assert_eq(make_sub_btn.get_text(), "SVG", "Make sure the SVG button is present.")

	# Get a reference to the ExportSVGDialog so we can check it
	var svg_dlg = gui.get_node("ExportSVGDialog")
	watch_signals(svg_dlg)

	# Simulate a mouse click of the export SVG sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the SVG export dialog shows up
	assert_signal_emitted(svg_dlg, "about_to_show")

	# Set the export directory manually
	var path_txt = svg_dlg.get_node("MarginContainer/VBoxContainer/PathContainer/PathText")
	path_txt.set_text("/tmp/test.svg")

	# Enable the seciton controls
	var section_btn = svg_dlg.get_node("MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton")
	assert_not_null(section_btn)
	section_btn.emit_signal("toggled", true)
	section_btn.pressed = true
	svg_dlg._on_CheckButton_toggled(section_btn)
	var section_cont = svg_dlg.get_node("MarginContainer/VBoxContainer/SectionContainer")
	assert_true(section_cont.visible, "Make sure the section controls are visible.")

	# Export the SVG files
	var ok_btn = svg_dlg.get_node("MarginContainer/VBoxContainer/OkButton")
	assert_not_null(ok_btn)
	watch_signals(ok_btn)
	ok_btn.emit_signal("button_down")
	assert_signal_emitted(ok_btn, "button_down")

	# Get a reference to the error dialog
	var error_dlg = gui.get_node("ErrorDialog")
	watch_signals(error_dlg)

	# Give the file time to be written
	yield(yield_to(ok_btn, "button_down", 5), YIELD)

	# Make sure the error dialog has the correct text in it
	assert_eq(error_dlg.dialog_text.split("\n")[0], "There was an error exporting to SVG. If you are slicing an SVG", "Make sure the error dialog has the correct text.")


"""
Tests as if the user clicked the Export->STEP button.
"""
func test_make_button_step():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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
	var make_sub_btn = popup.get_child(0).get_child(1)
	assert_eq(make_sub_btn.get_text(), "STEP", "Make sure the STEP button is present.")

	# Get a reference to the ExportDialog so we can export the file manually
	var export_dlg = gui.get_node("ExportDialog")
	watch_signals(export_dlg)

	# Simulate a mouse click of the export STEP sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the export dialog shows up
	assert_signal_emitted(export_dlg, "about_to_show")

	# Manually set the path and file name
	export_dlg.current_dir = "/tmp"
	export_dlg.current_file = "test.step"
	export_dlg.current_path = "/tmp"
	export_dlg.get_line_edit().set_text("/tmp/test.step")
	export_dlg.emit_signal("file_selected", "/tmp/test.step")

	# Give the file time to be written
	yield(yield_to(export_dlg, "file_selected", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.step"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.step", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], 'ISO-10303-21;')
	assert_eq(content.split("\n")[2], "FILE_DESCRIPTION(('Open CASCADE Model'),'2;1');")
	assert_eq(content.split("\n")[-2], 'END-ISO-10303-21;')

"""
Tests as if the user clicked the Export->STEP button.
"""
func test_make_button_stl():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

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
	var make_sub_btn = popup.get_child(0).get_child(0)
	assert_eq(make_sub_btn.get_text(), "STL", "Make sure the STL button is present.")

	# Get a reference to the ExportDialog so we can export the file manually
	var export_dlg = gui.get_node("ExportDialog")
	watch_signals(export_dlg)

	# Simulate a mouse click of the export STL sub button
	make_sub_btn.emit_signal("button_down")

	# Make sure that the export dialog shows up
	assert_signal_emitted(export_dlg, "about_to_show")

	# Manually set the path and file name
	export_dlg.current_dir = "/tmp"
	export_dlg.current_file = "test.stl"
	export_dlg.current_path = "/tmp"
	export_dlg.get_line_edit().set_text("/tmp/test.stl")
	export_dlg.emit_signal("file_selected", "/tmp/test.stl")

	# Give the file time to be written
	yield(yield_to(export_dlg, "file_selected", 5), YIELD)

	# Make sure that the saved file exists
	assert_true(File.new().file_exists("/tmp/test.stl"), "Make sure that the file was saved.")

	# Make sure that the saved file has the correct contents
	var file = File.new()
	file.open("/tmp/test.stl", File.READ)
	var content = file.get_as_text()
	file.close()
	assert_eq(content.split("\n")[0], "solid ")
	assert_eq(content.split("\n")[2], "   outer loop")
	assert_eq(content.split("\n")[-2], "endsolid")

"""
Tests as if the user had clicked the close button.
"""
func test_close_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

	# Get a reference to the parameter tree
	var param_tree = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree")
	var param_tree_root = gui._get_params_tree_root(param_tree)
	Common.add_columns_to_tree(["test_var", "1"], param_tree, param_tree_root)

	# Make sure that the parameters tree has items in it
	assert_not_null(param_tree_root.get_children(), "Make sure the parameters tree has items in it.")

	# Render the object in the 3D viewport
	gui._execute_and_render()

	# Get the viewport so we can make sure it has contents
	var vp = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	assert_eq(vp.get_child_count(), 17)

	# Make sure the components tree has items in it
	var components_tree = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("change_me", components_tree)
	assert_not_null(components_tree.get_root().get_children(), "Make sure the object tree has items in it.")

	# Get a reference to the close button so we can simulate it being clicked
	var close_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/CloseButton")

	# Simulate a mouse click of the close button
	close_btn.emit_signal("button_down")

	# Check to make sure the object tree is cleared
	assert_null(components_tree.get_root().get_children(), "Make sure the objects tree was cleared.")

	# Check to make sure that the params tree is cleared
	param_tree_root = gui._get_params_tree_root(param_tree)
	var child = param_tree_root.get_children()
	assert_null(child, "Make sure the parameters tree is empty.")

	# Make sure the 3D viewport is cleared
	assert_eq(vp.get_child_count(), 2, "Make sure that the 3D viewport was cleared.")


"""
Tests as if the user clicked the Home button to bring the camera position
back to a known good location and orientation.
"""
func test_home_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var ct = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	Common.add_component("box1", ct)
	Common.add_operation("box1", '.Workplane().tag("box1")', ct)
	Common.add_operation("box1", '.box(10,10,10)', ct)

	# Convert the components tree into a render
	gui._execute_and_render()

	# Get the viewport so we can make sure it has contents
	var vp = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	assert_eq(vp.get_child_count(), 17)

	# Get a reference to the home button so we can simulate it being clicked
	var home_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/HomeViewButton")

	# Simulate a mouse click of the home button
	home_btn.emit_signal("button_down")

	# Get the camera so we can check and manipulate its transform
	var cam = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera")
	assert_not_null(cam)

	assert_eq(str(cam.transform), "-0.707107, -0.408248, 0.57735, 0.707107, -0.408248, 0.57735, 0, 0.816497, 0.57735 - 14.819298, 14.819298, 14.819298", "Make sure the camera is in the right position with the correct rotation.")


"""
Tests as if the user clicked the About button to display information about Semblage.
"""
func test_about_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui)
	gui._ready()

	# Get a reference to the about button so we can simulate it being clicked
	var about_btn = gui.get_node("GUI/VBoxContainer/PanelContainer/Toolbar/AboutButton")
	assert_not_null(about_btn)

	var about_dlg = gui.get_node("AboutDialog")
	assert_not_null(about_dlg)
	watch_signals(about_dlg)

	# Simulate a mouse click of the about button
	about_btn.emit_signal("button_down")

	# Make sure that the about dialog is going to be visible
	assert_signal_emitted(about_dlg, "about_to_show", "Make sure that the About dialog will be visible.")

	# Make sure that the About dialog is showing correct information
	var info_box = about_dlg.get_node("AboutTabContainer/Info/InfoLabel")
	assert_not_null(info_box, "Make sure there is a valid reference to the info box.")
	assert_eq(info_box.get_text().split("\n")[0], "[center][b]Semblage v0.4.0-alpha[/b]", "Make sure the info box has the correct info at the top.")

	# Make sure that the Docs dialog is showing correct information
	var docs_box = about_dlg.get_node("AboutTabContainer/Docs/DocsLabel")
	assert_not_null(docs_box, "Make sure there is a valid reference to the docs box.")
	assert_eq(docs_box.get_text().split("\n")[4], "[url=https://semblage.7bindustries.com/en/latest/]Semblage[/url]", "Make sure the documentation box contains the correct information.")

	# Make sure that the Acknowledgements dialog is showing correct information
	var ack_box = about_dlg.get_node("AboutTabContainer/Acknowledgements/AckLabel")
	assert_not_null(ack_box, "Make sure there is a valid reference to the acknowledgements box.")
	assert_eq(ack_box.get_text().split("\n")[3], "[center][b]CONTRIBUTORS[/b]", "Make sure the acknowledgements box contains the correct information.")
