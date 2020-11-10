extends PopupPanel

var ContextHandler = load("res://ContextHandler.gd")

var action_type = "None"
var context_handler # Handles the situation where the context Action menu needs to be populated

"""
Called to prepare the popup to be viewed by the user, complete with controls
appropriate to the Action(s) that can be taken next.
"""
func activate_popup(mouse_pos, context):
	# Instantiate the context handler which tells us what type of Action we are dealing with
	context_handler = ContextHandler.new()

	# Figure out what type of Action we are dealing with
	action_type = context_handler.get_action_from_context(context)

	# Locate the popup at the mouse position and make it a minimum size to be resized later
	popup(Rect2(mouse_pos[0], mouse_pos[1], 1.0, 1.0))
	
	# Make way for the new controls
	clear_popup()

	# Populate the popup appropriately based on what the Action is
	if action_type == "new_workplane":
		populate_workplane_controls()
	else:
		print("Unknown Action type")

	# Make sure the panel is the correct size to contain all controls
	rect_size = get_node("VBoxContainer").rect_size

"""
Clears the previous dynamic controls from this popup.
"""
func clear_popup():
	# We only want to remove the contents of the dynamic VBoxContainer
	var par = get_node("VBoxContainer/PVBoxContainer")

	# Clear the previous items from the popup
	var children = par.get_children()
	for child in children:
		par.remove_child(child)

"""
Handles adding the sub-controls to the main control for the workplane settings.
"""
func populate_workplane_controls():
	# Let the user know what Action is currently selected
	self.get_node("VBoxContainer/ActionLabel").set_text("New Workplane")

	# Workplane name option button
	var wp_orientation = OptionButton.new()
	wp_orientation.set_text("Workplane")
	wp_orientation.add_item("XY")
	wp_orientation.add_item("XZ")
	wp_orientation.add_item("YZ")
	get_node("VBoxContainer/PVBoxContainer").add_child(wp_orientation)

	# Whether the normal of the plan is normal or goes the opposite direction
	var invert_normal = CheckBox.new()
	invert_normal.set_text("Invert")
	get_node("VBoxContainer/PVBoxContainer").add_child(invert_normal)

	# Origin location section label
	var origin_loc_lbl = Label.new()
	origin_loc_lbl.set_text("Origin Location")
	get_node("VBoxContainer/PVBoxContainer").add_child(origin_loc_lbl)

	# Add the origin location controls
	var origin_cont = HBoxContainer.new()
	var x_lbl = Label.new()
	x_lbl.set_text("X")
	var x_txt = LineEdit.new()
	x_txt.text = "0"
	origin_cont.add_child(x_lbl)
	origin_cont.add_child(x_txt)
	var y_lbl = Label.new()
	y_lbl.set_text("Y")
	var y_txt = LineEdit.new()
	y_txt.text = "0"
	origin_cont.add_child(y_lbl)
	origin_cont.add_child(y_txt)
	var z_lbl = Label.new()
	z_lbl.set_text("Z")
	var z_txt = LineEdit.new()
	z_txt.text = "0"
	origin_cont.add_child(z_lbl)
	origin_cont.add_child(z_txt)

	# Add the origin location controls to the popup
	get_node("VBoxContainer/PVBoxContainer").add_child(origin_cont)

	# Origin location section label
	var normal_dir_lbl = Label.new()
	normal_dir_lbl.set_text("Normal Direction")
	get_node("VBoxContainer/PVBoxContainer").add_child(normal_dir_lbl)

	# Add the origin location controls
	var normal_cont = HBoxContainer.new()
	var x_dir_lbl = Label.new()
	x_dir_lbl.set_text("X")
	var x_dir_txt = LineEdit.new()
	x_dir_txt.text = "0"
	normal_cont.add_child(x_dir_lbl)
	normal_cont.add_child(x_dir_txt)
	var y_dir_lbl = Label.new()
	y_dir_lbl.set_text("Y")
	var y_dir_txt = LineEdit.new()
	y_dir_txt.text = "0"
	normal_cont.add_child(y_dir_lbl)
	normal_cont.add_child(y_dir_txt)
	var z_dir_lbl = Label.new()
	z_dir_lbl.set_text("Z")
	var z_dir_txt = LineEdit.new()
	z_dir_txt.text = "1"
	normal_cont.add_child(z_dir_lbl)
	normal_cont.add_child(z_dir_txt)

	# Add the normal direction controls to the popup
	get_node("VBoxContainer/PVBoxContainer").add_child(normal_cont)

"""
Tells the caller what type of Action this popup thinks it is dealing with.
"""
func get_action_type():
	return action_type

func get_action_args():
	return {}
