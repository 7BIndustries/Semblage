extends VBoxContainer

class_name CBoreHoleControl

var prev_template = null

#var select_ctrl = null
var hole_dia_ctrl = null
var hole_depth_ctrl = null
var cbore_dia_ctrl = null
var cbore_depth_ctrl = null
var clean_ctrl = null
#var hide_show_btn = null

var template = ".cboreHole({diameter},{cbore_diameter},{cbore_depth},depth={depth},clean={clean})"

const dims_edit_rgx = "(?<=.cboreHole\\()(.*?)(?=,depth)"
const depth_edit_rgx = "(?<=depth\\=)(.*?)(?=\\,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"
const select_edit_rgx = "^.faces\\(.*\\)\\."

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add hole diameter control
	var hole_dia_group = HBoxContainer.new()
	var hole_dia_lbl = Label.new()
	hole_dia_lbl.set_text("Hole Diameter: ")
	hole_dia_group.add_child(hole_dia_lbl)
	hole_dia_ctrl = NumberEdit.new()
	hole_dia_ctrl.set_text("2.5")
	hole_dia_ctrl.hint_tooltip = tr("HOLE_DIA_CTRL_HINT_TOOLTIP")
	hole_dia_group.add_child(hole_dia_ctrl)
	add_child(hole_dia_group)

	# Add hole depth control
	var hole_depth_group = HBoxContainer.new()
	var hole_depth_lbl = Label.new()
	hole_depth_lbl.set_text("Hole Depth (0 = thru): ")
	hole_depth_group.add_child(hole_depth_lbl)
	hole_depth_ctrl = NumberEdit.new()
	hole_depth_ctrl.set_text("0")
	hole_depth_ctrl.hint_tooltip = tr("HOLE_DEPTH_CTRL_HINT_TOOLTIP")
	hole_depth_group.add_child(hole_depth_ctrl)
	add_child(hole_depth_group)

	# Add cbore hole diameter control
	var cbore_dia_group = HBoxContainer.new()
	var cbore_dia_lbl = Label.new()
	cbore_dia_lbl.set_text("Counter-Bore Diameter: ")
	cbore_dia_group.add_child(cbore_dia_lbl)
	cbore_dia_ctrl = NumberEdit.new()
	cbore_dia_ctrl.set_text("5.0")
	cbore_dia_ctrl.hint_tooltip = tr("CBORE_CBORE_DIA_CTRL_HINT_TOOLTIP")
	cbore_dia_group.add_child(cbore_dia_ctrl)
	add_child(cbore_dia_group)

	# Add hole depth control
	var cbore_depth_group = HBoxContainer.new()
	var cbore_depth_lbl = Label.new()
	cbore_depth_lbl.set_text("Counter-Bore Depth: ")
	cbore_depth_group.add_child(cbore_depth_lbl)
	cbore_depth_ctrl = NumberEdit.new()
	cbore_depth_ctrl.set_text("3.0")
	cbore_depth_ctrl.hint_tooltip = tr("CBORE_CBORE_DEPTH_CTRL_HINT_TOOLTIP")
	cbore_depth_group.add_child(cbore_depth_ctrl)
	add_child(cbore_depth_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not hole_dia_ctrl.is_valid:
		return false
	if not hole_depth_ctrl.is_valid:
		return false
	if not cbore_dia_ctrl.is_valid:
		return false
	if not cbore_depth_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Convert the hole depth to None if the user wants it all the way thru
	var depth = hole_depth_ctrl.get_text()
	if depth == "0.0" or depth == "0":
		depth = "None"

	complete += template.format({
		"diameter": hole_dia_ctrl.get_text(),
		"depth": depth,
		"cbore_diameter": cbore_dia_ctrl.get_text(),
		"cbore_depth": cbore_depth_ctrl.get_text(),
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

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var dims = res.get_string().split(",")
		hole_dia_ctrl.set_text(dims[0])
		cbore_dia_ctrl.set_text(dims[1])
		cbore_depth_ctrl.set_text(dims[2])

	# Hole depth edit
	rgx.compile(depth_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var depth = res.get_string()
		if depth == "None":
			depth = "0"
		hole_depth_ctrl.set_text(depth)

	# Clean edit
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false
