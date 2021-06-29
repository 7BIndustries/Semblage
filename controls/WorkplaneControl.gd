extends VBoxContainer

class_name WorkplaneControl

var simple_template = ".Workplane(\"{named_wp}\").workplane(invert={invert},centerOption=\"{center_option}\").tag(\"{comp_name}\")"
var template = ".Workplane(cq.Plane(origin=({origin_x},{origin_y},{origin_z}), xDir=({xdir_x},{xdir_y},{xdir_z}), normal=({normal_x},{normal_y},{normal_z}))).tag(\"{comp_name}\")"

var prev_template = null

const workplane_list = ["XY", "YZ", "XZ"]
const center_option_list = ["CenterOfBoundBox", "CenterOfMass", "ProjectedOrigin"]

var advanced_group = null

const wp_name_edit_rgx = "(?<=.Workplane\\(\")(.*?)(?=\"\\))"
const wp_cen_edit_rgx = "(?<=centerOption\\=\")(.*?)(?=\"\\))"
const invert_edit_rgx = "(?<=invert\\=)(.*?)(?=,centerOption)"
const origin_edit_rgx = "(?<=origin\\=\\()(.*?)(?=\\))"
const xdir_edit_rgx = "(?<=xdir\\=\\()(.*?)(?=\\))"
const normal_edit_rgx = "(?<=normal\\=\\()(.*?)(?=\\))"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Allow the user to give the Workplane/component a name
	var name_group = HBoxContainer.new()
	name_group.name = "name_group"
	var wp_name_lbl = Label.new()
	wp_name_lbl.set_text("Name: ")
	name_group.add_child(wp_name_lbl)
	var wp_name_ctrl = WPNameEdit.new()
	wp_name_ctrl.name = "wp_name_ctrl"
	wp_name_ctrl.expand_to_text_length = true
	wp_name_ctrl.set_text("change_me")
	wp_name_ctrl.hint_tooltip = tr("WP_NAME_CTRL_HINT_TOOLTIP")
	name_group.add_child(wp_name_ctrl)
	add_child(name_group)

	# Allow the user to select the named workplane
	var wp_group = HBoxContainer.new()
	wp_group.name = "wp_group"
	var wp_lbl = Label.new()
	wp_lbl.set_text("Orientation: ")
	wp_group.add_child(wp_lbl)
	var wp_ctrl = OptionButton.new()
	wp_ctrl.name = "wp_ctrl"
	Common.load_option_button(wp_ctrl, workplane_list)
	wp_ctrl.hint_tooltip = tr("WP_CTRL_HINT_TOOLTIP")
	wp_group.add_child(wp_ctrl)
	add_child(wp_group)

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
	add_child(wp_cen_group)

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
	add_child(invert_group)

	# Allow the user to show and hide the advanced workplane controls
	var hide_show_btn = Button.new()
	hide_show_btn.set_text("Advanced")
	hide_show_btn.hint_tooltip = tr("WP_HIDE_SHOW_BTN_HINT_TOOLTIP")
	hide_show_btn.connect("button_down", self, "_show_advanced")
	add_child(hide_show_btn)

	# The advanced workplane controls
	advanced_group = VBoxContainer.new()
	advanced_group.name = "advanced_group"
	advanced_group.hide()
	var origin_lbl = Label.new()
	origin_lbl.set_text("Origin")
	advanced_group.add_child(origin_lbl)
	var origin_group = HBoxContainer.new()
	origin_group.name = "origin_group"
	# Origin X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	origin_group.add_child(x_lbl)
	var origin_x_ctrl = NumberEdit.new()
	origin_x_ctrl.name = "origin_x_ctrl"
	origin_x_ctrl.set_text("0")
	origin_x_ctrl.hint_tooltip = tr("WP_ORIGIN_X_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_x_ctrl)
	# Origin Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	origin_group.add_child(y_lbl)
	var origin_y_ctrl = NumberEdit.new()
	origin_y_ctrl.name = "origin_y_ctrl"
	origin_y_ctrl.set_text("0")
	origin_y_ctrl.hint_tooltip = tr("WP_ORIGIN_Y_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_y_ctrl)
	# Origin Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	origin_group.add_child(z_lbl)
	var origin_z_ctrl = NumberEdit.new()
	origin_z_ctrl.name = "origin_z_ctrl"
	origin_z_ctrl.set_text("0")
	origin_z_ctrl.hint_tooltip = tr("WP_ORIGIN_Z_CTRL_HINT_TOOLTIP")
	origin_group.add_child(origin_z_ctrl)

	advanced_group.add_child(origin_group)

	# XDir Controls
	var xdir_lbl = Label.new()
	xdir_lbl.set_text("X Direction")
	advanced_group.add_child(xdir_lbl)
	var xdir_group = HBoxContainer.new()
	xdir_group.name = "xdir_group"
	# XDir X
	var xdir_x_lbl = Label.new()
	xdir_x_lbl.set_text("X: ")
	xdir_group.add_child(xdir_x_lbl)
	var xdir_x_ctrl = NumberEdit.new()
	xdir_x_ctrl.name = "xdir_x_ctrl"
	xdir_x_ctrl.set_text("1")
	xdir_x_ctrl.hint_tooltip = tr("WP_XDIR_X_CTRL_HINT_TOOLTIP")
	xdir_group.add_child(xdir_x_ctrl)
	# XDir Y
	var xdir_y_lbl = Label.new()
	xdir_y_lbl.set_text("Y: ")
	xdir_group.add_child(xdir_y_lbl)
	var xdir_y_ctrl = NumberEdit.new()
	xdir_y_ctrl.name = "xdir_y_ctrl"
	xdir_y_ctrl.set_text("0")
	xdir_y_ctrl.hint_tooltip = tr("WP_XDIR_Y_CTRL_HINT_TOOLTIP")
	xdir_group.add_child(xdir_y_ctrl)
	# XDir Z
	var xdir_z_lbl = Label.new()
	xdir_z_lbl.set_text("Z: ")
	xdir_group.add_child(xdir_z_lbl)
	var xdir_z_ctrl = NumberEdit.new()
	xdir_z_ctrl.name = "xdir_z_ctrl"
	xdir_z_ctrl.set_text("0")
	xdir_z_ctrl.hint_tooltip = tr("WP_XDIR_Z_CTRL_HINT_TOOLTIP")
	xdir_group.add_child(xdir_z_ctrl)

	advanced_group.add_child(xdir_group)

	# Normal controls
	var normal_lbl = Label.new()
	normal_lbl.set_text("Normal")
	advanced_group.add_child(normal_lbl)
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
	normal_z_ctrl.set_text("1")
	normal_z_ctrl.hint_tooltip = tr("WP_NORMAL_Z_CTRL_HINT_TOOLTIP")
	normal_group.add_child(normal_z_ctrl)

	advanced_group.add_child(normal_group)

	add_child(advanced_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var origin_x_ctrl = get_node("advanced_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("advanced_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("advanced_group/origin_group/origin_z_ctrl")
	var xdir_x_ctrl = get_node("advanced_group/xdir_group/xdir_x_ctrl")
	var xdir_y_ctrl = get_node("advanced_group/xdir_group/xdir_y_ctrl")
	var xdir_z_ctrl = get_node("advanced_group/xdir_group/xdir_z_ctrl")
	var normal_x_ctrl = get_node("advanced_group/normal_group/normal_x_ctrl")
	var normal_y_ctrl = get_node("advanced_group/normal_group/normal_y_ctrl")
	var normal_z_ctrl = get_node("advanced_group/normal_group/normal_z_ctrl")

	# Make sure all of the numeric controls have valid values
	if not origin_x_ctrl.is_valid:
		return false
	if not origin_y_ctrl.is_valid:
		return false
	if not origin_z_ctrl.is_valid:
		return false
	if not xdir_x_ctrl.is_valid:
		return false
	if not xdir_y_ctrl.is_valid:
		return false
	if not xdir_z_ctrl.is_valid:
		return false
	if not normal_x_ctrl.is_valid:
		return false
	if not normal_y_ctrl.is_valid:
		return false
	if not normal_z_ctrl.is_valid:
		return false
	if not wp_name_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	var wp_ctrl = get_node("wp_group/wp_ctrl")
	var wp_cen_ctrl = get_node("wp_cen_group/wp_cen_ctrl")
	var invert_ctrl = get_node("invert_group/invert_ctrl")
	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var origin_x_ctrl = get_node("advanced_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("advanced_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("advanced_group/origin_group/origin_z_ctrl")
	var xdir_x_ctrl = get_node("advanced_group/xdir_group/xdir_x_ctrl")
	var xdir_y_ctrl = get_node("advanced_group/xdir_group/xdir_y_ctrl")
	var xdir_z_ctrl = get_node("advanced_group/xdir_group/xdir_z_ctrl")
	var normal_x_ctrl = get_node("advanced_group/normal_group/normal_x_ctrl")
	var normal_y_ctrl = get_node("advanced_group/normal_group/normal_y_ctrl")
	var normal_z_ctrl = get_node("advanced_group/normal_group/normal_z_ctrl")

	# If the advanced group is visible, fill the advanced template out with those controls
	if advanced_group.visible:
		complete = template.format({
			"comp_name": wp_name_ctrl.get_text(),
			"origin_x": origin_x_ctrl.get_text(),
			"origin_y": origin_y_ctrl.get_text(),
			"origin_z": origin_z_ctrl.get_text(),
			"xdir_x": xdir_x_ctrl.get_text(),
			"xdir_y": xdir_y_ctrl.get_text(),
			"xdir_z": xdir_z_ctrl.get_text(),
			"normal_x": normal_x_ctrl.get_text(),
			"normal_y": normal_y_ctrl.get_text(),
			"normal_z": normal_z_ctrl.get_text(),
			})
	else:
		# Use the simple template
		complete = simple_template.format({
			"comp_name": wp_name_ctrl.get_text(),
			"named_wp": wp_ctrl.get_item_text(wp_ctrl.get_selected_id()),
			"center_option": wp_cen_ctrl.get_item_text(wp_cen_ctrl.get_selected_id()),
			"invert": invert_ctrl.pressed
		})

	return complete


"""
When in edit mode, returns the previous template string that needs to
be replaced.
"""
func get_previous_template():
	return prev_template


"""
Shows/hides the advanced workplane controls.
"""
func _show_advanced():
	if advanced_group.visible:
		advanced_group.hide()
	else:
		advanced_group.show()


"""
Loads values into the control's sub-controls based on a code string.
"""
func set_values_from_string(text_line):
	prev_template = text_line

	var rgx = RegEx.new()

	var wp_ctrl = get_node("wp_group/wp_ctrl")
	var wp_cen_ctrl = get_node("wp_cen_group/wp_cen_ctrl")
	var invert_ctrl = get_node("invert_group/invert_ctrl")
	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var origin_x_ctrl = get_node("advanced_group/origin_group/origin_x_ctrl")
	var origin_y_ctrl = get_node("advanced_group/origin_group/origin_y_ctrl")
	var origin_z_ctrl = get_node("advanced_group/origin_group/origin_z_ctrl")
	var xdir_x_ctrl = get_node("advanced_group/xdir_group/xdir_x_ctrl")
	var xdir_y_ctrl = get_node("advanced_group/xdir_group/xdir_y_ctrl")
	var xdir_z_ctrl = get_node("advanced_group/xdir_group/xdir_z_ctrl")
	var normal_x_ctrl = get_node("advanced_group/normal_group/normal_x_ctrl")
	var normal_y_ctrl = get_node("advanced_group/normal_group/normal_y_ctrl")
	var normal_z_ctrl = get_node("advanced_group/normal_group/normal_z_ctrl")

	# The workplane name
	rgx.compile(wp_name_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wp_ctrl, res.get_string())

	# The workplane center option
	rgx.compile(wp_cen_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wp_cen_ctrl, res.get_string())

	# The invert option
	rgx.compile(invert_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var inv = res.get_string()
		invert_ctrl.pressed = true if inv == "True" else false

	# The origin text
	rgx.compile(origin_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the origin X, Y and Z controls
		var xyz = res.get_string().split(",")
		origin_x_ctrl.set_text(xyz[0])
		origin_y_ctrl.set_text(xyz[1])
		origin_z_ctrl.set_text(xyz[2])

	# The xdir text
	rgx.compile(xdir_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the xdir X, Y and Z controls
		var xyz = res.get_string().split(",")
		xdir_x_ctrl.set_text(xyz[0])
		xdir_y_ctrl.set_text(xyz[1])
		xdir_z_ctrl.set_text(xyz[2])

	# The normal text
	rgx.compile(normal_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the normal X, Y and Z controls
		var xyz = res.get_string().split(",")
		normal_x_ctrl.set_text(xyz[0])
		normal_y_ctrl.set_text(xyz[1])
		normal_z_ctrl.set_text(xyz[2])

	# The component (tag) name
	rgx.compile(tag_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the tag/name text
		wp_name_ctrl.set_text(res.get_string())
