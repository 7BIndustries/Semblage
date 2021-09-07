extends "res://addons/gut/test.gd"


"""
Simulates a user right clicking on a Component tree operation item and clicking
the Edit button.
"""
func test_component_edit_button():
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

	# Get the box operation tree item
	var box_item = ct.get_root().get_children()
	box_item = box_item.get_children()
	box_item = box_item.get_next()

	# Make sure that the item we want to edit is selected
	box_item.select(0)

	# Get the box item so that we can test an Edit click on it
	assert_eq(box_item.get_text(0), '.box(10,10,10)', "Make sure that we grabbed the right item.")

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ComponentTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Edit button
	var edit_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	edit_btn = edit_btn.get_children()[0]

	# Make sure that we got the Edit button that was expected
	assert_eq(edit_btn.get_text(), "Edit", "Make sure that the Edit button was selected.")

	# Get a reference to the Operations dialog so that we can make sure it is shown when it should be
	var op_dlg = gui.get_node("ActionPopupPanel")
	var op_dlg_op = gui.get_node("ActionPopupPanel/VBoxContainer/ActionOptionButton")

	# Make sure that the Operations dialog is not visible currently
	assert_false(op_dlg.visible, "Make sure that the Operations dialog is not visible yet.")

	# Trigger the Edit button
	edit_btn.emit_signal("button_down")

	# Make sure that the Operations dialog is visible and that the right operation is selected
	assert_true(op_dlg_op.visible, "Make sure that the Operations dialog is visible now.")
	assert_eq(op_dlg_op.get_item_text(op_dlg_op.get_selected_id()), "Box (box)", "Make sure that the box operation is selected.")


"""
Simulates as if a user right clicked on a Component tree item and then
clicked the Remove button.
"""
func test_component_remove_button():
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

	# Get the box operation tree item
	var box_item = ct.get_root().get_children()
	box_item = box_item.get_children()
	box_item = box_item.get_next()

	# Make sure that the item we want to remove is selected
	box_item.select(0)

	# Get the box item so that we can test a Remove click on it
	assert_eq(box_item.get_text(0), '.box(10,10,10)', "Make sure that we grabbed the right item.")

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ComponentTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Remove button
	var remove_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	remove_btn = remove_btn.get_children()[1]

	# Make sure that we got the Remove button that was expected
	assert_eq(remove_btn.get_text(), "Remove", "Make sure that the Edit button was selected.")

	# Trigger the Remove button
	remove_btn.emit_signal("button_down")

	# Get the box operation tree item
	box_item = ct.get_root().get_children()
	box_item = box_item.get_children()
	box_item = box_item.get_next()

	assert_null(box_item, "Make sure that the box item has been removed.")


"""
Tests as if a component was right clicked on and then shown/hidden.
"""
func test_component_show_hide_button():
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

	# Get the box operation tree item
	var comp_item = ct.get_root().get_children()

	# Make sure that the item we want to show/hide is selected
	comp_item.select(0)

	# Make sure we grabbed the correct item
	assert_eq(comp_item.get_suffix(0), "")

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ComponentTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Show/Hide button
	var show_hide_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	show_hide_btn = show_hide_btn.get_children()[2]

	# Make sure that we got the Show/Hide button that was expected
	assert_eq(show_hide_btn.get_text(), "Show/Hide", "Make sure that the Show/Hide button was selected.")

	# Make sure that the tree item is not collapsed to begin with
	assert_false(comp_item.collapsed, "Make sure that the component tree item is not collapsed to start with.")

	# Trigger the Show/Hide button
	show_hide_btn.emit_signal("button_down")

	assert_true(comp_item.collapsed, "Make sure that the component tree item is collapsed when hidden.")

#	comp_item = ct.get_root().get_children()
	assert_eq(comp_item.get_suffix(0), " (hidden)")


"""
Simulates as if the user right clicked on a Component in the tree
and then clicked the Cancel button.
"""
func test_component_cancel_button():
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

	# Get the box operation tree item
	var box_item = ct.get_root().get_children()
	box_item = box_item.get_children()
	box_item = box_item.get_next()

	# Make sure that the item we want to cancel out of is selected
	box_item.select(0)

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ComponentTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Cancel button
	var cancel_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	cancel_btn = cancel_btn.get_children()[2]

	# Make sure that we got the Cancel button that was expected
	assert_eq(cancel_btn.get_text(), "Cancel", "Make sure that the Cancel button was selected.")

	# Trigger the Cancel button
	cancel_btn.emit_signal("button_down")

	# Make sure that the Cancel button hid the data popup panel
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is hidden again.")


"""
Simulates a user right clicking on a Parameter tree operation item and clicking
the New button.
"""
func test_parameter_new_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ParametersTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the New button
	var new_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	new_btn = new_btn.get_children()[0]

	# Make sure that we got the New button that was expected
	assert_eq(new_btn.get_text(), "New", "Make sure that the New button was selected.")

	# Get a reference to the Parameters dialog so that we can make sure it is shown when it should be
	var param_dlg = gui.get_node("AddParameterDialog")

	# Make sure that the Parameters dialog is not visible currently
	assert_false(param_dlg.visible, "Make sure that the Parameters dialog is not visible yet.")

	# Trigger the New button
	new_btn.emit_signal("button_down")

	# Make sure that the Parameters dialog is visible and that the right operation is selected
	assert_true(param_dlg.get_node("VBoxContainer/ParamNameLabel").visible, "Make sure that the Parameters dialog is visible now.")


"""
Simulates a user right clicking on a Component tree operation item and clicking
the Edit button.
"""
func test_parameter_edit_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var pt = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree")

	# Add a parameter item that we can edit
	Common.add_columns_to_tree(["dim1", "10"], pt, pt.get_root())
	var dim_item = pt.get_root().get_children()
	dim_item.select(0)

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ParametersTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Edit button
	var edit_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	edit_btn = edit_btn.get_children()[1]

	# Make sure that we got the Edit button that was expected
	assert_eq(edit_btn.get_text(), "Edit", "Make sure that the Edit button was selected.")

	# Get a reference to the Parameters dialog so that we can make sure it is shown when it should be
	var param_dlg = gui.get_node("AddParameterDialog")

	# Make sure that the Parameters dialog is not visible currently
	assert_false(param_dlg.visible, "Make sure that the Parameters dialog is not visible yet.")

	# Trigger the Edit button
	edit_btn.emit_signal("button_down")

	# Make sure that the Parameters dialog is visible and that the right operation is selected
	assert_true(param_dlg.get_node("VBoxContainer/ParamNameLabel").visible, "Make sure that the Parameters dialog is visible now.")


"""
Simulates as if the user right clicked on an item in the parameter tree
and then clicked Remove.
"""
func test_parameter_remove_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Set up the main component tree with the content we want
	var pt = gui.get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree")

	# Add a parameter item that we can remove
	Common.add_columns_to_tree(["dim1", "10"], pt, pt.get_root())
	var dim_item = pt.get_root().get_children()
	dim_item.select(0)

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ParametersTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Remove button
	var remove_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	remove_btn = remove_btn.get_children()[2]

	# Make sure that we got the Remove button that was expected
	assert_eq(remove_btn.get_text(), "Remove", "Make sure that the Remove button was selected.")

	# Get a reference to the Parameters dialog so that we can make sure it is shown when it should be
	var param_dlg = gui.get_node("AddParameterDialog")

	# Make sure that the Parameters dialog is not visible currently
	assert_false(param_dlg.visible, "Make sure that the Parameters dialog is not visible yet.")

	# Trigger the Remove button
	remove_btn.emit_signal("button_down")

	# The item that was selected should have been removed from the tree
	dim_item = pt.get_root().get_children()
	assert_null(dim_item, "Make sure the selected parameter was removed.")


"""
Simulates as if the user right clicked on the parameter tree and then
clicked Cancel.
"""
func test_parameter_cancel_button():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	gui._ready()

	# Initialize the trees
	gui._init_component_tree()
	gui._init_params_tree()

	# Get a reference to the data popup panel
	var dpp = gui.get_node('DataPopupPanel')

	# Make sure that the data popup panel is not visible yet since it has not been requested
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is not visible yet.")

	# Simulate a right click on the item
	gui._on_ParametersTree_activate_data_popup()

	# Make sure that the data popup panel is visible now that it has been requested
	assert_true(dpp.visible, "Make sure that the DataPopupPanel is visible now.")

	# Get a reference to the Cancel button
	var cancel_btn = gui.get_node("DataPopupPanel/DataPopupVBox")
	cancel_btn = cancel_btn.get_children()[3]

	# Make sure that we got the Cancel button that was expected
	assert_eq(cancel_btn.get_text(), "Cancel", "Make sure that the Cancel button was selected.")

	# Trigger the Cancel button
	cancel_btn.emit_signal("button_down")

	# Make sure that the Cancel button hid the data popup panel
	assert_false(dpp.visible, "Make sure that the DataPopupPanel is hidden again.")


"""
Simulates the user dragging and dropping an item.
"""
func test_operation_drag_and_drop():
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

	# Get the box operation tree item
	var box_item = ct.get_root().get_children()
	var drop_item = box_item.get_children()
	var drag_item = drop_item.get_next()

	# Make sure that the item we want to remove is selected
	box_item.select(0)

	# Get the box item so that we can test a Remove click on it
	assert_eq(drag_item.get_text(0), '.box(10,10,10)', "Make sure that we grabbed the right item.")
	assert_eq(drop_item.get_text(0), '.Workplane().tag("box1")', "Make sure that we grabbed the right item.")

	Common.move_before(drag_item, drop_item)

	# Get the box operation tree item
	box_item = ct.get_root().get_children()
	drop_item = box_item.get_children()
	drag_item = drop_item.get_next()

	# Make sure the items got swapped
	assert_eq(drop_item.get_text(0), '.box(10,10,10)', "Make sure that we grabbed the right item.")
	assert_eq(drag_item.get_text(0), '.Workplane().tag("box1")', "Make sure that we grabbed the right item.")
