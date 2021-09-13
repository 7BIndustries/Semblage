extends VBoxContainer

class_name SphereControl

var prev_template = null

var template = ".sphere({radius},direct=({direct_x},{direct_y},{direct_z}),angle1={angle1},angle2={angle2},angle3={angle3},centered=({centered_x},{centered_y},{centered_z}),combine={combine},clean={clean})"

const radius_edit_rgx = "(?<=.radius\\()(.*?)(?=,direct)"
const direct_edit_rgx = "(?<=direct\\=\\()(.*?)(?=\\),angle1)"
const angle1_edit_rgx = "(?<=angle1\\=)(.*?)(?=,angle2)"
const angle2_edit_rgx = "(?<=angle2\\=)(.*?)(?=,angle3)"
const angle3_edit_rgx = "(?<=angle3\\=)(.*?)(?=,centered)"
const centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\),combine)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Radius
	var radius_group = HBoxContainer.new()
	var radius_ctrl_lbl = Label.new()
	radius_ctrl_lbl.set_text("Radius: ")
	radius_group.add_child(radius_ctrl_lbl)
	var radius_ctrl = NumberEdit.new()
	radius_ctrl.name = "radius_ctrl"
	radius_ctrl.size_flags_horizontal = 3
	radius_ctrl.set_text("10.0")
	radius_ctrl.hint_tooltip = tr("SPHERE_RADIUS_CTRL_HINT_TOOLTIP")
	radius_group.add_child(radius_ctrl)
	add_child(radius_group)

	# The direction controls
	var direct_group = VBoxContainer.new()
	var direct_lbl = Label.new()
	direct_lbl.set_text("Direction")
	direct_group.add_child(direct_lbl)
	var dir_group = HBoxContainer.new()
	# Direction X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	dir_group.add_child(x_lbl)
	var direct_x_ctrl = NumberEdit.new()
	direct_x_ctrl.name = "direct_x_ctrl"
	direct_x_ctrl.size_flags_horizontal = 3
	direct_x_ctrl.set_text("0")
	direct_x_ctrl.hint_tooltip = tr("SPHERE_DIRECT_X_CTRL_HINT_TOOLTIP")
	dir_group.add_child(direct_x_ctrl)
	# Direction Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	dir_group.add_child(y_lbl)
	var direct_y_ctrl = NumberEdit.new()
	direct_y_ctrl.name = "direct_y_ctrl"
	direct_y_ctrl.size_flags_horizontal = 3
	direct_y_ctrl.set_text("0")
	direct_y_ctrl.hint_tooltip = tr("SPHERE_DIRECT_Y_CTRL_HINT_TOOLTIP")
	dir_group.add_child(direct_y_ctrl)
	# Direction Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	dir_group.add_child(z_lbl)
	var direct_z_ctrl = NumberEdit.new()
	direct_z_ctrl.name = "direct_z_ctrl"
	direct_z_ctrl.size_flags_horizontal = 3
	direct_z_ctrl.set_text("1")
	direct_z_ctrl.hint_tooltip = tr("SPHERE_DIRECT_Z_CTRL_HINT_TOOLTIP")
	dir_group.add_child(direct_z_ctrl)

	direct_group.add_child(dir_group)
	add_child(direct_group)

	# Angle 1
	var angle1_group = HBoxContainer.new()
	var angle1_ctrl_lbl = Label.new()
	angle1_ctrl_lbl.set_text("Angle 1: ")
	angle1_group.add_child(angle1_ctrl_lbl)
	var angle1_ctrl = NumberEdit.new()
	angle1_ctrl.name = "angle1_ctrl"
	angle1_ctrl.size_flags_horizontal = 3
	angle1_ctrl.CanBeNegative = true
	angle1_ctrl.MinValue = -360.0
	angle1_ctrl.MaxValue = 360.0
	angle1_ctrl.set_text("-90")
	angle1_ctrl.hint_tooltip = tr("SPHERE_ANGLE1_CTRL_HINT_TOOLTIP")
	angle1_group.add_child(angle1_ctrl)
	add_child(angle1_group)

	# Angle 2
	var angle2_group = HBoxContainer.new()
	var angle2_ctrl_lbl = Label.new()
	angle2_ctrl_lbl.set_text("Angle 2: ")
	angle2_group.add_child(angle2_ctrl_lbl)
	var angle2_ctrl = NumberEdit.new()
	angle2_ctrl.name = "angle2_ctrl"
	angle2_ctrl.size_flags_horizontal = 3
	angle2_ctrl.MinValue = -360.0
	angle2_ctrl.MaxValue = 360.0
	angle2_ctrl.set_text("90.0")
	angle2_ctrl.hint_tooltip = tr("SPHERE_ANGLE2_CTRL_HINT_TOOLTIP")
	angle2_group.add_child(angle2_ctrl)
	add_child(angle2_group)

	# Angle 3
	var angle3_group = HBoxContainer.new()
	var angle3_ctrl_lbl = Label.new()
	angle3_ctrl_lbl.set_text("Angle 3: ")
	angle3_group.add_child(angle3_ctrl_lbl)
	var angle3_ctrl = NumberEdit.new()
	angle3_ctrl.name = "angle3_ctrl"
	angle3_ctrl.size_flags_horizontal = 3
	angle2_ctrl.MinValue = -360.0
	angle3_ctrl.MaxValue = 360.0
	angle3_ctrl.set_text("360.0")
	angle3_ctrl.hint_tooltip = tr("SPHERE_ANGLE3_CTRL_HINT_TOOLTIP")
	angle3_group.add_child(angle3_ctrl)
	add_child(angle3_group)

	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered")
	add_child(centered_lbl)

	# Add the box centering controls
	var centered_group = HBoxContainer.new()
	# X
	var cen_x_lbl = Label.new()
	cen_x_lbl.set_text("X: ")
	centered_group.add_child(cen_x_lbl)
	var centered_x_ctrl = CheckBox.new()
	centered_x_ctrl.name = "centered_x_ctrl"
	centered_x_ctrl.pressed = true
	centered_x_ctrl.hint_tooltip = tr("CEN_X_CTRL_HINT_TOOLTIP")
	centered_group.add_child(centered_x_ctrl)
	# Y
	var cen_y_lbl = Label.new()
	cen_y_lbl.set_text("Y: ")
	centered_group.add_child(cen_y_lbl)
	var centered_y_ctrl = CheckBox.new()
	centered_y_ctrl.name = "centered_y_ctrl"
	centered_y_ctrl.pressed = true
	centered_y_ctrl.hint_tooltip = tr("CEN_Y_CTRL_HINT_TOOLTIP")
	centered_group.add_child(centered_y_ctrl)
	# Z
	var cen_z_lbl = Label.new()
	cen_z_lbl.set_text("Z: ")
	centered_group.add_child(cen_z_lbl)
	var centered_z_ctrl = CheckBox.new()
	centered_z_ctrl.name = "centered_z_ctrl"
	centered_z_ctrl.pressed = true
	centered_z_ctrl.hint_tooltip = tr("CEN_Z_CTRL_HINT_TOOLTIP")
	centered_group.add_child(centered_z_ctrl)
	add_child(centered_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	var combine_ctrl = CheckBox.new()
	combine_ctrl.name = "combine_ctrl"
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)
	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	var clean_ctrl = CheckBox.new()
	clean_ctrl.name = "clean_ctrl"
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var direct_x_ctrl = find_node("direct_x_ctrl", true, false)
	var direct_y_ctrl = find_node("direct_y_ctrl", true, false)
	var direct_z_ctrl = find_node("direct_z_ctrl", true, false)
	var angle1_ctrl = find_node("angle1_ctrl", true, false)
	var angle2_ctrl = find_node("angle2_ctrl", true, false)
	var angle3_ctrl = find_node("angle3_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not radius_ctrl.is_valid:
		return false
	if not direct_x_ctrl.is_valid:
		return false
	if not direct_y_ctrl.is_valid:
		return false
	if not direct_y_ctrl.is_valid:
		return false
	if not angle1_ctrl.is_valid:
		return false
	if not angle2_ctrl.is_valid:
		return false
	if not angle3_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var direct_x_ctrl = find_node("direct_x_ctrl", true, false)
	var direct_y_ctrl = find_node("direct_y_ctrl", true, false)
	var direct_z_ctrl = find_node("direct_z_ctrl", true, false)
	var angle1_ctrl = find_node("angle1_ctrl", true, false)
	var angle2_ctrl = find_node("angle2_ctrl", true, false)
	var angle3_ctrl = find_node("angle3_ctrl", true, false)
	var centered_x_ctrl = find_node("centered_x_ctrl", true, false)
	var centered_y_ctrl = find_node("centered_y_ctrl", true, false)
	var centered_z_ctrl = find_node("centered_z_ctrl", true, false)
	var combine_ctrl = find_node("combine_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

	var complete = template.format({
		"radius": radius_ctrl.get_text(),
		"direct_x": direct_x_ctrl.get_text(),
		"direct_y": direct_y_ctrl.get_text(),
		"direct_z": direct_z_ctrl.get_text(),
		"angle1": angle1_ctrl.get_text(),
		"angle2": angle2_ctrl.get_text(),
		"angle3": angle3_ctrl.get_text(),
		"centered_x": centered_x_ctrl.pressed,
		"centered_y": centered_y_ctrl.pressed,
		"centered_z": centered_z_ctrl.pressed,
		"combine": combine_ctrl.pressed,
		"clean": clean_ctrl.pressed
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
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var direct_x_ctrl = find_node("direct_x_ctrl", true, false)
	var direct_y_ctrl = find_node("direct_y_ctrl", true, false)
	var direct_z_ctrl = find_node("direct_z_ctrl", true, false)
	var angle1_ctrl = find_node("angle1_ctrl", true, false)
	var angle2_ctrl = find_node("angle2_ctrl", true, false)
	var angle3_ctrl = find_node("angle3_ctrl", true, false)
	var centered_x_ctrl = find_node("centered_x_ctrl", true, false)
	var centered_y_ctrl = find_node("centered_y_ctrl", true, false)
	var centered_z_ctrl = find_node("centered_z_ctrl", true, false)
	var combine_ctrl = find_node("combine_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# The sphere radius
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# The direction values
	rgx.compile(direct_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the xdir X, Y and Z controls
		var xyz = res.get_string().split(",")
		direct_x_ctrl.set_text(xyz[0])
		direct_y_ctrl.set_text(xyz[1])
		direct_z_ctrl.set_text(xyz[2])

	# Angle 1
	rgx.compile(angle1_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle1_ctrl.set_text(angle)

	# Angle 2
	rgx.compile(angle2_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle2_ctrl.set_text(angle)

	# Angle 3
	rgx.compile(angle3_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle3_ctrl.set_text(angle)

	# Box centering booleans
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the centering controls
		var lwh = res.get_string().split(",")
		centered_x_ctrl.pressed = true if lwh[0] == "True" else false
		centered_y_ctrl.pressed = true if lwh[1] == "True" else false
		centered_z_ctrl.pressed = true if lwh[2] == "True" else false

	# Combine boolean
	rgx.compile(combine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var comb = res.get_string()
		combine_ctrl.pressed = true if comb == "True" else false

	# Clean boolean
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false
