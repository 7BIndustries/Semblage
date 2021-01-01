extends VBoxContainer

class_name BoxControl

var length_ctrl = null
var width_ctrl = null
var height_ctrl = null
var cen_x_ctrl = null
var cen_y_ctrl = null
var cen_z_ctrl = null

var prev_template = null

var template = ".box({length},{width},{height},centered=({centered_x},{centered_y},{centered_z}))"

var dims_edit_rgx = "(?<=.box\\()(.*?)(?=,centered)"
var centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\))"

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
	length_ctrl = LineEdit.new()
	length_ctrl.set_text("10.0")
	size_group.add_child(length_ctrl)
	# Width
	var width_ctrl_lbl = Label.new()
	width_ctrl_lbl.set_text("Width: ")
	size_group.add_child(width_ctrl_lbl)
	width_ctrl = LineEdit.new()
	width_ctrl.set_text("10.0")
	size_group.add_child(width_ctrl)
	# Height
	var height_ctrl_lbl = Label.new()
	height_ctrl_lbl.set_text("Height: ")
	size_group.add_child(height_ctrl_lbl)
	height_ctrl = LineEdit.new()
	height_ctrl.set_text("10.0")
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
	centered_group.add_child(cen_x_ctrl)
	# Y
	var cen_y_lbl = Label.new()
	cen_y_lbl.set_text("Y: ")
	centered_group.add_child(cen_y_lbl)
	cen_y_ctrl = CheckBox.new()
	cen_y_ctrl.pressed = true
	centered_group.add_child(cen_y_ctrl)
	# Z
	var cen_z_lbl = Label.new()
	cen_z_lbl.set_text("Z: ")
	centered_group.add_child(cen_z_lbl)
	cen_z_ctrl = CheckBox.new()
	cen_z_ctrl.pressed = true
	centered_group.add_child(cen_z_ctrl)

	add_child(centered_group)


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
		"centered_z": cen_z_ctrl.pressed
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
