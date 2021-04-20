extends VBoxContainer

class_name EllipseControl

var prev_template = null

var template = ".ellipse({x_radius},{y_radius},rotation_angle={rotation_angle},forConstruction={forConstruction})"

var radius_edit_rgx = "(?<=.ellipseArc\\()(.*?)(?=,angle1)"
var rotation_angle_edit_rgx = "(?<=rotation_angle\\=)(.*?)(?=\\,sense)"
var for_construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"

var x_radius_ctrl = null
var y_radius_ctrl = null
var rotation_angle_ctrl = null
var for_construction_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# X Radius
	var x_radius_group = HBoxContainer.new()
	var x_radius_lbl = Label.new()
	x_radius_lbl.set_text("X Radius: ")
	x_radius_group.add_child(x_radius_lbl)
	x_radius_ctrl = NumberEdit.new()
	x_radius_ctrl.set_text("5.0")
	x_radius_group.add_child(x_radius_ctrl)
	add_child(x_radius_group)

	# Y Radius
	var y_radius_group = HBoxContainer.new()
	var y_radius_lbl = Label.new()
	y_radius_lbl.set_text("Y Radius: ")
	y_radius_group.add_child(y_radius_lbl)
	y_radius_ctrl = NumberEdit.new()
	y_radius_ctrl.set_text("10.0")
	y_radius_group.add_child(y_radius_ctrl)
	add_child(y_radius_group)

	# Rotation angle
	var rotation_angle_group = HBoxContainer.new()
	var rotation_angle_lbl = Label.new()
	rotation_angle_lbl.set_text("Rotation Angle: ")
	rotation_angle_group.add_child(rotation_angle_lbl)
	rotation_angle_ctrl = NumberEdit.new()
	rotation_angle_ctrl.MaxValue = 360.0
	rotation_angle_ctrl.set_text("0.0")
	rotation_angle_group.add_child(rotation_angle_ctrl)
	add_child(rotation_angle_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not x_radius_ctrl.is_valid:
		return false
	if not y_radius_ctrl.is_valid:
		return false
	if not rotation_angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"x_radius": x_radius_ctrl.get_text(),
		"y_radius": y_radius_ctrl.get_text(),
		"rotation_angle": rotation_angle_ctrl.get_text(),
		"forConstruction": for_construction_ctrl.pressed
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

	# X and Y Radii
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the X and Y radii controls
		var xy = res.get_string().split(",")
		x_radius_ctrl.set_text(xy[0])
		y_radius_ctrl.set_text(xy[1])

	# Rotation angle
	rgx.compile(rotation_angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the rotation angle controls
		var rotation_angle = res.get_string()
		rotation_angle_ctrl.set_text(rotation_angle)

	# For construction
	rgx.compile(for_construction_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
