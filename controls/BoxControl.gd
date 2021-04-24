extends VBoxContainer

class_name BoxControl

var length_ctrl = null
var width_ctrl = null
var height_ctrl = null
var cen_x_ctrl = null
var cen_y_ctrl = null
var cen_z_ctrl = null
var combine_ctrl = null
var clean_ctrl = null

var prev_template = null

var template = ".box({length},{width},{height},centered=({centered_x},{centered_y},{centered_z}),combine={combine},clean={clean})"

var dims_edit_rgx = "(?<=.box\\()(.*?)(?=,centered)"
var centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\)\\,)"
var combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,)"
var clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"

func _ready():
	# Add a label for the box size group controls
	var size_lbl = Label.new()
	size_lbl.set_text("Size")
	add_child(size_lbl)

	# Add the box size controls
	var size_group = HBoxContainer.new()
	var length_ctrl_lbl = Label.new()
	# Length
	length_ctrl_lbl.set_text("Length: ")
	size_group.add_child(length_ctrl_lbl)
	length_ctrl = NumberEdit.new()
	length_ctrl.set_text("10.0")
	length_ctrl.hint_tooltip = "Box size in X direction."
	size_group.add_child(length_ctrl)
	# Width
	var width_ctrl_lbl = Label.new()
	width_ctrl_lbl.set_text("Width: ")
	size_group.add_child(width_ctrl_lbl)
	width_ctrl = NumberEdit.new()
	width_ctrl.set_text("10.0")
	width_ctrl.hint_tooltip = "Box size in Y direction."
	size_group.add_child(width_ctrl)
	# Height
	var height_ctrl_lbl = Label.new()
	height_ctrl_lbl.set_text("Height: ")
	size_group.add_child(height_ctrl_lbl)
	height_ctrl = NumberEdit.new()
	height_ctrl.set_text("10.0")
	height_ctrl.hint_tooltip = "Box size in Z direction."
	size_group.add_child(height_ctrl)
	
	add_child(size_group)

	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered")
	add_child(centered_lbl)

	# Add the box centering controls
	var centered_group = HBoxContainer.new()
	# X
	var cen_x_lbl = Label.new()
	cen_x_lbl.set_text("X: ")
	centered_group.add_child(cen_x_lbl)
	cen_x_ctrl = CheckBox.new()
	cen_x_ctrl.pressed = true
	cen_x_ctrl.hint_tooltip = "If True, the box will be centered around the X axis reference point.\nIf False, the corner of the box will be on the reference point and it\nwill extend in the positive x direction."
	centered_group.add_child(cen_x_ctrl)
	# Y
	var cen_y_lbl = Label.new()
	cen_y_lbl.set_text("Y: ")
	centered_group.add_child(cen_y_lbl)
	cen_y_ctrl = CheckBox.new()
	cen_y_ctrl.pressed = true
	cen_y_ctrl.hint_tooltip = "If True, the box will be centered around the Y axis reference point.\nIf False, the corner of the box will be on the reference point and it\nwill extend in the positive y direction."
	centered_group.add_child(cen_y_ctrl)
	# Z
	var cen_z_lbl = Label.new()
	cen_z_lbl.set_text("Z: ")
	centered_group.add_child(cen_z_lbl)
	cen_z_ctrl = CheckBox.new()
	cen_z_ctrl.pressed = true
	cen_z_ctrl.hint_tooltip = "If True, the box will be centered around the Z axis reference point.\nIf False, the corner of the box will be on the reference point and it\nwill extend in the positive z direction."
	centered_group.add_child(cen_z_ctrl)

	add_child(centered_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	combine_ctrl = CheckBox.new()
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = "Whether the box should be combined with other solids on the stack."
	combine_group.add_child(combine_ctrl)

	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = "Whether to clean the resulting geometry. If the CAD kernel\nis yielding invalid results, try disabling this."
	clean_group.add_child(clean_ctrl)

	add_child(clean_group)

"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not length_ctrl.is_valid:
		return false
	if not width_ctrl.is_valid:
		return false
	if not height_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():	
	var complete = template.format({
		"length": length_ctrl.get_text(),
		"width": width_ctrl.get_text(),
		"height": height_ctrl.get_text(),
		"centered_x": cen_x_ctrl.pressed,
		"centered_y": cen_y_ctrl.pressed,
		"centered_z": cen_z_ctrl.pressed,
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

	# The box dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var lwh = res.get_string().split(",")
		length_ctrl.set_text(lwh[0])
		width_ctrl.set_text(lwh[1])
		height_ctrl.set_text(lwh[2])

	# Box centering booleans
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the centering controls
		var lwh = res.get_string().split(",")
		cen_x_ctrl.pressed = true if lwh[0] == "True" else false
		cen_y_ctrl.pressed = true if lwh[1] == "True" else false
		cen_z_ctrl.pressed = true if lwh[2] == "True" else false

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
