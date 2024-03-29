extends VBoxContainer

class_name LineControl

var prev_template = null

var template = ".line({xDist},{yDist},forConstruction={for_construction})"

const dims_edit_rgx = "(?<=.line\\()(.*?)(?=,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var x_dist_group = HBoxContainer.new()
	var y_dist_group = HBoxContainer.new()

	# X coord
	var x_dist_lbl = Label.new()
	x_dist_lbl.set_text("X Distance: ")
	x_dist_group.add_child(x_dist_lbl)
	var x_dist_ctrl = NumberEdit.new()
	x_dist_ctrl.name = "x_dist_ctrl"
	x_dist_ctrl.size_flags_horizontal = 3
	x_dist_ctrl.set_text("1.0")
	x_dist_ctrl.hint_tooltip = tr("LINE_X_DIST_CTRL_HINT_TOOLTIP")
	x_dist_group.add_child(x_dist_ctrl)
	add_child(x_dist_group)
	# Y coord
	var y_dist_lbl = Label.new()
	y_dist_lbl.set_text("Y Distance: ")
	y_dist_group.add_child(y_dist_lbl)
	var y_dist_ctrl = NumberEdit.new()
	y_dist_ctrl.name = "y_dist_ctrl"
	y_dist_ctrl.size_flags_horizontal = 3
	y_dist_ctrl.set_text("1.0")
	y_dist_ctrl.hint_tooltip = tr("LINE_Y_DIST_CTRL_HINT_TOOLTIP")
	y_dist_group.add_child(y_dist_ctrl)
	add_child(y_dist_group)

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
	var x_dist_ctrl = find_node("x_dist_ctrl", true, false)
	var y_dist_ctrl = find_node("y_dist_ctrl", true, false)

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
	var x_dist_ctrl = find_node("x_dist_ctrl", true, false)
	var y_dist_ctrl = find_node("y_dist_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"xDist": x_dist_ctrl.get_text(),
		"yDist": y_dist_ctrl.get_text(),
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
	var x_dist_ctrl = find_node("x_dist_ctrl", true, false)
	var y_dist_ctrl = find_node("y_dist_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

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

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
