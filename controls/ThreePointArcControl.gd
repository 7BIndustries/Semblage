extends VBoxContainer

class_name ThreePointArcControl

var prev_template = null

var template = ".threePointArc(point1=({point_1_x},{point_1_y}),point2=({point_2_x},{point_2_y}),forConstruction={for_construction})"

const point1_edit_rgx = "(?<=point1\\=\\()(.*?)(?=\\),point2)"
const point2_edit_rgx = "(?<=point2\\=\\()(.*?)(?=\\),forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"

var point_1_x_ctrl = null
var point_1_y_ctrl = null
var point_2_x_ctrl = null
var point_2_y_ctrl = null
var for_construction_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var point_1_group_lbl = Label.new()
	point_1_group_lbl.set_text("Point 1")
	add_child(point_1_group_lbl)

	# Add the point 1 vector controls
	var point_1_group = HBoxContainer.new()
	# Point 1 X
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	point_1_group.add_child(x_length_lbl)
	point_1_x_ctrl = NumberEdit.new()
	point_1_x_ctrl.CanBeNegative = true
	point_1_x_ctrl.set_text("4.0")
	point_1_x_ctrl.hint_tooltip = tr("THREE_POINT_ARC_POINT_1_X_CTRL_HINT_TOOLTIP")
	point_1_group.add_child(point_1_x_ctrl)
	# Point 1 Y
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	point_1_group.add_child(y_length_lbl)
	point_1_y_ctrl = NumberEdit.new()
	point_1_y_ctrl.CanBeNegative = true
	point_1_y_ctrl.set_text("0.0")
	point_1_y_ctrl.hint_tooltip = tr("THREE_POINT_ARC_POINT_1_Y_CTRL_HINT_TOOLTIP")
	point_1_group.add_child(point_1_y_ctrl)

	add_child(point_1_group)

	var point_2_group_lbl = Label.new()
	point_2_group_lbl.set_text("Point 2")
	add_child(point_2_group_lbl)

	# Add the point 1 vector controls
	var point_2_group = HBoxContainer.new()
	# Point 2 X
	x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	point_2_group.add_child(x_length_lbl)
	point_2_x_ctrl = NumberEdit.new()
	point_2_x_ctrl.CanBeNegative = true
	point_2_x_ctrl.set_text("0.0")
	point_2_x_ctrl.hint_tooltip = tr("THREE_POINT_ARC_POINT_2_X_CTRL_HINT_TOOLTIP")
	point_2_group.add_child(point_2_x_ctrl)
	# Point 2 Y
	y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	point_2_group.add_child(y_length_lbl)
	point_2_y_ctrl = NumberEdit.new()
	point_2_y_ctrl.CanBeNegative = true
	point_2_y_ctrl.set_text("-4.0")
	point_2_y_ctrl.hint_tooltip = tr("THREE_POINT_ARC_POINT_2_Y_CTRL_HINT_TOOLTIP")
	point_2_group.add_child(point_2_y_ctrl)

	add_child(point_2_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)

	add_child(const_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not point_1_x_ctrl.is_valid:
		return false
	if not point_1_y_ctrl.is_valid:
		return false
	if not point_2_x_ctrl.is_valid:
		return false
	if not point_2_y_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"point_1_x": point_1_x_ctrl.get_text(),
		"point_1_y": point_1_y_ctrl.get_text(),
		"point_2_x": point_2_x_ctrl.get_text(),
		"point_2_y": point_2_y_ctrl.get_text(),
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
	prev_template = text_line

	var rgx = RegEx.new()

	# Point 1 dimensions
	rgx.compile(point1_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the point 1 controls
		var xyz = res.get_string().split(",")
		point_1_x_ctrl.set_text(xyz[0])
		point_1_y_ctrl.set_text(xyz[1])

	# Point 2 dimensions
	rgx.compile(point2_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the point 2 controls
		var xyz = res.get_string().split(",")
		point_2_x_ctrl.set_text(xyz[0])
		point_2_y_ctrl.set_text(xyz[1])

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
