extends VBoxContainer

class_name CenterControl

var prev_template = null

var template = ".center({x_coord},{y_coord})"

const dims_edit_rgx = "(?<=.center\\()(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the X and Y coordinate control groups
	var x_group = HBoxContainer.new()
	var y_group = HBoxContainer.new()

	# X coordinate
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	x_group.add_child(x_length_lbl)
	var x_coord_ctrl = NumberEdit.new()
	x_coord_ctrl.name = "x_coord_ctrl"
	x_coord_ctrl.size_flags_horizontal = 3
	x_coord_ctrl.set_text("1.0")
	x_coord_ctrl.hint_tooltip = tr("CENTER_X_COORD_CTRL_HINT_TOOLTIP")
	x_group.add_child(x_coord_ctrl)
	add_child(x_group)
	# Y coordinate
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	y_group.add_child(y_length_lbl)
	var y_coord_ctrl = NumberEdit.new()
	y_coord_ctrl.name = "y_coord_ctrl"
	y_coord_ctrl.size_flags_horizontal = 3
	y_coord_ctrl.set_text("1.0")
	y_coord_ctrl.hint_tooltip = tr("CENTER_Y_COORD_CTRL_HINT_TOOLTIP")
	y_group.add_child(y_coord_ctrl)
	add_child(y_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var x_coord_ctrl = find_node("x_coord_ctrl", true, false)
	var y_coord_ctrl = find_node("y_coord_ctrl", true, false)

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
	var x_coord_ctrl = find_node("x_coord_ctrl", true, false)
	var y_coord_ctrl = find_node("y_coord_ctrl", true, false)

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
	var x_coord_ctrl = find_node("x_coord_ctrl", true, false)
	var y_coord_ctrl = find_node("y_coord_ctrl", true, false)

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
