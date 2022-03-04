extends VBoxContainer

class_name ExistingComponentControl

var template = ""

var prev_template = null


"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	# Set up the controls
	var lbl_ctrl = Label.new()
	lbl_ctrl.set_text("Components in Current Directory")
	add_child(lbl_ctrl)
	var comp_list_ctrl = Tree.new()
	comp_list_ctrl.name = "comp_list_ctrl"
	comp_list_ctrl.hide_root = true
	comp_list_ctrl.rect_min_size = Vector2(220, 200)
	var tree_root = comp_list_ctrl.create_item()
	add_child(comp_list_ctrl)

	# Add the translation control
	var translate_lbl = Label.new()
	translate_lbl.set_text("Translation")
	add_child(translate_lbl)
	var translate_ctrl = TranslateControl.new()
	translate_ctrl.name = "translate_ctrl"
	add_child(translate_ctrl)

	# Add the rotation control
	var rotate_lbl = Label.new()
	rotate_lbl.set_text("Rotation")
	add_child(rotate_lbl)
	var rotate_ctrl = RotateAboutCenterControl.new()
	rotate_ctrl.name = "rotate_ctrl"
	add_child(rotate_ctrl)

	# Get the directory holding the current component's file
	var par = self.find_parent('Control')
	if not par.open_file_path:
		return
	var path_parts = par.open_file_path.split("/")
	var path_str = par.open_file_path.replace(path_parts[-1], "")

	# Search for mods within the open component's directory and add them to the tree
	var mods = discovery.discover(path_str)
	for mod in mods:
		var cur_item = null

		# Step through the period delimited package-module structure and nest it within the tree
		var mod_parts = mod.split(".")
		for mod_part in mod_parts:
			cur_item = comp_list_ctrl.create_item(cur_item)
			cur_item.set_text(0, mod_part)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""
	var translate_ctrl = get_node("translate_ctrl")
	var rotate_ctrl = get_node("rotate_ctrl")

	var comp_list_ctrl = get_node("comp_list_ctrl")
	var selected = comp_list_ctrl.get_selected()

	# Build an import line based on what was selected in the tree
	var parent_str = ""
	if selected.get_parent():
		parent_str = selected.get_parent().get_text(0)
	if selected.get_parent().get_parent():
		parent_str = "(ext) from " + selected.get_parent().get_parent().get_text(0) + "." + parent_str + " import " + selected.get_text(0) + "\n"

	complete = parent_str

	var comp_name = selected.get_text(0).replace("build_", "")

	# Add the build definition
	complete += comp_name + "=" + selected.get_text(0) + "()\n"

	# Add the translation and rotation components
	complete += translate_ctrl.get_completed_template() + "\n"
	complete += rotate_ctrl.get_completed_template()

	return complete


"""
When in edit mode, returns the previous template string that needs to
be replaced.
"""
func get_previous_template():
	return prev_template


"""
Loads values into the control's sub-controls based on a code string.
"""
func set_values_from_string(text_line):
	prev_template = text_line

	var rgx = RegEx.new()
