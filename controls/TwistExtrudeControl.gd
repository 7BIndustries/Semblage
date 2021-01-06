extends VBoxContainer

class_name TwistExtrudeControl

var prev_template = null

var template = ".twistExtrude({distance},angleDegrees={angle_degrees},combine={combine},clean={clean})"
var wp_template = ".workplane(invert={invert})"

var dist_edit_rgx = "(?<=.twistExtrude\\()(.*?)(?=,angleDegrees)"
var angle_edit_rgx = "(?<=angleDegrees\\=)(.*?)(?=\\,)"
var combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,)"
var clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"
var wp_edit_rgx = "(?<=.workplane\\(invert\\=)(.*?)(?=\\))"

var distance_ctrl = null
var angle_ctrl = null
var combine_ctrl = null
var clean_ctrl = null
var invert_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the control for the distance to extrude
	var distance_group = HBoxContainer.new()
	var distance_lbl = Label.new()
	distance_lbl.set_text("Distance: ")
	distance_group.add_child(distance_lbl)
	distance_ctrl = LineEdit.new()
	distance_ctrl.set_text("5.0")
	distance_group.add_child(distance_ctrl)
	add_child(distance_group)

	# Add the angle to twist through while extruding
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle (Degrees): ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = LineEdit.new()
	angle_ctrl.set_text("30")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

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
		"angle_degrees": angle_ctrl.get_text(),
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

	# Extrusion distance
	rgx.compile(dist_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		distance_ctrl.set_text(res.get_string())

	# Twist angle (Degrees)
	rgx.compile(angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		angle_ctrl.set_text(res.get_string())

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

	# Workplane (invert) edit
	rgx.compile(wp_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var invert = res.get_string()
		invert_ctrl.pressed = true if invert == "True" else false
