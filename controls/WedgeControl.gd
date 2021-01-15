extends VBoxContainer

class_name WedgeControl

var dx_ctrl = null
var dy_ctrl = null
var dz_ctrl = null
var xmin_ctrl = null
var zmin_ctrl = null
var xmax_ctrl = null
var zmax_ctrl = null
var pnt_x_ctrl = null
var pnt_y_ctrl = null
var pnt_z_ctrl = null
var dir_x_ctrl = null
var dir_y_ctrl = null
var dir_z_ctrl = null
var centered_x_ctrl = null
var centered_y_ctrl = null
var centered_z_ctrl = null
var combine_ctrl = null
var clean_ctrl = null

var prev_template = null

var template = ".wedge({dx},{dy},{dz},{xmin},{zmin},{xmax},{zmax},pnt=({pnt_x},{pnt_y},{pnt_z}),dir=({dir_x},{dir_y},{dir_z}),centered=({centered_x},{centered_y},{centered_z}),combine={combine},clean={clean})"

var dims_edit_rgx = "(?<=.wedge\\()(.*?)(?=,pnt)"
var pnt_edit_rgx = "(?<=pnt\\=\\()(.*?)(?=\\),dir)"
var dir_edit_rgx = "(?<=dir\\=\\()(.*?)(?=\\),centered)"
var centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\),combine)"
var combine_edit_rgx = "(?<=combine\\=\\()(.*?)(?=\\),clean)"
var clean_edit_rgx = "(?<=clean\\=\\()(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Distance controls
	var dist_group = VBoxContainer.new()
	var dist_lbl = Label.new()
	dist_lbl.set_text("Distance")
	dist_group.add_child(dist_lbl)
	var dir_group = HBoxContainer.new()
	# Distance X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	dir_group.add_child(x_lbl)
	dx_ctrl = LineEdit.new()
	dx_ctrl.set_text("2.5")
	dir_group.add_child(dx_ctrl)
	# Distance Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	dir_group.add_child(y_lbl)
	dy_ctrl = LineEdit.new()
	dy_ctrl.set_text("5.0")
	dir_group.add_child(dy_ctrl)
	# Distance Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	dir_group.add_child(z_lbl)
	dz_ctrl = LineEdit.new()
	dz_ctrl.set_text("1.0")
	dir_group.add_child(dz_ctrl)

	dist_group.add_child(dir_group)
	add_child(dist_group)

	# Minimum location
	var minimum_group = VBoxContainer.new()
	var min_lbl = Label.new()
	min_lbl.set_text("Minimum Location")
	minimum_group.add_child(min_lbl)
	var min_group = HBoxContainer.new()
	# Distance X
	x_lbl = Label.new()
	x_lbl.set_text("X: ")
	min_group.add_child(x_lbl)
	xmin_ctrl = LineEdit.new()
	xmin_ctrl.set_text("2.5")
	min_group.add_child(xmin_ctrl)
	# Distance Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	min_group.add_child(z_lbl)
	zmin_ctrl = LineEdit.new()
	zmin_ctrl.set_text("1.0")
	min_group.add_child(zmin_ctrl)

	minimum_group.add_child(min_group)
	add_child(minimum_group)

	# Maximum distance
	var maximum_group = VBoxContainer.new()
	var max_lbl = Label.new()
	max_lbl.set_text("Maximum Location")
	maximum_group.add_child(max_lbl)
	var max_group = HBoxContainer.new()
	# Distance X
	x_lbl = Label.new()
	x_lbl.set_text("X: ")
	max_group.add_child(x_lbl)
	xmax_ctrl = LineEdit.new()
	xmax_ctrl.set_text("2.5")
	max_group.add_child(xmax_ctrl)
	# Distance Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	max_group.add_child(z_lbl)
	zmax_ctrl = LineEdit.new()
	zmax_ctrl.set_text("1.0")
	max_group.add_child(zmax_ctrl)

	maximum_group.add_child(max_group)
	add_child(maximum_group)

	# Point controls
	var point_group = VBoxContainer.new()
	var pnt_lbl = Label.new()
	pnt_lbl.set_text("Origin")
	point_group.add_child(pnt_lbl)
	var pnt_group = HBoxContainer.new()
	# Origin point X
	x_lbl = Label.new()
	x_lbl.set_text("X: ")
	pnt_group.add_child(x_lbl)
	pnt_x_ctrl = LineEdit.new()
	pnt_x_ctrl.set_text("2.5")
	pnt_group.add_child(pnt_x_ctrl)
	# Origin point Y
	y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	pnt_group.add_child(y_lbl)
	pnt_y_ctrl = LineEdit.new()
	pnt_y_ctrl.set_text("5.0")
	pnt_group.add_child(pnt_y_ctrl)
	# Origin point Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	pnt_group.add_child(z_lbl)
	pnt_z_ctrl = LineEdit.new()
	pnt_z_ctrl.set_text("1.0")
	pnt_group.add_child(pnt_z_ctrl)

	point_group.add_child(pnt_group)
	add_child(point_group)

	# Direction controls
	var direction_group = VBoxContainer.new()
	var dir_lbl = Label.new()
	dir_lbl.set_text("Direction")
	direction_group.add_child(dir_lbl)
	var d_group = HBoxContainer.new()
	# Direction X
	x_lbl = Label.new()
	x_lbl.set_text("X: ")
	d_group.add_child(x_lbl)
	dir_x_ctrl = LineEdit.new()
	dir_x_ctrl.set_text("0")
	d_group.add_child(dir_x_ctrl)
	# Direction Y
	y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	d_group.add_child(y_lbl)
	dir_y_ctrl = LineEdit.new()
	dir_y_ctrl.set_text("0")
	d_group.add_child(dir_y_ctrl)
	# Direction Z
	z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	d_group.add_child(z_lbl)
	dir_z_ctrl = LineEdit.new()
	dir_z_ctrl.set_text("1")
	d_group.add_child(dir_z_ctrl)

	direction_group.add_child(d_group)
	add_child(direction_group)

	# Add the wedge centering controls
	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered")
	add_child(centered_lbl)
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
		"dx": dx_ctrl.get_text(),
		"dy": dy_ctrl.get_text(),
		"dz": dz_ctrl.get_text(),
		"xmin": xmin_ctrl.get_text(),
		"zmin": zmin_ctrl.get_text(),
		"xmax": xmax_ctrl.get_text(),
		"zmax": zmax_ctrl.get_text(),
		"pnt_x": pnt_x_ctrl.get_text(),
		"pnt_y": pnt_y_ctrl.get_text(),
		"pnt_z": pnt_z_ctrl.get_text(),
		"dir_x": dir_x_ctrl.get_text(),
		"dir_y": dir_y_ctrl.get_text(),
		"dir_z": dir_z_ctrl.get_text(),
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

	# The wedge dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the wedge dimension controls
		var dims = res.get_string().split(",")
		dx_ctrl.set_text(dims[0])
		dy_ctrl.set_text(dims[1])
		dz_ctrl.set_text(dims[2])
		xmin_ctrl.set_text(dims[3])
		zmin_ctrl.set_text(dims[4])
		xmax_ctrl.set_text(dims[5])
		zmax_ctrl.set_text(dims[6])

	# The wedge origin
	rgx.compile(pnt_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the wedge origin controls
		var pnts = res.get_string().split(",")
		pnt_x_ctrl.set_text(pnts[0])
		pnt_y_ctrl.set_text(pnts[1])
		pnt_z_ctrl.set_text(pnts[2])

	# The wedge direction
	rgx.compile(dir_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the wedge direction controls
		var dirs = res.get_string().split(",")
		dir_x_ctrl.set_text(dirs[0])
		dir_y_ctrl.set_text(dirs[1])
		dir_z_ctrl.set_text(dirs[2])

	# Wedge centering booleans
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
