extends VBoxContainer

class_name RotateControl

var prev_template = null

var template = ".rotate(angleDegrees={angle_degrees},axisStartPoint={axis_start},axisEndPoint={axis_end})"

const angle_edit_rgx = "(?<=angleDegrees\\=)(.*?)(?=\\,axisStartPoint)"
const start_edit_rgx = "(?<=axisStartPoint\\=)(.*?)(?=\\,axisEndPoint)"
const end_edit_rgx = "(?<=axisEndPoint\\=)(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the controls for the start axis of the revolve
	var start_group = VBoxContainer.new()
	var start_lbl = Label.new()
	start_lbl.set_text("Axis Start")
	start_group.add_child(start_lbl)
	var axis_start_group = HBoxContainer.new()
	# Axis X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	axis_start_group.add_child(x_lbl)
	var axis_start_x_ctrl = NumberEdit.new()
	axis_start_x_ctrl.name = "axis_start_x_ctrl"
	axis_start_x_ctrl.size_flags_horizontal = 3
	axis_start_x_ctrl.set_text("0")
	axis_start_x_ctrl.hint_tooltip = tr("ROTATE_AXIS_START_X_CTRL_HINT_TOOLTIP")
	axis_start_group.add_child(axis_start_x_ctrl)
	# Axis Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	axis_start_group.add_child(y_lbl)
	var axis_start_y_ctrl = NumberEdit.new()
	axis_start_y_ctrl.name = "axis_start_y_ctrl"
	axis_start_y_ctrl.size_flags_horizontal = 3
	axis_start_y_ctrl.set_text("0")
	axis_start_y_ctrl.hint_tooltip = tr("ROTATE_AXIS_START_Y_CTRL_HINT_TOOLTIP")
	axis_start_group.add_child(axis_start_y_ctrl)
	# Axis Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	axis_start_group.add_child(z_lbl)
	var axis_start_z_ctrl = NumberEdit.new()
	axis_start_z_ctrl.name = "axis_start_z_ctrl"
	axis_start_z_ctrl.size_flags_horizontal = 3
	axis_start_z_ctrl.set_text("0")
	axis_start_z_ctrl.hint_tooltip = tr("ROTATE_AXIS_START_Z_CTRL_HINT_TOOLTIP")
	axis_start_group.add_child(axis_start_z_ctrl)

	start_group.add_child(axis_start_group)
	add_child(start_group)

	# Add the controls for the end axis of the revolve
	var end_group = VBoxContainer.new()
	var end_lbl = Label.new()
	end_lbl.set_text("Axis End")
	end_group.add_child(end_lbl)
	var axis_end_group = HBoxContainer.new()
	# Axis X
	x_lbl = Label.new()
	x_lbl.set_text("X: ")
	axis_end_group.add_child(x_lbl)
	var axis_end_x_ctrl = NumberEdit.new()
	axis_end_x_ctrl.name = "axis_end_x_ctrl"
	axis_end_x_ctrl.size_flags_horizontal = 3
	axis_end_x_ctrl.set_text("0")
	axis_end_x_ctrl.hint_tooltip = tr("ROTATE_ABOUT_CENTER_AXIS_END_X_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_x_ctrl)
	# Axis Y
	y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	axis_end_group.add_child(y_lbl)
	var axis_end_y_ctrl = NumberEdit.new()
	axis_end_y_ctrl.name = "axis_end_y_ctrl"
	axis_end_y_ctrl.size_flags_horizontal = 3
	axis_end_y_ctrl.set_text("0")
	axis_end_y_ctrl.hint_tooltip = tr("ROTATE_ABOUT_CENTER_AXIS_END_Y_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_y_ctrl)
	# Axis Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	axis_end_group.add_child(z_lbl)
	var axis_end_z_ctrl = NumberEdit.new()
	axis_end_z_ctrl.name = "axis_end_z_ctrl"
	axis_end_z_ctrl.size_flags_horizontal = 3
	axis_end_z_ctrl.set_text("1")
	axis_end_z_ctrl.hint_tooltip = tr("ROTATE_ABOUT_CENTER_AXIS_END_Z_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_z_ctrl)

	end_group.add_child(axis_end_group)
	add_child(end_group)

	# Add control for angle to rotate through
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle (Degrees): ")
	angle_group.add_child(angle_lbl)
	var angle_ctrl = NumberEdit.new()
	angle_ctrl.name = "angle_ctrl"
	angle_ctrl.size_flags_horizontal = 3
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("90.0")
	angle_ctrl.hint_tooltip = tr("ROTATE_ANGLE_CTRL_HINT_TOOLTIP")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var axis_start_x_ctrl = find_node("axis_start_x_ctrl", true, false)
	var axis_start_y_ctrl = find_node("axis_start_y_ctrl", true, false)
	var axis_start_z_ctrl = find_node("axis_start_z_ctrl", true, false)
	var axis_end_x_ctrl = find_node("axis_end_x_ctrl", true, false)
	var axis_end_y_ctrl = find_node("axis_end_y_ctrl", true, false)
	var axis_end_z_ctrl = find_node("axis_end_z_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not axis_start_x_ctrl.is_valid:
		return false
	if not axis_start_y_ctrl.is_valid:
		return false
	if not axis_start_z_ctrl.is_valid:
		return false
	if not axis_end_x_ctrl.is_valid:
		return false
	if not axis_end_y_ctrl.is_valid:
		return false
	if not axis_end_z_ctrl.is_valid:
		return false
	if not angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var axis_start_x_ctrl = find_node("axis_start_x_ctrl", true, false)
	var axis_start_y_ctrl = find_node("axis_start_y_ctrl", true, false)
	var axis_start_z_ctrl = find_node("axis_start_z_ctrl", true, false)
	var axis_end_x_ctrl = find_node("axis_end_x_ctrl", true, false)
	var axis_end_y_ctrl = find_node("axis_end_y_ctrl", true, false)
	var axis_end_z_ctrl = find_node("axis_end_z_ctrl", true, false)

	var complete = ""

	# Build the axis start and end strings
	var axis_start_str = "(" + axis_start_x_ctrl.get_text() + "," +\
							   axis_start_y_ctrl.get_text() + "," +\
							   axis_start_z_ctrl.get_text() + ")"
	var axis_end_str = "(" + axis_end_x_ctrl.get_text() + "," +\
							   axis_end_y_ctrl.get_text() + "," +\
							   axis_end_z_ctrl.get_text() + ")"

	complete += template.format({
		"angle_degrees": angle_ctrl.get_text(),
		"axis_start": axis_start_str,
		"axis_end": axis_end_str
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
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var axis_start_x_ctrl = find_node("axis_start_x_ctrl", true, false)
	var axis_start_y_ctrl = find_node("axis_start_y_ctrl", true, false)
	var axis_start_z_ctrl = find_node("axis_start_z_ctrl", true, false)
	var axis_end_x_ctrl = find_node("axis_end_x_ctrl", true, false)
	var axis_end_y_ctrl = find_node("axis_end_y_ctrl", true, false)
	var axis_end_z_ctrl = find_node("axis_end_z_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Rotation angle
	rgx.compile(angle_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		angle_ctrl.set_text(res.get_string())

	# Start axis
	rgx.compile(start_edit_rgx)
	res = rgx.search(text_line)
	var parts = res.get_string().replace("(", "").replace(")", "").split(",")
	if res:
		axis_start_x_ctrl.set_text(parts[0])
		axis_start_y_ctrl.set_text(parts[1])
		axis_start_z_ctrl.set_text(parts[2])

	# End axis
	rgx.compile(end_edit_rgx)
	res = rgx.search(text_line)
	parts = res.get_string().replace("(", "").replace(")", "").split(",")
	if res:
		axis_end_x_ctrl.set_text(parts[0])
		axis_end_y_ctrl.set_text(parts[1])
		axis_end_z_ctrl.set_text(parts[2])
