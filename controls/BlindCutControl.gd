extends VBoxContainer

class_name BlindCutControl

var prev_template = null

var template = ".cutBlind({distance},clean={clean},taper={taper})"
var wp_template = ".workplane(invert={invert})"

var dist_edit_rgx = "(?<=.cutBlind\\()(.*?)(?=,clean)"
var clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\,)"
var taper_edit_rgx = "(?<=taper\\=)(.*?)(?=\\))"
var wp_edit_rgx = "(?<=.workplane\\(invert\\=)(.*?)(?=\\).cutBlind)"

var distance_ctrl = null
var clean_ctrl = null
var taper_ctrl = null
var invert_ctrl = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the control for the distance to cut
	var distance_group = HBoxContainer.new()
	var distance_lbl = Label.new()
	distance_lbl.set_text("Distance to Cut: ")
	distance_group.add_child(distance_lbl)
	distance_ctrl = NumberEdit.new()
	distance_ctrl.CanBeNegative = true
	distance_ctrl.set_text("1.0")
	distance_ctrl.hint_tooltip = "Distance to extrude before cutting (> 0.0 means in the positive direction of the workplane normal, < 0.0 means in the negative direction)."
	distance_group.add_child(distance_ctrl)
	add_child(distance_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = "Call clean on the underlying CAD object afterwards to have a clean shape."
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)

	# Add the control for the amount of taper to apply
	var taper_group = HBoxContainer.new()
	var taper_lbl = Label.new()
	taper_lbl.set_text("Taper: ")
	taper_group.add_child(taper_lbl)
	taper_ctrl = NumberEdit.new()
	taper_ctrl.CanBeNegative = true
	taper_ctrl.set_text("0.0")
	taper_ctrl.hint_tooltip = "Angle for optional tapered extrusion."
	taper_group.add_child(taper_ctrl)
	add_child(taper_group)

	# Allow the user to flip the direction of the operation
	var invert_group = HBoxContainer.new()
	var invert_lbl = Label.new()
	invert_lbl.set_text("Invert: ")
	invert_group.add_child(invert_lbl)
	invert_ctrl = CheckBox.new()
	invert_ctrl.pressed = false
	invert_group.add_child(invert_ctrl)
	add_child(invert_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not distance_ctrl.is_valid:
		return false
	if not taper_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Allow flipping the direction of the operation
	if invert_ctrl.pressed:
		complete += wp_template.format({
			"invert": invert_ctrl.pressed
		})

	complete += template.format({
		"distance": distance_ctrl.get_text(),
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
	prev_template = text_line

	var rgx = RegEx.new()

	# Cut distance
	rgx.compile(dist_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		distance_ctrl.set_text(res.get_string())

	# Clean boolean
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false

	# Taper amount
	rgx.compile(taper_edit_rgx)
	res = rgx.search(text_line)
	if res:
		taper_ctrl.set_text(res.get_string())

	# Workplane (invert) edit
	rgx.compile(wp_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var invert = res.get_string()
		invert_ctrl.pressed = true if invert == "True" else false
