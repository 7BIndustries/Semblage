extends VBoxContainer

class_name SphereControl

var radius_ctrl = null
var direct_x_ctrl = null
var direct_y_ctrl = null
var direct_z_ctrl = null
var angle1_ctrl = null
var angle2_ctrl = null
var angle3_ctrl = null
var centered_x_ctrl = null
var centered_y_ctrl = null
var centered_z_ctrl = null
var combine_ctrl = null
var clean_ctrl = null

var prev_template = null

var template = ".sphere({radius},direct=({direct_x},{direct_y},{direct_z}),angle1={angle1},angle2={angle2},angle3={angle3},centered=({centered_x},{centered_y},{centered_z}),combine={combine},clean={clean})"

var radius_edit_rgx = "(?<=.radius\\()(.*?)(?=,direct)"
var direct_edit_rgx = "(?<=direct\\=\\()(.*?)(?=\\),angle1)"
var angle1_edit_rgx = "(?<=angle1\\=\\()(.*?)(?=\\),angle2)"
var angle2_edit_rgx = "(?<=angle1\\=\\()(.*?)(?=\\),angle3)"
var angle3_edit_rgx = "(?<=angle1\\=\\()(.*?)(?=\\),centered)"
var centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\),combine)"
var combine_edit_rgx = "(?<=combine\\=\\()(.*?)(?=\\),clean)"
var clean_edit_rgx = "(?<=clean\\=\\()(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Radius
	var radius_group = HBoxContainer.new()
	var radius_ctrl_lbl = Label.new()
	radius_ctrl_lbl.set_text("Radius: ")
	radius_group.add_child(radius_ctrl_lbl)
	radius_ctrl = LineEdit.new()
	radius_ctrl.set_text("10.0")
	radius_group.add_child(radius_ctrl)
	add_child(radius_group)

	# The advanced workplane controls
	var direct_group = VBoxContainer.new()
	var direct_lbl = Label.new()
	direct_lbl.set_text("Direction")
	direct_group.add_child(direct_lbl)
	var dir_group = HBoxContainer.new()
	# Direction X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	dir_group.add_child(x_lbl)
	direct_x_ctrl = LineEdit.new()
	direct_x_ctrl.set_text("0")
	dir_group.add_child(direct_x_ctrl)
	# Direction Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	dir_group.add_child(y_lbl)
	direct_y_ctrl = LineEdit.new()
	direct_y_ctrl.set_text("0")
	dir_group.add_child(direct_y_ctrl)
	# Direction Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	dir_group.add_child(z_lbl)
	direct_z_ctrl = LineEdit.new()
	direct_z_ctrl.set_text("1")
	dir_group.add_child(direct_z_ctrl)

	direct_group.add_child(dir_group)
	add_child(direct_group)

	# Angle 1
	var angle1_group = HBoxContainer.new()
	var angle1_ctrl_lbl = Label.new()
	angle1_ctrl_lbl.set_text("Angle 1: ")
	angle1_group.add_child(angle1_ctrl_lbl)
	angle1_ctrl = LineEdit.new()
	angle1_ctrl.set_text("-90")
	angle1_group.add_child(angle1_ctrl)
	add_child(angle1_group)

	# Angle 2
	var angle2_group = HBoxContainer.new()
	var angle2_ctrl_lbl = Label.new()
	angle2_ctrl_lbl.set_text("Angle 2: ")
	angle2_group.add_child(angle2_ctrl_lbl)
	angle2_ctrl = LineEdit.new()
	angle2_ctrl.set_text("90.0")
	angle2_group.add_child(angle2_ctrl)
	add_child(angle2_group)

	# Angle 3
	var angle3_group = HBoxContainer.new()
	var angle3_ctrl_lbl = Label.new()
	angle3_ctrl_lbl.set_text("Angle 3: ")
	angle3_group.add_child(angle3_ctrl_lbl)
	angle3_ctrl = LineEdit.new()
	angle3_ctrl.set_text("360.0")
	angle3_group.add_child(angle3_ctrl)
	add_child(angle3_group)

	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered")
	add_child(centered_lbl)

	# Add the box centering controls
	var centered_group = HBoxContainer.new()
	# X
	var cen_x_lbl = Label.new()
	cen_x_lbl.set_text("X: ")
	centered_group.add_child(cen_x_lbl)
	centered_x_ctrl = CheckBox.new()
	centered_x_ctrl.pressed = true
	centered_group.add_child(centered_x_ctrl)
	# Y
	var cen_y_lbl = Label.new()
	cen_y_lbl.set_text("Y: ")
	centered_group.add_child(cen_y_lbl)
	centered_y_ctrl = CheckBox.new()
	centered_y_ctrl.pressed = true
	centered_group.add_child(centered_y_ctrl)
	# Z
	var cen_z_lbl = Label.new()
	cen_z_lbl.set_text("Z: ")
	centered_group.add_child(cen_z_lbl)
	centered_z_ctrl = CheckBox.new()
	centered_z_ctrl.pressed = true
	centered_group.add_child(centered_z_ctrl)
	add_child(centered_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	combine_ctrl = CheckBox.new()
	combine_ctrl.pressed = true
	combine_group.add_child(combine_ctrl)
	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)


"""
Fills out the template and returns it.
"""
func get_completed_template():	
	var complete = template.format({
		"radius": radius_ctrl.get_text(),
		"direct_x": direct_x_ctrl.get_text(),
		"direct_y": direct_y_ctrl.get_text(),
		"direct_z": direct_z_ctrl.get_text(),
		"angle1": angle1_ctrl.get_text(),
		"angle2": angle2_ctrl.get_text(),
		"angle3": angle3_ctrl.get_text(),
		"centered_x": centered_x_ctrl.pressed,
		"centered_y": centered_y_ctrl.pressed,
		"centered_z": centered_z_ctrl.pressed,
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

	# The sphere radius
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# The direction values
	rgx.compile(direct_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the xdir X, Y and Z controls
		var xyz = res.get_string().split(",")
		direct_x_ctrl.set_text(xyz[0])
		direct_y_ctrl.set_text(xyz[1])
		direct_z_ctrl.set_text(xyz[2])

	# Angle 1
	rgx.compile(angle1_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle1_ctrl.set_text(angle)

	# Angle 2
	rgx.compile(angle2_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle2_ctrl.set_text(angle)

	# Angle 3
	rgx.compile(angle3_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle control
		var angle = res.get_string()
		angle3_ctrl.set_text(angle)

	# Box centering booleans
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the centering controls
		var lwh = res.get_string().split(",")
		centered_x_ctrl.pressed = true if lwh[0] == "True" else false
		centered_y_ctrl.pressed = true if lwh[1] == "True" else false
		centered_z_ctrl.pressed = true if lwh[2] == "True" else false

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
