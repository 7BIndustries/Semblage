extends VBoxContainer

class_name CenterControl

var prev_template = null

var template = ".center({x_coord},{y_coord})"

const dims_edit_rgx = "(?<=.center\\()(.*?)(?=\\))"

var x_coord_ctrl = null
var y_coord_ctrl = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the X and Y coordinate controls
	var dims_group = HBoxContainer.new()

	# X coordinate
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	dims_group.add_child(x_length_lbl)
	x_coord_ctrl = NumberEdit.new()
	x_coord_ctrl.set_text("1.0")
	x_coord_ctrl.hint_tooltip = ToolTips.get_tts().center_x_coord_ctrl_hint_tooltip
	dims_group.add_child(x_coord_ctrl)
	# Y coordinate
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	dims_group.add_child(y_length_lbl)
	y_coord_ctrl = NumberEdit.new()
	y_coord_ctrl.set_text("1.0")
	y_coord_ctrl.hint_tooltip = ToolTips.get_tts().center_y_coord_ctrl_hint_tooltip
	dims_group.add_child(y_coord_ctrl)

	add_child(dims_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not x_coord_ctrl.is_valid:
		return false
	if not y_coord_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = template.format({
		"x_coord": x_coord_ctrl.get_text(),
		"y_coord": y_coord_ctrl.get_text()
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

	# Center X and Y locations
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the center location controls
		var xy = res.get_string().split(",")
		x_coord_ctrl.set_text(xy[0])
		y_coord_ctrl.set_text(xy[1])
