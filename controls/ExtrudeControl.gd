extends VBoxContainer

class_name ExtrudeControl

var prev_template = null

var template = ".extrude({distance},combine={combine},clean={clean},both={both},taper={taper})"

var dist_edit_rgx = "(?<=.extrude\\()(.*?)(?=,combine)"
var combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,)"
var clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\,)"
var both_edit_rgx = "(?<=both\\=)(.*?)(?=\\,)"
var taper_edit_rgx = "(?<=taper\\=)(.*?)(?=\\))"

var distance_ctrl = null
var combine_ctrl = null
var clean_ctrl = null
var both_ctrl = null
var taper_ctrl = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the control for the distance to extrude
	var distance_group = HBoxContainer.new()
	var distance_lbl = Label.new()
	distance_lbl.set_text("Distance: ")
	distance_group.add_child(distance_lbl)
	distance_ctrl = LineEdit.new()
	distance_ctrl.set_text("1.0")
	distance_group.add_child(distance_ctrl)

	add_child(distance_group)

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

	# Add the both checkbox
	var both_group = HBoxContainer.new()
	var both_lbl = Label.new()
	both_lbl.set_text("Both: ")
	both_group.add_child(both_lbl)
	both_ctrl = CheckBox.new()
	both_ctrl.pressed = false
	both_group.add_child(both_ctrl)

	add_child(both_group)

	# Add the control for the amount of taper to apply
	var taper_group = HBoxContainer.new()
	var taper_lbl = Label.new()
	taper_lbl.set_text("Taper: ")
	taper_group.add_child(taper_lbl)
	taper_ctrl = LineEdit.new()
	taper_ctrl.set_text("0.0")
	taper_group.add_child(taper_ctrl)

	add_child(taper_group)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = template.format({
		"distance": distance_ctrl.get_text(),
		"combine": combine_ctrl.pressed,
		"clean": clean_ctrl.pressed,
		"both": both_ctrl.pressed,
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

	# Extrusion distance
	rgx.compile(dist_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		distance_ctrl.set_text(res.get_string())

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

	# Both boolean
	rgx.compile(both_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var both = res.get_string()
		both_ctrl.pressed = true if both == "True" else false

	# Taper amount
	rgx.compile(taper_edit_rgx)
	res = rgx.search(text_line)
	if res:
		taper_ctrl.set_text(res.get_string())
