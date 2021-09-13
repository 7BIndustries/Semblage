extends VBoxContainer

class_name BoxControl

var prev_template = null

var template = ".box({length},{width},{height},centered=({centered_x},{centered_y},{centered_z}),combine={combine},clean={clean})"

const dims_edit_rgx = "(?<=.box\\()(.*?)(?=,centered)"
const centered_edit_rgx = "(?<=centered\\=\\()(.*?)(?=\\)\\,)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"

func _ready():
	# Add the box size controls
	var length_group = HBoxContainer.new()
	var width_group = HBoxContainer.new()
	var height_group = HBoxContainer.new()
	var length_ctrl_lbl = Label.new()
	# Length
	length_ctrl_lbl.set_text("Length: ")
	length_group.add_child(length_ctrl_lbl)
	var length_ctrl = NumberEdit.new()
	length_ctrl.size_flags_horizontal = 3
	length_ctrl.name = "length_ctrl"
	length_ctrl.set_text("10.0")
	length_ctrl.hint_tooltip = tr("BOX_LENGTH_CTRL_HINT_TOOLTIP")
	length_group.add_child(length_ctrl)
	add_child(length_group)
	# Width
	var width_ctrl_lbl = Label.new()
	width_ctrl_lbl.set_text("Width:  ")
	width_group.add_child(width_ctrl_lbl)
	var width_ctrl = NumberEdit.new()
	width_ctrl.size_flags_horizontal = 3
	width_ctrl.name = "width_ctrl"
	width_ctrl.set_text("10.0")
	width_ctrl.hint_tooltip = tr("BOX_WIDTH_CTRL_HINT_TOOLTIP")
	width_group.add_child(width_ctrl)
	add_child(width_group)
	# Height
	var height_ctrl_lbl = Label.new()
	height_ctrl_lbl.set_text("Height: ")
	height_group.add_child(height_ctrl_lbl)
	var height_ctrl = NumberEdit.new()
	height_ctrl.size_flags_horizontal = 3
	height_ctrl.name = "height_ctrl"
	height_ctrl.set_text("10.0")
	height_ctrl.hint_tooltip = tr("BOX_HEIGHT_CTRL_HINT_TOOLTIP")
	height_group.add_child(height_ctrl)
	add_child(height_group)

	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered")
	add_child(centered_lbl)

	# Add the box centering controls
	var centered_group = HBoxContainer.new()
	# X
	var cen_x_lbl = Label.new()
	cen_x_lbl.set_text("X: ")
	centered_group.add_child(cen_x_lbl)
	var cen_x_ctrl = CheckBox.new()
	cen_x_ctrl.name = "cen_x_ctrl"
	cen_x_ctrl.pressed = true
	cen_x_ctrl.hint_tooltip = tr("CEN_X_CTRL_HINT_TOOLTIP")
	centered_group.add_child(cen_x_ctrl)
	# Y
	var cen_y_lbl = Label.new()
	cen_y_lbl.set_text("Y: ")
	centered_group.add_child(cen_y_lbl)
	var cen_y_ctrl = CheckBox.new()
	cen_y_ctrl.name = "cen_y_ctrl"
	cen_y_ctrl.pressed = true
	cen_y_ctrl.hint_tooltip = tr("CEN_Y_CTRL_HINT_TOOLTIP")
	centered_group.add_child(cen_y_ctrl)
	# Z
	var cen_z_lbl = Label.new()
	cen_z_lbl.set_text("Z: ")
	centered_group.add_child(cen_z_lbl)
	var cen_z_ctrl = CheckBox.new()
	cen_z_ctrl.name = "cen_z_ctrl"
	cen_z_ctrl.pressed = true
	cen_z_ctrl.hint_tooltip = tr("CEN_Z_CTRL_HINT_TOOLTIP")
	centered_group.add_child(cen_z_ctrl)

	add_child(centered_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	var combine_ctrl = CheckBox.new()
	combine_ctrl.name = "combine_ctrl"
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)

	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	var clean_ctrl = CheckBox.new()
	clean_ctrl.name = "clean_ctrl"
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)

	add_child(clean_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var length_ctrl = find_node("length_ctrl", true, false)
	var width_ctrl = find_node("width_ctrl", true, false)
	var height_ctrl = find_node("height_ctrl", true, false)

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
	var length_ctrl = find_node("length_ctrl", true, false)
	var width_ctrl = find_node("width_ctrl", true, false)
	var height_ctrl = find_node("height_ctrl", true, false)
	var cen_x_ctrl = find_node("cen_x_ctrl", true, false)
	var cen_y_ctrl = find_node("cen_y_ctrl", true, false)
	var cen_z_ctrl = find_node("cen_z_ctrl", true, false)
	var combine_ctrl = find_node("combine_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

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
	var length_ctrl = find_node("length_ctrl", true, false)
	var width_ctrl = find_node("width_ctrl", true, false)
	var height_ctrl = find_node("height_ctrl", true, false)
	var cen_x_ctrl = find_node("cen_x_ctrl", true, false)
	var cen_y_ctrl = find_node("cen_y_ctrl", true, false)
	var cen_z_ctrl = find_node("cen_z_ctrl", true, false)
	var combine_ctrl = find_node("combine_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

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
