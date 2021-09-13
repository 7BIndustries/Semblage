extends VBoxContainer

class_name RectControl

var prev_template = null

var template = ".rect({xLen},{yLen},centered={centered},forConstruction={for_construction})"

const dims_edit_rgx = "(?<=.rect\\()(.*?)(?=,centered)"
const centered_edit_rgx = "(?<=centered\\=)(.*?)(?=\\,)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var x_length_group = HBoxContainer.new()
	var y_length_group = HBoxContainer.new()

	# Width (X length)
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("Width: ")
	x_length_group.add_child(x_length_lbl)
	var x_length_ctrl = NumberEdit.new()
	x_length_ctrl.name = "x_length_ctrl"
	x_length_ctrl.size_flags_horizontal = 3
	x_length_ctrl.set_text("1.0")
	x_length_ctrl.hint_tooltip = tr("RECT_X_LENGTH_CTRL_HINT_TOOLTIP")
	x_length_group.add_child(x_length_ctrl)
	# Height (Y length)
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Height: ")
	y_length_group.add_child(y_length_lbl)
	var y_length_ctrl = NumberEdit.new()
	y_length_ctrl.name = "y_length_ctrl"
	y_length_ctrl.size_flags_horizontal = 3
	y_length_ctrl.set_text("1.0")
	y_length_ctrl.hint_tooltip = tr("RECT_Y_LENGTH_CTRL_HINT_TOOLTIP")
	y_length_group.add_child(y_length_ctrl)

	add_child(x_length_group)
	add_child(y_length_group)

	# Add the centered control
	var centered_group = HBoxContainer.new()
	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered: ")
	centered_group.add_child(centered_lbl)
	var centered_ctrl = CheckBox.new()
	centered_ctrl.name = "centered_ctrl"
	centered_ctrl.pressed = true
	centered_ctrl.hint_tooltip = tr("RECT_CENTERED_CTRL_HINT_TOOLTIP")
	centered_group.add_child(centered_ctrl)

	add_child(centered_group)

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
	var x_length_ctrl = find_node("x_length_ctrl", true, false)
	var y_length_ctrl = find_node("y_length_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not x_length_ctrl.is_valid:
		return false
	if not y_length_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var x_length_ctrl = find_node("x_length_ctrl", true, false)
	var y_length_ctrl = find_node("y_length_ctrl", true, false)
	var centered_ctrl = find_node("centered_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"xLen": x_length_ctrl.get_text(),
		"yLen": y_length_ctrl.get_text(),
		"centered": centered_ctrl.pressed,
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
	var x_length_ctrl = find_node("x_length_ctrl", true, false)
	var y_length_ctrl = find_node("y_length_ctrl", true, false)
	var centered_ctrl = find_node("centered_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var lw = res.get_string().split(",")
		x_length_ctrl.set_text(lw[0])
		y_length_ctrl.set_text(lw[1])

	# Centered
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cen = res.get_string()
		centered_ctrl.pressed = true if cen == "True" else false

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
