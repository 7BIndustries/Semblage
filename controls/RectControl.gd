extends VBoxContainer

class_name RectControl

var prev_template = null

var template = ".rect({xLen},{yLen},centered={centered},forConstruction={for_construction})"

var dims_edit_rgx = "(?<=.rect\\()(.*?)(?=,centered)"
var centered_edit_rgx = "(?<=centered\\=)(.*?)(?=\\,)"
var const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"

var x_length_ctrl = null
var y_length_ctrl = null
var centered_ctrl = null
var for_construction_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var dims_group = HBoxContainer.new()

	# Width (X length)
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("Width: ")
	dims_group.add_child(x_length_lbl)
	x_length_ctrl = NumberEdit.new()
	x_length_ctrl.set_text("1.0")
	dims_group.add_child(x_length_ctrl)
	# Height (Y length)
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Height: ")
	dims_group.add_child(y_length_lbl)
	y_length_ctrl = NumberEdit.new()
	y_length_ctrl.set_text("1.0")
	dims_group.add_child(y_length_ctrl)

	add_child(dims_group)

	# Add the centered control
	var centered_group = HBoxContainer.new()
	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered: ")
	centered_group.add_child(centered_lbl)
	centered_ctrl = CheckBox.new()
	centered_ctrl.pressed = true
	centered_group.add_child(centered_ctrl)

	add_child(centered_group)

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
	if not x_length_ctrl.is_valid:
		return false
	if not y_length_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
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


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
