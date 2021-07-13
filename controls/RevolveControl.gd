extends VBoxContainer

class_name RevolveControl

var is_binary = false

var prev_template = null

var template = ".revolve(angleDegrees={angle_degrees},axisStart={axis_start},axisEnd={axis_end},combine={combine},clean={clean})"
var wp_template = ".workplane(invert={invert})"

const angle_edit_rgx = "(?<=angleDegrees\\=)(.*?)(?=\\,axisStart)"
const start_edit_rgx = "(?<=axisStart\\=)(.*?)(?=\\,axisEnd)"
const end_edit_rgx = "(?<=axisEnd\\=)(.*?)(?=\\,combine)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"
const wp_edit_rgx = "(?<=.workplane\\(invert\\=)(.*?)(?=\\))"

var angle_ctrl = null
var axis_start_x_ctrl = null
var axis_start_y_ctrl = null
var axis_start_z_ctrl = null
var axis_end_x_ctrl = null
var axis_end_y_ctrl = null
var axis_end_z_ctrl = null
var combine_ctrl = null
var clean_ctrl = null
var invert_ctrl = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add control for angle to revolve through
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle (Degrees): ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = NumberEdit.new()
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("360.0")
	angle_ctrl.hint_tooltip = tr("REVOLVE_ANGLE_CTRL_HINT_TOOLTIP")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

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
	axis_start_x_ctrl = NumberEdit.new()
	axis_start_x_ctrl.set_text("0")
	axis_start_x_ctrl.hint_tooltip = tr("REVOLVE_AXIS_START_X_CTRL_HINT_TOOLTIP")
	axis_start_group.add_child(axis_start_x_ctrl)
	# Axis Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	axis_start_group.add_child(y_lbl)
	axis_start_y_ctrl = NumberEdit.new()
	axis_start_y_ctrl.set_text("0")
	axis_start_y_ctrl.hint_tooltip = tr("REVOLVE_AXIS_START_Y_CTRL_HINT_TOOLTIP")
	axis_start_group.add_child(axis_start_y_ctrl)
	# Axis Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	axis_start_group.add_child(z_lbl)
	axis_start_z_ctrl = NumberEdit.new()
	axis_start_z_ctrl.set_text("0")
	axis_start_z_ctrl.hint_tooltip = tr("REVOLVE_AXIS_START_Z_CTRL_HINT_TOOLTIP")
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
	axis_end_x_ctrl = NumberEdit.new()
	axis_end_x_ctrl.set_text("0")
	axis_end_x_ctrl.hint_tooltip = tr("REVOLVE_AXIS_END_X_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_x_ctrl)
	# Axis Y
	y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	axis_end_group.add_child(y_lbl)
	axis_end_y_ctrl = NumberEdit.new()
	axis_end_y_ctrl.set_text("0")
	axis_end_y_ctrl.hint_tooltip = tr("REVOLVE_AXIS_END_Y_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_y_ctrl)
	# Axis Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	axis_end_group.add_child(z_lbl)
	axis_end_z_ctrl = NumberEdit.new()
	axis_end_z_ctrl.set_text("1")
	axis_end_z_ctrl.hint_tooltip = tr("REVOLVE_AXIS_END_Z_CTRL_HINT_TOOLTIP")
	axis_end_group.add_child(axis_end_z_ctrl)

	end_group.add_child(axis_end_group)
	add_child(end_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	combine_ctrl = CheckBox.new()
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)
	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)

	# Allow the user to flip the direction of the operation
	var invert_group = HBoxContainer.new()
	var invert_lbl = Label.new()
	invert_lbl.set_text("Invert: ")
	invert_group.add_child(invert_lbl)
	invert_ctrl = CheckBox.new()
	invert_ctrl.pressed = false
	invert_ctrl.hint_tooltip = tr("INVERT_CTRL_HINT_TOOLTIP")
	invert_group.add_child(invert_ctrl)
	add_child(invert_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not angle_ctrl.is_valid:
		return false
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

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Allow flipping the direction of the operation
	if invert_ctrl.pressed:
		complete += wp_template.format({
			"invert": invert_ctrl.pressed
		})

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
		"axis_end": axis_end_str,
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

	# Workplane (invert) edit
	rgx.compile(wp_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var invert = res.get_string()
		invert_ctrl.pressed = true if invert == "True" else false
