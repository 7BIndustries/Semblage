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

var radius_ctrl = null
var start_angle_ctrl = null
var angle_ctrl = null
var count_ctrl = null
var fill_ctrl = null
var rotate_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the radius controls
	var rad_group = HBoxContainer.new()
	var rad_lbl = Label.new()
	rad_lbl.set_text("Radius: ")
	rad_group.add_child(rad_lbl)
	radius_ctrl = NumberEdit.new()
	radius_ctrl.set_text("1.0")
	radius_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_radius_ctrl_hint_tooltip
	rad_group.add_child(radius_ctrl)
	add_child(rad_group)

	# Start Angle
	var start_angle_group = HBoxContainer.new()
	var start_angle_lbl = Label.new()
	start_angle_lbl.set_text("Start Angle: ")
	start_angle_group.add_child(start_angle_lbl)
	start_angle_ctrl = NumberEdit.new()
	start_angle_ctrl.MaxValue = 360.0
	start_angle_ctrl.set_text("0.0")
	start_angle_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_start_angle_ctrl_hint_tooltip
	start_angle_group.add_child(start_angle_ctrl)
	add_child(start_angle_group)

	# Angle
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = NumberEdit.new()
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("360.0")
	angle_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_angle_ctrl_hint_tooltip
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

	# Count
	var count_group = HBoxContainer.new()
	var count_lbl = Label.new()
	count_lbl.set_text("Count: ")
	count_group.add_child(count_lbl)
	count_ctrl = NumberEdit.new()
	count_ctrl.NumberFormat = "int"
	count_ctrl.set_text("5")
	count_ctrl.CanBeZero = false
	count_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_count_ctrl_hint_tooltip
	count_group.add_child(count_ctrl)
	add_child(count_group)

	# Fill
	var fill_group = HBoxContainer.new()
	var fill_lbl = Label.new()
	fill_lbl.set_text("Fill: ")
	fill_group.add_child(fill_lbl)
	fill_ctrl = CheckBox.new()
	fill_ctrl.pressed = true
	fill_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_fill_ctrl_hint_tooltip
	fill_group.add_child(fill_ctrl)
	add_child(fill_group)

	# Rotate
	var rotate_group = HBoxContainer.new()
	var rotate_lbl = Label.new()
	rotate_lbl.set_text("Rotate: ")
	rotate_group.add_child(rotate_lbl)
	rotate_ctrl = CheckBox.new()
	rotate_ctrl.pressed = true
	rotate_ctrl.hint_tooltip = ToolTips.get_tts().polar_array_rotate_ctrl_hint_tooltip
	rotate_group.add_child(rotate_ctrl)
	add_child(rotate_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
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


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
