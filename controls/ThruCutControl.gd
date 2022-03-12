extends VBoxContainer

class_name ThruCutControl

var prev_template = null

var template = ".cutThruAll(clean={clean},taper={taper})"
#var wp_template = ".workplane(invert={invert})"

const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\,)"
const taper_edit_rgx = "(?<=taper\\=)(.*?)(?=\\))"
#const wp_edit_rgx = "(?<=.workplane\\(invert\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
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

	# Add the control for the amount of taper to apply
	var taper_group = HBoxContainer.new()
	var taper_lbl = Label.new()
	taper_lbl.set_text("Taper: ")
	taper_group.add_child(taper_lbl)
	var taper_ctrl = NumberEdit.new()
	taper_ctrl.name = "taper_ctrl"
	taper_ctrl.size_flags_horizontal = 3
	taper_ctrl.CanBeNegative = true
	taper_ctrl.set_text("0.0")
	taper_ctrl.hint_tooltip = tr("TAPER_CTRL_HINT_TOOLTIP")
	taper_group.add_child(taper_ctrl)
	add_child(taper_group)

	# Allow the user to flip the direction of the operation
#	var invert_group = HBoxContainer.new()
#	var invert_lbl = Label.new()
#	invert_lbl.set_text("Invert: ")
#	invert_group.add_child(invert_lbl)
#	var invert_ctrl = CheckBox.new()
#	invert_ctrl.name = "invert_ctrl"
#	invert_ctrl.pressed = false
#	invert_ctrl.hint_tooltip = tr("INVERT_CTRL_HINT_TOOLTIP")
#	invert_group.add_child(invert_ctrl)
#	add_child(invert_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var taper_ctrl = find_node("taper_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not taper_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var clean_ctrl = find_node("clean_ctrl", true, false)
	var taper_ctrl = find_node("taper_ctrl", true, false)
#	var invert_ctrl = find_node("invert_ctrl", true, false)

	var complete = ""

	# Allow flipping the direction of the operation
#	if invert_ctrl.pressed:
#		complete += wp_template.format({
#			"invert": invert_ctrl.pressed
#		})

	complete += template.format({
		"clean": clean_ctrl.pressed,
		"taper": taper_ctrl.get_text()
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
	var clean_ctrl = find_node("clean_ctrl", true, false)
	var taper_ctrl = find_node("taper_ctrl", true, false)
#	var invert_ctrl = find_node("invert_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Clean boolean
	rgx.compile(clean_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false

	# Taper amount
	rgx.compile(taper_edit_rgx)
	res = rgx.search(text_line)
	if res:
		taper_ctrl.set_text(res.get_string())

	# Workplane (invert) edit
#	rgx.compile(wp_edit_rgx)
#	res = rgx.search(text_line)
#	if res:
#		var invert = res.get_string()
#		invert_ctrl.pressed = true if invert == "True" else false
