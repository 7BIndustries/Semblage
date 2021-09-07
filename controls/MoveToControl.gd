extends VBoxContainer

class_name MoveToControl

var prev_template = null

var template = ".moveTo({xDist},{yDist})"

const dims_edit_rgx = "(?<=.moveTo\\()(.*?)(?=\\))"

var x_dist_ctrl = null
var y_dist_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# X coord
	var x_dims_group = HBoxContainer.new()
	var x_dist_lbl = Label.new()
	x_dist_lbl.set_text("X Distance: ")
	x_dims_group.add_child(x_dist_lbl)
	x_dist_ctrl = NumberEdit.new()
	x_dist_ctrl.CanBeNegative = true
	x_dist_ctrl.set_text("1.0")
	x_dist_ctrl.hint_tooltip = tr("MOVETO_X_DIST_CTRL_HINT_TOOLTIP")
	x_dims_group.add_child(x_dist_ctrl)
	add_child(x_dims_group)

	# Y coord
	var y_dims_group = HBoxContainer.new()
	var y_dist_lbl = Label.new()
	y_dist_lbl.set_text("Y Distance: ")
	y_dims_group.add_child(y_dist_lbl)
	y_dist_ctrl = NumberEdit.new()
	y_dist_ctrl.CanBeNegative = true
	y_dist_ctrl.set_text("1.0")
	y_dist_ctrl.hint_tooltip = tr("MOVETO_Y_DIST_CTRL_HINT_TOOLTIP")
	y_dims_group.add_child(y_dist_ctrl)
	add_child(y_dims_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not x_dist_ctrl.is_valid:
		return false
	if not y_dist_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"xDist": x_dist_ctrl.get_text(),
		"yDist": y_dist_ctrl.get_text()
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

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var xy = res.get_string().split(",")
		x_dist_ctrl.set_text(xy[0])
		y_dist_ctrl.set_text(xy[1])
