extends VBoxContainer

class_name RotateAboutCenterControl

var template = ".rotateAboutCenter(axisEndPoint=({axis_end}),angleDegrees={angle_degrees})"

var prev_template = null

var axis_end_x_ctrl = null
var axis_end_y_ctrl = null
var axis_end_z_ctrl = null
var angle_ctrl = null

var axis_end_edit_rgx = "(?<=axisEndPoint\\=)(.*?)(?=\\,angleDegrees)"
var angle_edit_rgx = "(?<=angleDegrees\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the controls for the end axis of the revolve
	var end_group = VBoxContainer.new()
	var end_lbl = Label.new()
	end_lbl.set_text("Axis End")
	end_group.add_child(end_lbl)
	var axis_end_group = HBoxContainer.new()
	# Axis X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	axis_end_group.add_child(x_lbl)
	axis_end_x_ctrl = NumberEdit.new()
	axis_end_x_ctrl.set_text("0")
	axis_end_group.add_child(axis_end_x_ctrl)
	# Axis Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	axis_end_group.add_child(y_lbl)
	axis_end_y_ctrl = NumberEdit.new()
	axis_end_y_ctrl.set_text("0")
	axis_end_group.add_child(axis_end_y_ctrl)
	# Axis Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	axis_end_group.add_child(z_lbl)
	axis_end_z_ctrl = NumberEdit.new()
	axis_end_z_ctrl.set_text("1")
	axis_end_group.add_child(axis_end_z_ctrl)

	end_group.add_child(axis_end_group)
	add_child(end_group)

	# Add control for angle to revolve through
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle (Degrees): ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = NumberEdit.new()
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("90.0")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
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
	var complete = ""

	# Build the axis end string
	var axis_end_str = "(" + axis_end_x_ctrl.get_text() + "," +\
							   axis_end_y_ctrl.get_text() + "," +\
							   axis_end_z_ctrl.get_text() + ")"

	complete += template.format({
		"angle_degrees": angle_ctrl.get_text(),
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
	prev_template = text_line

	var rgx = RegEx.new()

	# Rotation angle
	rgx.compile(angle_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		angle_ctrl.set_text(res.get_string())

	# End axis
	rgx.compile(axis_end_edit_rgx)
	res = rgx.search(text_line)
	var parts = res.get_string().replace("(", "").replace(")", "").split(",")
	if res:
		axis_end_x_ctrl.set_text(parts[0])
		axis_end_y_ctrl.set_text(parts[1])
		axis_end_z_ctrl.set_text(parts[2])
