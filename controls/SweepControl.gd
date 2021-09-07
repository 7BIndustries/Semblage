extends VBoxContainer

# signal error

class_name SweepControl

var prev_template = null

var template = "{profile}.sweep({path},multisection={multisection},sweepAlongWires={sweep_along_wires},makeSolid={make_solid},isFrenet={is_frenet},combine={combine},clean={clean},transition=\"{transition}\",normal={normal},auxSpine={aux_spine}).tag(\"{comp_name}\")"

const profile_edit_rgx = "(?<=^)(.*?)(?=\\.sweep)"
const path_edit_rgx = "(?<=.sweep\\()(.*?)(?=,multisection)"
const multisection_edit_rgx = "(?<=multisection\\=)(.*?)(?=,sweepAlongWires)"
const sweep_along_wires_edit_rgx = "(?<=sweepAlongWires\\=)(.*?)(?=,makeSolid)"
const make_solid_edit_rgx = "(?<=makeSolid\\=)(.*?)(?=,isFrenet)"
const is_frenet_edit_rgx = "(?<=isFrenet\\=)(.*?)(?=,combine)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=,transition)"
const transition_edit_rgx = "(?<=transition\\=\")(.*?)(?=\",normal)"
const normal_edit_rgx = "(?<=normal\\=)(.*?)(?=,auxSpine)"
const aux_spine_edit_rgx = "(?<=auxSpine\\=)(.*?)(?=\\))"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

var valid = false
var transition_options = ["right", "round", "transformed"]

"""
Called when the node enters the scene tree.
"""
func _ready():
	# Control to set the profile to be swept
	var profile_group = VBoxContainer.new()
	profile_group.name = "profile_group"
	# Profile label
	var profile_lbl = Label.new()
	profile_lbl.set_text("Profile")
	profile_group.add_child(profile_lbl)
	# Profile option control
	var profile_opt = OptionButton.new()
	profile_opt.name = "profile_opt"
	profile_opt.hint_tooltip = tr("PROFILE_OPT_HINT_TOOLTIP")
	profile_opt.connect("item_selected", self, "_on_profile_opt_item_selected")
	profile_group.add_child(profile_opt)

	# Control to set the path to be swept
	var path_group = VBoxContainer.new()
	path_group.name = "path_group"
	# Path label
	var path_lbl = Label.new()
	path_lbl.set_text("Path")
	path_group.add_child(path_lbl)
	# Path option control
	var path_opt = OptionButton.new()
	path_opt.name = "path_opt"
	path_opt.hint_tooltip = tr("PATH_OPT_HINT_TOOLTIP")
	path_opt.connect("item_selected", self, "_on_path_opt_item_selected")
	path_group.add_child(path_opt)

	# Control to set the tag name of the resulting object
	var tag_name_group = VBoxContainer.new()
	tag_name_group.name = "tag_name_group"
	# Tag name label
	var tag_name_lbl = Label.new()
	tag_name_lbl.set_text("New Component Name")
	tag_name_group.add_child(tag_name_lbl)
	# Tag name input text
	var tag_name_txt = LineEdit.new()
	tag_name_txt.name = "tag_name_txt"
	tag_name_txt.hint_tooltip = tr("WP_NAME_CTRL_HINT_TOOLTIP")
	tag_name_group.add_child(tag_name_txt)

	# Multisection checkbox
	var multisection_group = HBoxContainer.new()
	multisection_group.name = "multisection_group"
	var multisection_lbl = Label.new()
	multisection_lbl.set_text("Multisection: ")
	multisection_group.add_child(multisection_lbl)
	var multisection_ctrl = CheckBox.new()
	multisection_ctrl.name = "multisection_ctrl"
	multisection_ctrl.pressed = false
	multisection_ctrl.hint_tooltip = tr("MULTISECTION_HINT_TOOLTIP")
	multisection_group.add_child(multisection_ctrl)

	# Sweep along wires checkbox
	var sweep_along_wires_group = HBoxContainer.new()
	sweep_along_wires_group.name = "sweep_along_wires_group"
	var sweep_along_wires_lbl = Label.new()
	sweep_along_wires_lbl.set_text("Sweep Along Wires: ")
	sweep_along_wires_group.add_child(sweep_along_wires_lbl)
	var sweep_along_wires_ctrl = CheckBox.new()
	sweep_along_wires_ctrl.name = "sweep_along_wires_ctrl"
	sweep_along_wires_ctrl.pressed = false
	sweep_along_wires_ctrl.hint_tooltip = tr("SWEEP_ALONG_WIRES_HINT_TOOLTIP")
	sweep_along_wires_group.add_child(sweep_along_wires_ctrl)

	# Make solid checkbox
	var make_solid_group = HBoxContainer.new()
	make_solid_group.name = "make_solid_group"
	var make_solid_lbl = Label.new()
	make_solid_lbl.set_text("Make Solid: ")
	make_solid_group.add_child(make_solid_lbl)
	var make_solid_ctrl = CheckBox.new()
	make_solid_ctrl.name = "make_solid_ctrl"
	make_solid_ctrl.pressed = true
	make_solid_ctrl.hint_tooltip = tr("MAKE_SOLID_HINT_TOOLTIP")
	make_solid_group.add_child(make_solid_ctrl)

	# Is Frenet checkbox
	var is_frenet_group = HBoxContainer.new()
	is_frenet_group.name = "is_frenet_group"
	var is_frenet_lbl = Label.new()
	is_frenet_lbl.set_text("Is Frenet: ")
	is_frenet_group.add_child(is_frenet_lbl)
	var is_frenet_ctrl = CheckBox.new()
	is_frenet_ctrl.name = "is_frenet_ctrl"
	is_frenet_ctrl.pressed = false
	is_frenet_ctrl.hint_tooltip = tr("IS_FRENET_HINT_TOOLTIP")
	is_frenet_group.add_child(is_frenet_ctrl)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	combine_group.name = "combine_group"
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	var combine_ctrl = CheckBox.new()
	combine_ctrl.name = "combine_ctrl"
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	clean_group.name = "clean_group"
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	var clean_ctrl = CheckBox.new()
	clean_ctrl.name = "clean_ctrl"
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)

	# Option button to set the transition style
	var transition_group = VBoxContainer.new()
	transition_group.name = "transition_group"
	# Profile label
	var transition_lbl = Label.new()
	transition_lbl.set_text("Transition")
	transition_group.add_child(transition_lbl)
	# Profile option control
	var transition_opt = OptionButton.new()
	transition_opt.name = "transition_opt"
	transition_opt.hint_tooltip = tr("TRANSITION_OPT_HINT_TOOLTIP")
	Common.load_option_button(transition_opt, transition_options)
	transition_group.add_child(transition_opt)

	# Normal controls
	var normal_group_enclose = VBoxContainer.new()
	normal_group_enclose.name = "normal_group_enclose"

	# Normal group label
	var normal_lbl = Label.new()
	normal_lbl.set_text("Normal")
	normal_group_enclose.add_child(normal_lbl)

	# Checkbox to make the normal None
	var none_cbx = CheckBox.new()
	none_cbx.set_text("None")
	none_cbx.name = "none_cbx"
	none_cbx.pressed = true
	none_cbx.connect("toggled", self, "_on_none_cbx_toggled")
	normal_group_enclose.add_child(none_cbx)

	var normal_group = HBoxContainer.new()
	normal_group.name = "normal_group"
	# Normal X
	var norm_x_lbl = Label.new()
	norm_x_lbl.set_text("X: ")
	normal_group.add_child(norm_x_lbl)
	var normal_x_ctrl = NumberEdit.new()
	normal_x_ctrl.name = "normal_x_ctrl"
	normal_x_ctrl.set_text("0")
	normal_x_ctrl.hint_tooltip = tr("WP_NORMAL_X_CTRL_HINT_TOOLTIP")
	normal_group.add_child(normal_x_ctrl)
	# Normal Y
	var norm_y_lbl = Label.new()
	norm_y_lbl.set_text("Y: ")
	normal_group.add_child(norm_y_lbl)
	var normal_y_ctrl = NumberEdit.new()
	normal_y_ctrl.name = "normal_y_ctrl"
	normal_y_ctrl.set_text("0")
	normal_y_ctrl.hint_tooltip = tr("WP_NORMAL_Y_CTRL_HINT_TOOLTIP")
	normal_group.add_child(normal_y_ctrl)
	# Normal Z
	var norm_z_lbl = Label.new()
	norm_z_lbl.set_text("Z: ")
	normal_group.add_child(norm_z_lbl)
	var normal_z_ctrl = NumberEdit.new()
	normal_z_ctrl.name = "normal_z_ctrl"
	normal_z_ctrl.set_text("0")
	normal_z_ctrl.hint_tooltip = tr("WP_NORMAL_Z_CTRL_HINT_TOOLTIP")
	normal_group.add_child(normal_z_ctrl)
	normal_group.hide()
	normal_group_enclose.add_child(normal_group)

	# Control for the wire defining the binormal along the extrusion path
	var aux_spine_group = VBoxContainer.new()
	aux_spine_group.name = "aux_spine_group"
	# Aux spine label
	var aux_spine_lbl = Label.new()
	aux_spine_lbl.set_text("Aux Spine")
	aux_spine_group.add_child(aux_spine_lbl)
	# Aux spine option control
	var aux_spine_opt = OptionButton.new()
	aux_spine_opt.name = "aux_spine_opt"
	aux_spine_opt.hint_tooltip = tr("AUX_SPINE_OPT_HINT_TOOLTIP")
	aux_spine_group.add_child(aux_spine_opt)

	# Create the button that lets the user know that there is an error on the form
	var error_btn_group = HBoxContainer.new()
	error_btn_group.name = "error_btn_group"
	var error_btn = Button.new()
	error_btn.name = "error_btn"
	error_btn.set_text("!")
	error_btn_group.add_child(error_btn)
	error_btn_group.hide()

	add_child(profile_group)
	add_child(path_group)
	add_child(tag_name_group)
	add_child(multisection_group)
	add_child(sweep_along_wires_group)
	add_child(make_solid_group)
	add_child(is_frenet_group)
	add_child(combine_group)
	add_child(clean_group)
	add_child(transition_group)
	add_child(normal_group_enclose)
	add_child(aux_spine_group)
	add_child(error_btn_group)

	# Pull any component names that already exist in the context
	var comp_names = find_parent("ActionPopupPanel")
	comp_names = comp_names.components

	# Load up both component option buttons with the names of the found components
	Common.load_option_button(profile_opt, comp_names)
	Common.load_option_button(path_opt, comp_names)

	# Add None as an option for the auxiliary spine
	comp_names.insert(0, "None")
	Common.load_option_button(aux_spine_opt, comp_names)

	_validate_form()


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return true

"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	var profile_opt = get_node("profile_group/profile_opt")
	var path_opt = get_node("path_group/path_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var multisection_ctrl = get_node("multisection_group/multisection_ctrl")
	var sweep_along_wires_ctrl = get_node("sweep_along_wires_group/sweep_along_wires_ctrl")
	var make_solid_ctrl = get_node("make_solid_group/make_solid_ctrl")
	var is_frenet_ctrl = get_node("is_frenet_group/is_frenet_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")
	var transition_opt = get_node('transition_group/transition_opt')
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var normal_group = get_node("normal_group_enclose/normal_group")
	var normal_x_ctrl = get_node("normal_group_enclose/normal_group/normal_x_ctrl")
	var normal_y_ctrl = get_node("normal_group_enclose/normal_group/normal_y_ctrl")
	var normal_z_ctrl = get_node("normal_group_enclose/normal_group/normal_z_ctrl")
	var aux_spine_opt = get_node("aux_spine_group/aux_spine_opt")

	# Handle the fact that the aux spline can be None or a quoted component name
	var aux_spine_text = "None"
	if aux_spine_opt.get_item_text(aux_spine_opt.selected) != "None":
		aux_spine_text = "\"" + aux_spine_opt.get_item_text(aux_spine_opt.selected) + "\""

	# Handle the fact that the normal can be None or an actual vector
	var nx = normal_x_ctrl.get_text()
	var ny = normal_y_ctrl.get_text()
	var nz = normal_z_ctrl.get_text()
	var normal_text = "None"
	if normal_group.visible and (nx != "0" or ny != "0" or nz != "0"):
		normal_text = "(" + nx + "," + ny + "," + nz + ")"

	complete = template.format({
		"profile": profile_opt.get_item_text(profile_opt.selected),
		"path": path_opt.get_item_text(path_opt.selected),
		"multisection": multisection_ctrl.pressed,
		"sweep_along_wires": sweep_along_wires_ctrl.pressed,
		"make_solid": make_solid_ctrl.pressed,
		"is_frenet": is_frenet_ctrl.pressed,
		"combine": combine_ctrl.pressed,
		"clean": clean_ctrl.pressed,
		"transition": transition_opt.get_item_text(transition_opt.selected),
		"normal": normal_text,
		"aux_spine": aux_spine_text,
		"comp_name": tag_name_txt.get_text()
	})

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

	var profile_opt = get_node("profile_group/profile_opt")
	var path_opt = get_node("path_group/path_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var multisection_ctrl = get_node("multisection_group/multisection_ctrl")
	var sweep_along_wires_ctrl = get_node("sweep_along_wires_group/sweep_along_wires_ctrl")
	var make_solid_ctrl = get_node("make_solid_group/make_solid_ctrl")
	var is_frenet_ctrl = get_node("is_frenet_group/is_frenet_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")
	var transition_opt = get_node('transition_group/transition_opt')
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var normal_group = get_node("normal_group_enclose/normal_group")
	var none_cbx = get_node("normal_group_enclose/none_cbx")
	var normal_x_ctrl = get_node("normal_group_enclose/normal_group/normal_x_ctrl")
	var normal_y_ctrl = get_node("normal_group_enclose/normal_group/normal_y_ctrl")
	var normal_z_ctrl = get_node("normal_group_enclose/normal_group/normal_z_ctrl")
	var aux_spine_opt = get_node("aux_spine_group/aux_spine_opt")

	var rgx = RegEx.new()

	# Profile component
	rgx.compile(profile_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(profile_opt, res.get_string())

	# Path component
	rgx.compile(path_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(path_opt, res.get_string())

	# Tag/component name
	rgx.compile(tag_edit_rgx)
	res = rgx.search(text_line)
	if res:
		tag_name_txt.set_text(res.get_string())

	# Multisection checkbox
	rgx.compile(multisection_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var multi = res.get_string()
		multisection_ctrl.pressed = true if multi == "True" else false

	# Sweep along wires checkbox
	rgx.compile(sweep_along_wires_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var along = res.get_string()
		sweep_along_wires_ctrl.pressed = true if along == "True" else false

	# Make solid
	rgx.compile(make_solid_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var solid = res.get_string()
		make_solid_ctrl.pressed = true if solid == "True" else false

	# Is frenet
	rgx.compile(is_frenet_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var frenet = res.get_string()
		is_frenet_ctrl.pressed = true if frenet == "True" else false

	# Combine
	rgx.compile(combine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var combine = res.get_string()
		combine_ctrl.pressed = true if combine == "True" else false

	# Transition type
	rgx.compile(transition_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(transition_opt, res.get_string())

	# Clean checkbox
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false

	# Normal values
	rgx.compile(normal_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var norm = res.get_string()
		# If the text is None, we do not want to show the normal controls
		if norm == "None":
			none_cbx.pressed = true
			normal_group.hide()
		# Break out the X, Y and Z parts of the normal into their controls
		else:
			var parts = norm.split("(")[1].split(")")[0].split(",")
			normal_x_ctrl.set_text(parts[0])
			normal_y_ctrl.set_text(parts[1])
			normal_z_ctrl.set_text(parts[2])

	# Aux spine
	rgx.compile(aux_spine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(aux_spine_opt, res.get_string())

	# Validate the form and populate the component name
	_validate_form()
	if valid:
		_build_new_name()


"""
Makes sure that the form has the proper data in it.
"""
func _validate_form():
	var profile_opt = get_node("profile_group/profile_opt")
	var path_opt = get_node("path_group/path_opt")
	var error_btn_group = get_node("error_btn_group")
	var error_btn = get_node("error_btn_group/error_btn")

	# Start with the error button hidden
	error_btn_group.hide()

	# There must be at least two objects for a boolean operation to work
	if profile_opt.get_item_count() <= 1 and path_opt.get_item_count() <= 1:
		error_btn_group.show()
		error_btn.hint_tooltip = tr("BINARY_OP_ERROR_TWO_COMPONENTS")
		valid = false
	# The first and second objects cannot be the same
	elif profile_opt.get_item_text(profile_opt.selected) == path_opt.get_item_text(path_opt.selected):
		error_btn_group.show()
		error_btn.hint_tooltip = tr("BINARY_OP_ERROR_TWO_DIFF_COMPONENTS")
		valid = false
	else:
		valid = true


"""
Combines the names of the profile and path objects into a new name
that will not collide with the existing component names.
"""
func _build_new_name():
	# If the form is valid we should be able to construct the new component name
	if valid:
		var tag_name_txt = get_node("tag_name_group/tag_name_txt")
		var profile_opt = get_node("profile_group/profile_opt")
		var path_opt = get_node("path_group/path_opt")

		# Set the new component name to the combination of both components that are being unioned
		var profile = profile_opt.get_item_text(profile_opt.selected)
		var path = path_opt.get_item_text(path_opt.selected)

		tag_name_txt.set_text(profile + "_" + path)


"""
Tells the Operations dialog if this form contains valid data.
"""
func is_valid():
	return valid


"""
Handles pulling the control information together to tell which items
have been combined in the boolean operation.
"""
func get_combine_map():
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var profile_opt = get_node("profile_group/profile_opt")
	var path_opt = get_node("path_group/path_opt")

	# Set the new component name to the combination of both components that are being unioned
	var profile_text = profile_opt.get_item_text(profile_opt.selected)
	var path_text = path_opt.get_item_text(path_opt.selected)

	# A new dictionary with the new combined object name as the key
	var map = { tag_name_txt.get_text(): [profile_text, path_text] }

	return map


"""
Called when the user selects a profile from the option button.
"""
func _on_profile_opt_item_selected(_index):
	_validate_form()

	# Populate the new component name with a combination of both component names
	_build_new_name()


"""
Called when the user selects a path from the option button.
"""
func _on_path_opt_item_selected(_index):
	_validate_form()

	# Populate the new component name with a combination of both component names
	_build_new_name()


"""
Called when the None Normal checkbox is clicked.
"""
func _on_none_cbx_toggled(is_pressed):
	var normal_group = get_node("normal_group_enclose/normal_group")

	# Use the state of the checkbox to set the normal control visibility
	if is_pressed:
		normal_group.hide()
	else:
		normal_group.show()
