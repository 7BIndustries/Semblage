extends VBoxContainer

class_name AssemblyPartControl

signal error

var prev_template = null

var template = ".add(obj={component},name={name},loc={loc},color={color})"

# Regexes used to load controls from the code string
const obj_edit_rgx = "(?<=obj\\=)(.*?)(?=\\,name)"
const name_edit_rgx = "(?<=name\\=\")(.*?)(?=\"\\,loc)"
const loc_edit_rgx = "(?<=loc\\=\\()(.*?)(?=\\)\\,color)"
const color_edit_rgx = "(?<=color\\=cq\\.Color\\()(.*?)(?=\\))"

"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	# Allow the user to set the component to add to the assembly
	var obj_group = HBoxContainer.new()
	obj_group.name = "obj_group"
	var assy_obj_lbl = Label.new()
	assy_obj_lbl.set_text("Component: ")
	obj_group.add_child(assy_obj_lbl)
	var assy_comp_ctrl = OptionButton.new()
	assy_comp_ctrl.name = "assy_comp_ctrl"
	assy_comp_ctrl.size_flags_horizontal = 3
	assy_comp_ctrl.add_item("None")
	assy_comp_ctrl.add_item("New")
	assy_comp_ctrl.connect("item_selected", self, "_on_component_changed")
	assy_comp_ctrl.hint_tooltip = tr("ASSY_COMPONENT_CTRL_HINT_TOOLTIP")
	obj_group.add_child(assy_comp_ctrl)
	add_child(obj_group)

	# Allow the user to give the Workplane/component a name
	var name_group = HBoxContainer.new()
	name_group.name = "name_group"
	var assy_name_lbl = Label.new()
	assy_name_lbl.set_text("Name: ")
	name_group.add_child(assy_name_lbl)
	var assy_name_ctrl = WPNameEdit.new()
	assy_name_ctrl.name = "assy_name_ctrl"
	assy_name_ctrl.size_flags_horizontal = 3
	assy_name_ctrl.editable = false
	assy_name_ctrl.set_text("change_me")
	assy_name_ctrl.hint_tooltip = tr("WP_NAME_CTRL_HINT_TOOLTIP")
	name_group.add_child(assy_name_ctrl)
	add_child(name_group)

	# Add a label for this location group
	var loc_lbl = Label.new()
	loc_lbl.set_text("Location")
	add_child(loc_lbl)

	# Add a control for each part of the location
	var loc_group = HBoxContainer.new()
	loc_group.name = "loc_group"
	# X Control
	var loc_x_lbl = Label.new()
	loc_x_lbl.set_text("X: ")
	loc_group.add_child(loc_x_lbl)
	var loc_x_ctrl = NumberEdit.new()
	loc_x_ctrl.size_flags_horizontal = 3
	loc_x_ctrl.name = "loc_x_ctrl"
	loc_x_ctrl.CanBeNegative = true
	loc_x_ctrl.CanBeAVariable = true
	loc_x_ctrl.set_text("0.0")
	loc_x_ctrl.hint_tooltip = tr("LOCATION_X_CTRL_HINT_TOOLTIP")
	loc_group.add_child(loc_x_ctrl)
	# Y Control
	var loc_y_lbl = Label.new()
	loc_y_lbl.set_text("Y: ")
	loc_group.add_child(loc_y_lbl)
	var loc_y_ctrl = NumberEdit.new()
	loc_y_ctrl.size_flags_horizontal = 3
	loc_y_ctrl.name = "loc_y_ctrl"
	loc_y_ctrl.CanBeNegative = true
	loc_y_ctrl.CanBeAVariable = true
	loc_y_ctrl.set_text("0.0")
	loc_y_ctrl.hint_tooltip = tr("LOCATION_Y_CTRL_HINT_TOOLTIP")
	loc_group.add_child(loc_y_ctrl)
	add_child(loc_group)
	# Z Control
	var loc_z_lbl = Label.new()
	loc_z_lbl.set_text("Z: ")
	loc_group.add_child(loc_z_lbl)
	var loc_z_ctrl = NumberEdit.new()
	loc_z_ctrl.size_flags_horizontal = 3
	loc_z_ctrl.name = "loc_z_ctrl"
	loc_z_ctrl.CanBeNegative = true
	loc_z_ctrl.CanBeAVariable = true
	loc_z_ctrl.set_text("0.0")
	loc_z_ctrl.hint_tooltip = tr("LOCATION_Z_CTRL_HINT_TOOLTIP")
	loc_group.add_child(loc_z_ctrl)
	add_child(loc_group)

	# Allow the user to set the color for the assembly
	var color_group = HBoxContainer.new()
	color_group.name = "color_group"
	var assy_color_lbl = Label.new()
	assy_color_lbl.set_text("Color")
	color_group.add_child(assy_color_lbl)
	add_child(color_group)

	# Add a control for each part of the location
	var color_comps_group = HBoxContainer.new()
	color_comps_group.name = "color_comps_group"

	# Color picker button
	var color_btn = Button.new()
	# Load the button icon into an image so we can resize it
	var image = Image.new()
	image.load("res://assets/icons/color_button_flat_ready.svg")
	image.resize(20, 20)
	var icon = ImageTexture.new()
	icon.create_from_image(image)
	color_btn.icon = icon
	color_btn.connect("button_down", self, '_on_color_button_pressed')
	color_comps_group.add_child(color_btn)
	# R (red) Control
	var color_r_lbl = Label.new()
	color_r_lbl.set_text("R: ")
	color_comps_group.add_child(color_r_lbl)
	var color_r_ctrl = NumberEdit.new()
	color_r_ctrl.size_flags_horizontal = 3
	color_r_ctrl.name = "color_r_ctrl"
	color_r_ctrl.CanBeNegative = false
	color_r_ctrl.CanBeAVariable = true
	color_r_ctrl.MaxValue = 1.0
	color_r_ctrl.set_text("0.0")
	color_r_ctrl.hint_tooltip = tr("COLOR_R_CTRL_HINT_TOOLTIP")
	color_comps_group.add_child(color_r_ctrl)
	# G (green) Control
	var color_g_lbl = Label.new()
	color_g_lbl.set_text("G: ")
	color_comps_group.add_child(color_g_lbl)
	var color_g_ctrl = NumberEdit.new()
	color_g_ctrl.size_flags_horizontal = 3
	color_g_ctrl.name = "color_g_ctrl"
	color_g_ctrl.CanBeNegative = false
	color_g_ctrl.CanBeAVariable = true
	color_g_ctrl.MaxValue = 1.0
	color_g_ctrl.set_text("0.0")
	color_g_ctrl.hint_tooltip = tr("COLOR_G_CTRL_HINT_TOOLTIP")
	color_comps_group.add_child(color_g_ctrl)
	# B (blue) Control
	var color_b_lbl = Label.new()
	color_b_lbl.set_text("B: ")
	color_comps_group.add_child(color_b_lbl)
	var color_b_ctrl = NumberEdit.new()
	color_b_ctrl.size_flags_horizontal = 3
	color_b_ctrl.name = "color_b_ctrl"
	color_b_ctrl.CanBeNegative = false
	color_b_ctrl.CanBeAVariable = true
	color_b_ctrl.MaxValue = 1.0
	color_b_ctrl.set_text("0.0")
	color_b_ctrl.hint_tooltip = tr("COLOR_G_CTRL_HINT_TOOLTIP")
	color_comps_group.add_child(color_b_ctrl)
	# A (alpha) Control
	var color_a_lbl = Label.new()
	color_a_lbl.set_text("A: ")
	color_comps_group.add_child(color_a_lbl)
	var color_a_ctrl = NumberEdit.new()
	color_a_ctrl.size_flags_horizontal = 3
	color_a_ctrl.name = "color_a_ctrl"
	color_a_ctrl.CanBeNegative = false
	color_a_ctrl.CanBeAVariable = true
	color_a_ctrl.MaxValue = 1.0
	color_a_ctrl.set_text("0.0")
	color_a_ctrl.hint_tooltip = tr("COLOR_A_CTRL_HINT_TOOLTIP")
	color_comps_group.add_child(color_a_ctrl)

	add_child(color_comps_group)

	# Get the directory holding the current component's file
	var tlp = self.find_parent('Control')
	if not tlp.open_file_path:
		return
	var path_parts = tlp.open_file_path.split("/")
	var path_str = tlp.open_file_path.replace(path_parts[-1], "")

	# Fill the components drop down with any components that are in the assembly directory
	var mods = discovery.discover(path_str)
	for mod in mods:
		var cur_item = null

		# Step through the period delimited package-module structure and nest it within the tree
		var mod_parts = mod.split(".")
		for mod_part in mod_parts:
			assy_comp_ctrl.add_item(cur_item)


"""
Called when a user selects a color from the color picker dialog.
"""
func _on_color_chosen(picked_color):
	var color_r_ctrl = get_node("color_comps_group/color_r_ctrl")
	var color_g_ctrl = get_node("color_comps_group/color_g_ctrl")
	var color_b_ctrl = get_node("color_comps_group/color_b_ctrl")
	var color_a_ctrl = get_node("color_comps_group/color_a_ctrl")

	# Save the new color settings in the rgba Number controls
	color_r_ctrl.set_text(str(picked_color.r))
	color_g_ctrl.set_text(str(picked_color.g))
	color_b_ctrl.set_text(str(picked_color.b))
	color_a_ctrl.set_text(str(picked_color.a))

	print(picked_color)


"""
Called when the user clicks the color picker button.
"""
func _on_color_button_pressed():
	var cp = find_parent("Control").get_node("ColorPickerDialog")
	cp.connect("ok_pressed", self, "_on_color_chosen")

	cp.popup_centered()


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var assy_comp_ctrl = get_node("obj_group/assy_comp_ctrl")
	var assy_name_ctrl = get_node("name_group/assy_name_ctrl")
	var loc_x_ctrl = get_node("loc_group/loc_x_ctrl")
	var loc_y_ctrl = get_node("loc_group/loc_y_ctrl")
	var loc_z_ctrl = get_node("loc_group/loc_z_ctrl")
	var color_r_ctrl = get_node("color_comps_group/color_r_ctrl")
	var color_g_ctrl = get_node("color_comps_group/color_g_ctrl")
	var color_b_ctrl = get_node("color_comps_group/color_b_ctrl")
	var color_a_ctrl = get_node("color_comps_group/color_a_ctrl")

	# Make sure that the user has selected a component
	if assy_comp_ctrl.get_selected_id() == 0:
		return false

	# Make sure all of the numeric controls have valid values
	if not assy_name_ctrl.is_valid:
		return false
	if not loc_x_ctrl.is_valid:
		return false
	if not loc_y_ctrl.is_valid:
		return false
	if not loc_z_ctrl.is_valid:
		return false
	if not color_r_ctrl.is_valid:
		return false
	if not color_g_ctrl.is_valid:
		return false
	if not color_b_ctrl.is_valid:
		return false
	if not color_a_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	var assy_comp_ctrl = get_node("obj_group/assy_comp_ctrl")
	var assy_name_ctrl = get_node("name_group/assy_name_ctrl")
	var loc_x_ctrl = get_node("loc_group/loc_x_ctrl")
	var loc_y_ctrl = get_node("loc_group/loc_y_ctrl")
	var loc_z_ctrl = get_node("loc_group/loc_z_ctrl")
	var color_r_ctrl = get_node("color_comps_group/color_r_ctrl")
	var color_g_ctrl = get_node("color_comps_group/color_g_ctrl")
	var color_b_ctrl = get_node("color_comps_group/color_b_ctrl")
	var color_a_ctrl = get_node("color_comps_group/color_a_ctrl")

	# Assemble the method call for the object
	var component = "build_" + assy_name_ctrl.get_text() + "()"

	# Assemble the name
	var name = "\"" + assy_name_ctrl.get_text() + "\""

	# Assemble the location 3-tuple
	var loc = "(" + loc_x_ctrl.get_text() + "," + loc_y_ctrl.get_text() + "," + loc_y_ctrl.get_text() + ")"

	# Assemble the CadQuery Color object instantiation
	var color = "cq.Color(" + color_r_ctrl.get_text() + "," + color_g_ctrl.get_text() + "," + color_b_ctrl.get_text() + "," + color_a_ctrl.get_text() + ")"

	complete += template.format({
		"component": component,
		"name": name,
		"loc": loc,
		"color": color
	})

	return complete


"""
Loads values into the control's sub-controls based on a code string.
"""
func set_values_from_string(text_line):
	prev_template = text_line

	var rgx = RegEx.new()

	var assy_comp_ctrl = get_node("obj_group/assy_comp_ctrl")
	var assy_name_ctrl = get_node("name_group/assy_name_ctrl")
	var loc_x_ctrl = get_node("loc_group/loc_x_ctrl")
	var loc_y_ctrl = get_node("loc_group/loc_y_ctrl")
	var loc_z_ctrl = get_node("loc_group/loc_z_ctrl")
	var color_r_ctrl = get_node("color_comps_group/color_r_ctrl")
	var color_g_ctrl = get_node("color_comps_group/color_g_ctrl")
	var color_b_ctrl = get_node("color_comps_group/color_b_ctrl")
	var color_a_ctrl = get_node("color_comps_group/color_a_ctrl")

	# Set the assembly component object selection
	rgx.compile(obj_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		var obj_name = res.get_string().replace("build_", "").replace("()", "")

		# The component build method will not be present in the option drop down when editing
		assy_comp_ctrl.add_item(obj_name)
		Common.set_option_btn_by_text(assy_comp_ctrl, obj_name)

	# The workplane name
	rgx.compile(name_edit_rgx)
	res = rgx.search(text_line)
	if res:
		assy_name_ctrl.set_text(res.get_string())

	# Split the location and insert the values in the correct controls
	rgx.compile(loc_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the origin X, Y and Z controls
		var xyz = res.get_string().split(",")
		loc_x_ctrl.set_text(xyz[0])
		loc_y_ctrl.set_text(xyz[1])
		loc_z_ctrl.set_text(xyz[2])

	# Split the color and insert the values in the correct controls
	rgx.compile(color_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the origin X, Y and Z controls
		var xyz = res.get_string().split(",")
		color_r_ctrl.set_text(xyz[0])
		color_g_ctrl.set_text(xyz[1])
		color_b_ctrl.set_text(xyz[2])
		color_a_ctrl.set_text(xyz[3])


"""
Called when the user changes the component selection.
"""
func _on_component_changed(selected_index):
	var assy_comp_ctrl = get_node("obj_group/assy_comp_ctrl")
	var assy_name_ctrl = get_node("name_group/assy_name_ctrl")

	# Unlock the name field if anything other than None is selected
	if selected_index != 0:
		assy_name_ctrl.editable = true

	# Make sure the assembly is saved if the user is trying to add a new component
	if selected_index == 1:
		var par = find_parent("ActionPopupPanel")
		var code = par.new_template

		# If there is no top-level assembly object, something is wrong
		if code == null or not code.begins_with(".Assembly"):
			par._on_error("You must add a top level assembly and save it before adding a component.")
			return

	print(assy_comp_ctrl.get_item_text(selected_index))
