extends VBoxContainer

class_name BlindCutControl

var prev_template = null

var template = ".cutBlind({distance},clean={clean},taper={taper})"
#var wp_template = ".workplane(invert={invert})"

const dist_edit_rgx = "(?<=.cutBlind\\()(.*?)(?=,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\,)"
const taper_edit_rgx = "(?<=taper\\=)(.*?)(?=\\))"
#const wp_edit_rgx = "(?<=.workplane\\(invert\\=)(.*?)(?=\\).cutBlind)"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the control for the distance to cut
	var distance_group = HBoxContainer.new()
	distance_group.name = "distance_group"
	var distance_lbl = Label.new()
	distance_lbl.set_text("Distance to Cut: ")
	distance_group.add_child(distance_lbl)
	var distance_ctrl = NumberEdit.new()
	distance_ctrl.size_flags_horizontal = 3
	distance_ctrl.name = "distance_ctrl"
	distance_ctrl.CanBeNegative = true
	distance_ctrl.set_text("1.0")
	distance_ctrl.hint_tooltip = tr("BLIND_CUT_DISTANCE_CTRL_HINT_TOOLTIP")
	distance_group.add_child(distance_ctrl)
	add_child(distance_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	clean_group.name = "clean_group"
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
	taper_group.name = "taper_group"
	var taper_lbl = Label.new()
	taper_lbl.set_text("Taper: ")
	taper_group.add_child(taper_lbl)
	var taper_ctrl = NumberEdit.new()
	taper_ctrl.size_flags_horizontal = 3
	taper_ctrl.name = "taper_ctrl"
	taper_ctrl.CanBeNegative = true
	taper_ctrl.set_text("0.0")
	taper_ctrl.hint_tooltip = tr("TAPER_CTRL_HINT_TOOLTIP")
	taper_group.add_child(taper_ctrl)
	add_child(taper_group)

	# Allow the user to flip the direction of the operation
#	var invert_group = HBoxContainer.new()
#	invert_group.name = "invert_group"
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
	var distance_ctrl = get_node("distance_group/distance_ctrl")
	var taper_ctrl = get_node("taper_group/taper_ctrl")

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

	var distance_ctrl = get_node("distance_group/distance_ctrl")
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var taper_ctrl = get_node("taper_group/taper_ctrl")
	var invert_ctrl = get_node("invert_group/invert_ctrl")

	# Allow flipping the direction of the operation
#	if invert_ctrl.pressed:
#		complete += wp_template.format({
#			"invert": invert_ctrl.pressed
#		})

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

	var distance_ctrl = get_node("distance_group/distance_ctrl")
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var taper_ctrl = get_node("taper_group/taper_ctrl")
#	var invert_ctrl = get_node("invert_group/invert_ctrl")

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
#	rgx.compile(wp_edit_rgx)
#	res = rgx.search(text_line)
#	if res:
#		var invert = res.get_string()
#		invert_ctrl.pressed = true if invert == "True" else false
