extends "res://addons/gut/test.gd"

"""
Simulates as if the user was working with the Union control.
"""
func test_union_control():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	assert_not_null(gui, "Make sure we got a valid reference to the main GUI.")
	var popup = gui.get_node("ActionPopupPanel")
	assert_not_null(popup, "Make sure we got a valid reference to the Operations dialog.")

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton")
	assert_not_null(threed_btn, "Make sure we got a valid reference to the 3D group button.")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	Common.set_option_btn_by_text(action_btn, "Boolean - Union (union)")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "Boolean - Union (union)")
	action_btn.emit_signal("item_selected", 0)

	# Get a reference to the control that has been loaded
	var union_control = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer").get_children()[0]
	assert_not_null(union_control, "Make sure we got a valid reference to the union control.")

	# Set the control up like it has been used
	popup.original_context = '# Semblage v0.2\nimport cadquery as cq\nbox1=cq.Workplane().tag("box1").box(10,10,10)\nbox2=.Workplane().tag("box2").center(5, 5).box(10,10,10)'
	gui.components["box1"] = ['.Workplane().tag("box1")', '.box(10,10,10)']
	gui.components["box2"] = ['.Workplane().tag("box2")', '.center(5, 5)', '.box(10,10,10)']

	# Initialize the trees
	gui._init_object_tree()
	gui._init_history_tree()
	gui._init_params_tree()

	# Fake out the 2D operation action tree
	var action_tree = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/ActionTree")
	var action_tree_root = action_tree.create_item()

	union_control._ready()

	# Render the object in the 3D viewport
	gui._render_history_tree()

	# Get the viewport so we can make sure it has contents
	var vp = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	assert_eq(vp.get_child_count(), 28)

	# Get references to the controls on the form
	var first_object_opt = union_control.get_node("first_obj_group/first_object_opt")
	assert_not_null(first_object_opt, "Make sure we got a valid reference to the first object option button.")
	var second_object_opt = union_control.get_node("second_obj_group/second_object_opt")
	assert_not_null(second_object_opt, "Make sure we got a valid reference to the second object option button.")
	var tag_name_txt = union_control.get_node("tag_name_group/tag_name_txt")

	# Make sure all of the controls have the correct default values in them
	assert_eq(first_object_opt.get_item_text(first_object_opt.get_selected_id()), "box1", "Make sure the first object control has the correct default value.")
	assert_eq(second_object_opt.get_item_text(second_object_opt.get_selected_id()), "box1", "Make sure the second object control has the correct default value.")

	# Make sure that the error button is visible and has the correct tooltip
	var error_btn = union_control.get_node("error_btn_group/error_btn")
	assert_eq(error_btn.hint_tooltip, "Two different components must be selected for a binary (i.e. boolean) operation.")

	# Set the second object option button to the other object
	Common.set_option_btn_by_text(second_object_opt, "box2")
	second_object_opt.emit_signal("item_selected", 0)
	assert_eq(error_btn.get_parent().visible, false)

	# Make sure the combined name is correct
	assert_eq(tag_name_txt.get_text(), "box1_box2", "Make sure that the resulting tag name is correct.")

	# Simulate a click of the OK button on the Operations dialog
	var ok_btn = popup.get_node("VBoxContainer/OkButton")
	ok_btn.emit_signal("button_down")
	print(popup.original_context)

	# See if the results in the 3D viewport have changed appropriately
	gui._render_history_tree()
	assert_eq(vp.get_child_count(), 52)

	union_control.free()
	threed_btn.free()
	popup.free()
	gui.free()


"""
Simulates as if the user was working with the Cut control.
"""
func test_cut_control():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	var popup = gui.get_node("ActionPopupPanel")

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	Common.set_option_btn_by_text(action_btn, "Boolean - Cut (cut)")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "Boolean - Cut (cut)")
	action_btn.emit_signal("item_selected", 0)

	# Get a reference to the control that has been loaded
	var cut_control = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer").get_children()[0]
	assert_not_null(cut_control, "Make sure we got a valid reference to the cut control.")

	# Set the control up like it has been used
	popup.original_context = '# Semblage v0.2\nimport cadquery as cq\nbox1=cq.Workplane().tag("box1").box(10,10,10)\nbox2=.Workplane().tag("box2").center(5, 5).box(10,10,10)'
	gui.components["box1"] = ['.Workplane().tag("box1")', '.box(10,10,10)']
	gui.components["box2"] = ['.Workplane().tag("box2")', '.center(5, 5)', '.box(10,10,10)']

	# Initialize the trees
	gui._init_object_tree()
	gui._init_history_tree()
	gui._init_params_tree()

	# Fake out the 2D operation action tree
	var action_tree = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/ActionTree")
	var action_tree_root = action_tree.create_item()

	cut_control._ready()

	# Render the object in the 3D viewport
	gui._render_history_tree()

	# Get the viewport so we can make sure it has contents
	var vp = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	assert_eq(vp.get_child_count(), 28)

	# Get references to the controls on the form
	var first_object_opt = cut_control.get_node("first_obj_group/first_object_opt")
	assert_not_null(first_object_opt, "Make sure we got a valid reference to the first object option button.")
	var second_object_opt = cut_control.get_node("second_obj_group/second_object_opt")
	assert_not_null(second_object_opt, "Make sure we got a valid reference to the second object option button.")
	var tag_name_txt = cut_control.get_node("tag_name_group/tag_name_txt")

	# Make sure all of the controls have the correct default values in them
	assert_eq(first_object_opt.get_item_text(first_object_opt.get_selected_id()), "box1", "Make sure the first object control has the correct default value.")
	assert_eq(second_object_opt.get_item_text(second_object_opt.get_selected_id()), "box1", "Make sure the second object control has the correct default value.")

	# Make sure that the error button is visible and has the correct tooltip
	var error_btn = cut_control.get_node("error_btn_group/error_btn")
	assert_eq(error_btn.hint_tooltip, "Two different components must be selected for a binary (i.e. boolean) operation.")

	# Set the second object option button to the other object
	Common.set_option_btn_by_text(second_object_opt, "box2")
	second_object_opt.emit_signal("item_selected", 0)
	assert_eq(error_btn.get_parent().visible, false)

	# Make sure the combined name is correct
	assert_eq(tag_name_txt.get_text(), "box1_box2", "Make sure that the resulting tag name is correct.")

	# Simulate a click of the OK button on the Operations dialog
	var ok_btn = popup.get_node("VBoxContainer/OkButton")
	ok_btn.emit_signal("button_down")
	print(popup.original_context)

	# See if the results in the 3D viewport have changed appropriately
	gui._render_history_tree()
	assert_eq(vp.get_child_count(), 40)

	cut_control.free()
	threed_btn.free()
	popup.free()
	gui.free()


"""
Simulates as if the user was working with the Intersect control.
"""
func test_intersect_control():
	# Get a reference to the whole interface and make sure we got it
	var gui = partial_double("res://GUI.tscn").instance()
	var popup = gui.get_node("ActionPopupPanel")

	# Simulate a click of the workplane button
	var threed_btn = popup.get_node("VBoxContainer/ActionGroupsVBoxContainer/HBoxContainer/ThreeDButton")
	threed_btn.pressed = true
	threed_btn.emit_signal("toggled", threed_btn)

	# Check to make sure the ActionOptionButton shows the correct default selection
	var action_btn = popup.get_node("VBoxContainer/ActionOptionButton")
	Common.set_option_btn_by_text(action_btn, "Boolean - Intersect (intersect)")
	assert_eq(action_btn.get_item_text(action_btn.get_selected_id()), "Boolean - Intersect (intersect)")
	action_btn.emit_signal("item_selected", 0)

	# Get a reference to the control that has been loaded
	var intersect_control = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/DynamicContainer").get_children()[0]
	assert_not_null(intersect_control, "Make sure we got a valid reference to the intersect control.")

	# Set the control up like it has been used
	popup.original_context = '# Semblage v0.2\nimport cadquery as cq\nbox1=cq.Workplane().tag("box1").box(10,10,10)\nbox2=.Workplane().tag("box2").center(5, 5).box(10,10,10)'
	gui.components["box1"] = ['.Workplane().tag("box1")', '.box(10,10,10)']
	gui.components["box2"] = ['.Workplane().tag("box2")', '.center(5, 5)', '.box(10,10,10)']

	# Initialize the trees
	gui._init_object_tree()
	gui._init_history_tree()
	gui._init_params_tree()

	# Fake out the 2D operation action tree
	var action_tree = popup.get_node("VBoxContainer/HBoxContainer/ActionContainer/ActionTree")
	var action_tree_root = action_tree.create_item()

	intersect_control._ready()

	# Render the object in the 3D viewport
	gui._render_history_tree()

	# Get the viewport so we can make sure it has contents
	var vp = gui.get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	assert_eq(vp.get_child_count(), 28)

	# Get references to the controls on the form
	var first_object_opt = intersect_control.get_node("first_obj_group/first_object_opt")
	assert_not_null(first_object_opt, "Make sure we got a valid reference to the first object option button.")
	var second_object_opt = intersect_control.get_node("second_obj_group/second_object_opt")
	assert_not_null(second_object_opt, "Make sure we got a valid reference to the second object option button.")
	var tag_name_txt = intersect_control.get_node("tag_name_group/tag_name_txt")

	# Make sure all of the controls have the correct default values in them
	assert_eq(first_object_opt.get_item_text(first_object_opt.get_selected_id()), "box1", "Make sure the first object control has the correct default value.")
	assert_eq(second_object_opt.get_item_text(second_object_opt.get_selected_id()), "box1", "Make sure the second object control has the correct default value.")

	# Make sure that the error button is visible and has the correct tooltip
	var error_btn = intersect_control.get_node("error_btn_group/error_btn")
	assert_eq(error_btn.hint_tooltip, "Two different components must be selected for a binary (i.e. boolean) operation.")

	# Set the second object option button to the other object
	Common.set_option_btn_by_text(second_object_opt, "box2")
	second_object_opt.emit_signal("item_selected", 0)
	assert_eq(error_btn.get_parent().visible, false)

	# Make sure the combined name is correct
	assert_eq(tag_name_txt.get_text(), "box1_box2", "Make sure that the resulting tag name is correct.")

	# Simulate a click of the OK button on the Operations dialog
	var ok_btn = popup.get_node("VBoxContainer/OkButton")
	ok_btn.emit_signal("button_down")
	print(popup.original_context)

	# See if the results in the 3D viewport have changed appropriately
	gui._render_history_tree()
	assert_eq(vp.get_child_count(), 28)

	intersect_control.free()
	threed_btn.free()
	popup.free()
	gui.free()
