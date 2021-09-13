extends VBoxContainer

class_name LineToControl

var prev_template = null

var template = ".lineTo({x},{y},forConstruction={for_construction})"

const dims_edit_rgx = "(?<=.lineTo\\()(.*?)(?=,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var x_group = HBoxContainer.new()
	var y_group = HBoxContainer.new()

	# X coord
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	x_group.add_child(x_lbl)
	var x_ctrl = NumberEdit.new()
	x_ctrl.name = "x_ctrl"
	x_ctrl.size_flags_horizontal = 3
	x_ctrl.set_text("1.0")
	x_ctrl.hint_tooltip = tr("LINETO_X_DIST_CTRL_HINT_TOOLTIP")
	x_group.add_child(x_ctrl)
	add_child(x_group)
	# Y coord
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	y_group.add_child(y_lbl)
	var y_ctrl = NumberEdit.new()
	y_ctrl.name = "y_ctrl"
	y_ctrl.size_flags_horizontal = 3
	y_ctrl.set_text("1.0")
	y_ctrl.hint_tooltip = tr("LINETO_Y_DIST_CTRL_HINT_TOOLTIP")
	y_group.add_child(y_ctrl)
	add_child(y_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	var for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.name = "for_construction_ctrl"
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)

	add_child(const_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var x_ctrl = find_node("x_ctrl", true, false)
	var y_ctrl = find_node("y_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not x_ctrl.is_valid:
		return false
	if not y_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var x_ctrl = find_node("x_ctrl", true, false)
	var y_ctrl = find_node("y_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"x": x_ctrl.get_text(),
		"y": y_ctrl.get_text(),
		"for_construction": for_construction_ctrl.pressed
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
	var x_ctrl = find_node("x_ctrl", true, false)
	var y_ctrl = find_node("y_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var xy = res.get_string().split(",")
		x_ctrl.set_text(xy[0])
		y_ctrl.set_text(xy[1])

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
