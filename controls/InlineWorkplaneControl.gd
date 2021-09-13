extends VBoxContainer

class_name InlineWorkplaneControl

var template = '.workplane(offset={offset},invert={invert},centerOption="{center_option}",origin=({origin_x},{origin_y},{origin_z}))'

var prev_template = null

const center_option_list = ["CenterOfBoundBox", "CenterOfMass", "ProjectedOrigin"]

const offset_edit_rgx = "(?<=offset\\=)(.*?)(?=,invert)"
const invert_edit_rgx = "(?<=invert\\=)(.*?)(?=,centerOption)"
const wp_cen_edit_rgx = "(?<=centerOption\\=\")(.*?)(?=\",origin)"
const origin_edit_rgx = "(?<=origin\\=\\()(.*?)(?=\\))"


"""
Called when the node enters the scene tree.
"""
func _ready():
	# Set up the control for the workplane offset
	var offset_group = HBoxContainer.new()
	var offset_lbl = Label.new()
	offset_lbl.set_text("Offset: ")
	offset_group.name = "offset_group"
	offset_group.add_child(offset_lbl)
	var offset_ctrl = NumberEdit.new()
	offset_ctrl.size_flags_horizontal = 3
	offset_ctrl.CanBeAVariable = true
	offset_ctrl.CanBeNegative = true
	offset_ctrl.set_text("0.0")
	offset_ctrl.hint_tooltip = tr("WP_OFFSET_CTRL")
	offset_ctrl.name = "offset_ctrl"
	offset_group.add_child(offset_ctrl)

	# Allow the user to set whether the workplane normal is inverted
	var invert_group = HBoxContainer.new()
	invert_group.name = "invert_group"
	var invert_lbl = Label.new()
	invert_lbl.set_text("Invert: ")
	invert_group.add_child(invert_lbl)
	var invert_ctrl = CheckBox.new()
	invert_ctrl.name = "invert_ctrl"
	invert_ctrl.pressed = false
	invert_ctrl.hint_tooltip = tr("INVERT_CTRL_HINT_TOOLTIP")
	invert_group.add_child(invert_ctrl)

	# Add a control for the center option
	var wp_cen_group = HBoxContainer.new()
	wp_cen_group.name = "wp_cen_group"
	var wp_cen_lbl = Label.new()
	wp_cen_lbl.set_text("Center Option: ")
	wp_cen_group.add_child(wp_cen_lbl)
	var wp_cen_ctrl = OptionButton.new()
	wp_cen_ctrl.name = "wp_cen_ctrl"
	Common.load_option_button(wp_cen_ctrl, center_option_list)
	wp_cen_ctrl.hint_tooltip = tr("WP_CEN_CTRL_HINT_TOOLTIP")
	wp_cen_group.add_child(wp_cen_ctrl)

	var origin_xyz_group = VBoxContainer.new()
	origin_xyz_group.name = "origin_xyz_group"
	var origin_lbl = Label.new()
	origin_lbl.set_text("Origin")
	origin_xyz_group.add_child(origin_lbl)
	var origin_group = HBoxContainer.new()
	origin_group.name = "origin_group"
	# Origin X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	origin_group.add_child(x_lbl)
	var origin_x_ctrl = NumberEdit.new()
	origin_x_ctrl.size_flags_horizontal = 3
	origin_x_ctrl.name = "origin_x_ctrl"
	origin_x_ctrl.set_text("0")
	origin_x_ctrl.hint_tooltip = tr("WP_ORIGIN_X_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_x_ctrl)
	# Origin Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	origin_group.add_child(y_lbl)
	var origin_y_ctrl = NumberEdit.new()
	origin_y_ctrl.size_flags_horizontal = 3
	origin_y_ctrl.name = "origin_y_ctrl"
	origin_y_ctrl.set_text("0")
	origin_y_ctrl.hint_tooltip = tr("WP_ORIGIN_Y_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_y_ctrl)
	# Origin Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	origin_group.add_child(z_lbl)
	var origin_z_ctrl = NumberEdit.new()
	origin_z_ctrl.size_flags_horizontal = 3
	origin_z_ctrl.name = "origin_z_ctrl"
	origin_z_ctrl.set_text("0")
	origin_z_ctrl.hint_tooltip = tr("WP_ORIGIN_Z_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_z_ctrl)

	origin_xyz_group.add_child(origin_group)

	add_child(offset_group)
	add_child(invert_group)
	add_child(wp_cen_group)
	add_child(origin_xyz_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var offset_ctrl = get_node("offset_group/offset_ctrl")
	var origin_x_ctrl = get_node("origin_xyz_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("origin_xyz_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("origin_xyz_group/origin_group/origin_z_ctrl")

	# Make sure all of the numeric controls have valid values
	if not offset_ctrl.is_valid:
		return false
	if not origin_x_ctrl.is_valid:
		return false
	if not origin_y_ctrl.is_valid:
		return false
	if not origin_z_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	var offset_ctrl = get_node("offset_group/offset_ctrl")
	var invert_ctrl = get_node("invert_group/invert_ctrl")
	var wp_cen_ctrl = get_node("wp_cen_group/wp_cen_ctrl")
	var origin_x_ctrl = get_node("origin_xyz_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("origin_xyz_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("origin_xyz_group/origin_group/origin_z_ctrl")

	complete = template.format({
			"offset": offset_ctrl.get_text(),
			"invert": invert_ctrl.pressed,
			"center_option": wp_cen_ctrl.get_item_text(wp_cen_ctrl.get_selected_id()),
			"origin_x": origin_x_ctrl.get_text(),
			"origin_y": origin_y_ctrl.get_text(),
			"origin_z": origin_z_ctrl.get_text()
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

	var rgx = RegEx.new()

	var offset_ctrl = get_node("offset_group/offset_ctrl")
	var invert_ctrl = get_node("invert_group/invert_ctrl")
	var wp_cen_ctrl = get_node("wp_cen_group/wp_cen_ctrl")
	var origin_x_ctrl = get_node("origin_xyz_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("origin_xyz_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("origin_xyz_group/origin_group/origin_z_ctrl")

	# The offset
	rgx.compile(offset_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		var offset = res.get_string()
		offset_ctrl.set_text(offset)

	# The invert option
	rgx.compile(invert_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var inv = res.get_string()
		invert_ctrl.pressed = true if inv == "True" else false

	# The workplane center option
	rgx.compile(wp_cen_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wp_cen_ctrl, res.get_string())

	# The origin text
	rgx.compile(origin_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the origin X, Y and Z controls
		var xyz = res.get_string().split(",")
		origin_x_ctrl.set_text(xyz[0])
		origin_y_ctrl.set_text(xyz[1])
		origin_z_ctrl.set_text(xyz[2])
