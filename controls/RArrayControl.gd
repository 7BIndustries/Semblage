extends VBoxContainer

class_name RArrayControl

var prev_template = null

var template = ".rarray({xSpacing},{ySpacing},{xCount},{yCount},center={centered})"

const dims_edit_rgx = "(?<=.rarray\\()(.*?)(?=,center)"
const centered_edit_rgx = "(?<=center\\=)(.*?)(?=\\))"

var x_spacing_ctrl = null
var y_spacing_ctrl = null
var x_count_ctrl = null
var y_count_ctrl = null
var centered_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var spacing_lbl = Label.new()
	spacing_lbl.set_text("Spacing")
	add_child(spacing_lbl)

	# Add the rarray dimension controls
	var spacing_group = HBoxContainer.new()
	# X spacing
	var x_spacing_lbl = Label.new()
	x_spacing_lbl.set_text("X: ")
	spacing_group.add_child(x_spacing_lbl)
	x_spacing_ctrl = NumberEdit.new()
	x_spacing_ctrl.set_text("1.0")
	x_spacing_ctrl.CanBeZero = false
	x_spacing_ctrl.hint_tooltip = tr("RARRAY_X_SPACING_CTRL_HINT_TOOLTIP")
	spacing_group.add_child(x_spacing_ctrl)
	# Y spacing
	var y_spacing_lbl = Label.new()
	y_spacing_lbl.set_text("Y: ")
	spacing_group.add_child(y_spacing_lbl)
	y_spacing_ctrl = NumberEdit.new()
	y_spacing_ctrl.set_text("1.0")
	y_spacing_ctrl.CanBeZero = false
	y_spacing_ctrl.hint_tooltip = tr("RARRAY_Y_SPACING_CTRL_HINT_TOOLTIP")
	spacing_group.add_child(y_spacing_ctrl)
	add_child(spacing_group)

	var count_lbl = Label.new()
	count_lbl.set_text("Count")
	add_child(count_lbl)

	# Add the rarray dimension controls
	var count_group = HBoxContainer.new()
	# X spacing
	var x_count_lbl = Label.new()
	x_count_lbl.set_text("X: ")
	count_group.add_child(x_count_lbl)
	x_count_ctrl = NumberEdit.new()
	x_count_ctrl.NumberFormat = "int"
	x_count_ctrl.set_text("1")
	x_count_ctrl.CanBeZero = false
	x_count_ctrl.hint_tooltip = tr("RARRAY_X_COUNT_CTRL_HINT_TOOLTIP")
	count_group.add_child(x_count_ctrl)
	# Y spacing
	var y_count_lbl = Label.new()
	y_count_lbl.set_text("Y: ")
	count_group.add_child(y_count_lbl)
	y_count_ctrl = NumberEdit.new()
	x_count_ctrl.NumberFormat = "int"
	y_count_ctrl.set_text("1")
	y_count_ctrl.CanBeZero = false
	y_count_ctrl.hint_tooltip = tr("RARRAY_Y_COUNT_CTRL_HINT_TOOLTIP")
	count_group.add_child(y_count_ctrl)
	add_child(count_group)

	# Add the centered control
	var centered_group = HBoxContainer.new()
	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered: ")
	centered_group.add_child(centered_lbl)
	centered_ctrl = CheckBox.new()
	centered_ctrl.pressed = true
	centered_ctrl.hint_tooltip = tr("RARRAY_CENTERED_CTRL_HINT_TOOLTIP")
	centered_group.add_child(centered_ctrl)
	add_child(centered_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not x_spacing_ctrl.is_valid:
		return false
	if not y_spacing_ctrl.is_valid:
		return false
	if not x_count_ctrl.is_valid:
		return false
	if not y_count_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"xSpacing": x_spacing_ctrl.get_text(),
		"ySpacing": y_spacing_ctrl.get_text(),
		"xCount": x_count_ctrl.get_text(),
		"yCount": y_count_ctrl.get_text(),
		"centered": centered_ctrl.pressed
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
		var sc = res.get_string().split(",")
		x_spacing_ctrl.set_text(sc[0])
		y_spacing_ctrl.set_text(sc[1])
		x_count_ctrl.set_text(sc[2])
		y_count_ctrl.set_text(sc[3])

	# Centered
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cen = res.get_string()
		centered_ctrl.pressed = true if cen == "True" else false


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
