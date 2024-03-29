extends VBoxContainer

class_name PolarArrayControl

var prev_template = null

var template = ".polarArray({radius},startAngle={startAngle},angle={angle},count={count},fill={fill},rotate={rotate})"

const radius_edit_rgx = "(?<=.polarArray\\()(.*?)(?=,startAngle)"
const start_angle_edit_rgx = "(?<=startAngle\\=)(.*?)(?=\\,angle)"
const angle_edit_rgx = "(?<=angle\\=)(.*?)(?=\\,count)"
const count_edit_rgx = "(?<=count\\=)(.*?)(?=\\,fill)"
const fill_edit_rgx = "(?<=fill\\=)(.*?)(?=\\,rotate)"
const rotate_edit_rgx = "(?<=rotate\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the radius controls
	var rad_group = HBoxContainer.new()
	var rad_lbl = Label.new()
	rad_lbl.set_text("Radius: ")
	rad_group.add_child(rad_lbl)
	var radius_ctrl = NumberEdit.new()
	radius_ctrl.name = "radius_ctrl"
	radius_ctrl.size_flags_horizontal = 3
	radius_ctrl.set_text("1.0")
	radius_ctrl.hint_tooltip = tr("POLAR_ARRAY_RADIUS_CTRL_HINT_TOOLTIP")
	rad_group.add_child(radius_ctrl)
	add_child(rad_group)

	# Start Angle
	var start_angle_group = HBoxContainer.new()
	var start_angle_lbl = Label.new()
	start_angle_lbl.set_text("Start Angle: ")
	start_angle_group.add_child(start_angle_lbl)
	var start_angle_ctrl = NumberEdit.new()
	start_angle_ctrl.CanBeNegative = true
	start_angle_ctrl.name = "start_angle_ctrl"
	start_angle_ctrl.size_flags_horizontal = 3
	start_angle_ctrl.MinValue = -360.0
	start_angle_ctrl.MaxValue = 360.0
	start_angle_ctrl.set_text("0.0")
	start_angle_ctrl.hint_tooltip = tr("POLAR_ARRAY_START_ANGLE_CTRL_HINT_TOOLTIP")
	start_angle_group.add_child(start_angle_ctrl)
	add_child(start_angle_group)

	# Angle
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	var angle_ctrl = NumberEdit.new()
	angle_ctrl.name = "angle_ctrl"
	angle_ctrl.size_flags_horizontal = 3
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("360.0")
	angle_ctrl.hint_tooltip = tr("POLAR_ARRAY_ANGLE_CTRL_HINT_TOOLTIP")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

	# Count
	var count_group = HBoxContainer.new()
	var count_lbl = Label.new()
	count_lbl.set_text("Count: ")
	count_group.add_child(count_lbl)
	var count_ctrl = NumberEdit.new()
	count_ctrl.name = "count_ctrl"
	count_ctrl.size_flags_horizontal = 3
	count_ctrl.NumberFormat = "int"
	count_ctrl.set_text("5")
	count_ctrl.CanBeZero = false
	count_ctrl.hint_tooltip = tr("POLAR_ARRAY_COUNT_CTRL_HINT_TOOLTIP")
	count_group.add_child(count_ctrl)
	add_child(count_group)

	# Fill
	var fill_group = HBoxContainer.new()
	var fill_lbl = Label.new()
	fill_lbl.set_text("Fill: ")
	fill_group.add_child(fill_lbl)
	var fill_ctrl = CheckBox.new()
	fill_ctrl.name = "fill_ctrl"
	fill_ctrl.pressed = true
	fill_ctrl.hint_tooltip = tr("POLAR_ARRAY_FILL_CTRL_HINT_TOOLTIP")
	fill_group.add_child(fill_ctrl)
	add_child(fill_group)

	# Rotate
	var rotate_group = HBoxContainer.new()
	var rotate_lbl = Label.new()
	rotate_lbl.set_text("Rotate: ")
	rotate_group.add_child(rotate_lbl)
	var rotate_ctrl = CheckBox.new()
	rotate_ctrl.name = "rotate_ctrl"
	rotate_ctrl.pressed = true
	rotate_ctrl.hint_tooltip = tr("POLAR_ARRAY_ROTATE_CTRL_HINT_TOOLTIP")
	rotate_group.add_child(rotate_ctrl)
	add_child(rotate_group)


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
	var start_angle_ctrl = find_node("start_angle_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var count_ctrl = find_node("count_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not radius_ctrl.is_valid:
		return false
	if not start_angle_ctrl.is_valid:
		return false
	if not angle_ctrl.is_valid:
		return false
	if not count_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var start_angle_ctrl = find_node("start_angle_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var count_ctrl = find_node("count_ctrl", true, false)
	var fill_ctrl = find_node("fill_ctrl", true, false)
	var rotate_ctrl = find_node("rotate_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"radius": radius_ctrl.get_text(),
		"startAngle": start_angle_ctrl.get_text(),
		"angle": angle_ctrl.get_text(),
		"count": count_ctrl.get_text(),
		"fill": fill_ctrl.pressed,
		"rotate": rotate_ctrl.pressed
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
	var start_angle_ctrl = find_node("start_angle_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var count_ctrl = find_node("count_ctrl", true, false)
	var fill_ctrl = find_node("fill_ctrl", true, false)
	var rotate_ctrl = find_node("rotate_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Radius
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# Start angle
	rgx.compile(start_angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var angle = res.get_string()
		start_angle_ctrl.set_text(angle)

	# Angle
	rgx.compile(angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var angle = res.get_string()
		angle_ctrl.set_text(angle)

	# Count
	rgx.compile(count_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var count = res.get_string()
		count_ctrl.set_text(count)

	# Fill
	rgx.compile(fill_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var fill = res.get_string()
		fill_ctrl.pressed = true if fill == "True" else false

	# Rotate
	rgx.compile(rotate_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var rotate = res.get_string()
		rotate_ctrl.pressed = true if rotate == "True" else false
