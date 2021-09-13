extends VBoxContainer

class_name CSinkHoleControl

var prev_template = null

var template = ".cskHole({diameter},{csink_diameter},{csink_angle},depth={depth},clean={clean})"

const dims_edit_rgx = "(?<=.cboreHole\\()(.*?)(?=,depth)"
const depth_edit_rgx = "(?<=depth\\=)(.*?)(?=\\,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=\\))"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add hole diameter control
	var hole_dia_group = HBoxContainer.new()
	var hole_dia_lbl = Label.new()
	hole_dia_lbl.set_text("Hole Diameter: ")
	hole_dia_group.add_child(hole_dia_lbl)
	var hole_dia_ctrl = NumberEdit.new()
	hole_dia_ctrl.name = "hole_dia_ctrl"
	hole_dia_ctrl.size_flags_horizontal = 3
	hole_dia_ctrl.set_text("2.5")
	hole_dia_ctrl.hint_tooltip = tr("HOLE_DIA_CTRL_HINT_TOOLTIP")
	hole_dia_group.add_child(hole_dia_ctrl)
	add_child(hole_dia_group)

	# Add hole depth control
	var hole_depth_group = HBoxContainer.new()
	var hole_depth_lbl = Label.new()
	hole_depth_lbl.set_text("Hole Depth: ")
	hole_depth_group.add_child(hole_depth_lbl)
	var hole_depth_ctrl = NumberEdit.new()
	hole_depth_ctrl.name = "hole_depth_ctrl"
	hole_depth_ctrl.size_flags_horizontal = 3
	hole_depth_ctrl.set_text("0")
	hole_depth_ctrl.hint_tooltip = tr("HOLE_DEPTH_CTRL_HINT_TOOLTIP")
	hole_depth_group.add_child(hole_depth_ctrl)
	add_child(hole_depth_group)

	# Add csink hole diameter control
	var csink_dia_group = HBoxContainer.new()
	var csink_dia_lbl = Label.new()
	csink_dia_lbl.set_text("Counter-Sink Diameter: ")
	csink_dia_group.add_child(csink_dia_lbl)
	var csink_dia_ctrl = NumberEdit.new()
	csink_dia_ctrl.name = "csink_dia_ctrl"
	csink_dia_ctrl.size_flags_horizontal = 3
	csink_dia_ctrl.set_text("5.0")
	csink_dia_ctrl.hint_tooltip = tr("CSINK_DIA_CTRL_HINT_TOOLTIP")
	csink_dia_group.add_child(csink_dia_ctrl)
	add_child(csink_dia_group)

	# Add csink angle control
	var csink_angle_group = HBoxContainer.new()
	var csink_angle_lbl = Label.new()
	csink_angle_lbl.set_text("Counter-Sink Angle: ")
	csink_angle_group.add_child(csink_angle_lbl)
	var csink_angle_ctrl = NumberEdit.new()
	csink_angle_ctrl.name = "csink_angle_ctrl"
	csink_angle_ctrl.size_flags_horizontal = 3
	csink_angle_ctrl.set_text("82")
	csink_angle_ctrl.hint_tooltip = tr("CSINK_ANGLE_CTRL_HINT_TOOLTIP")
	csink_angle_group.add_child(csink_angle_ctrl)
	add_child(csink_angle_group)

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
	var hole_dia_ctrl = find_node("hole_dia_ctrl", true, false)
	var hole_depth_ctrl = find_node("hole_depth_ctrl", true, false)
	var csink_dia_ctrl = find_node("csink_dia_ctrl", true, false)
	var csink_angle_ctrl = find_node("csink_angle_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not hole_dia_ctrl.is_valid:
		return false
	if not hole_depth_ctrl.is_valid:
		return false
	if not csink_dia_ctrl.is_valid:
		return false
	if not csink_angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var hole_dia_ctrl = find_node("hole_dia_ctrl", true, false)
	var hole_depth_ctrl = find_node("hole_depth_ctrl", true, false)
	var csink_dia_ctrl = find_node("csink_dia_ctrl", true, false)
	var csink_angle_ctrl = find_node("csink_angle_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

	var complete = ""

	# Convert the hole depth to None if the user wants it all the way thru
	var depth = hole_depth_ctrl.get_text()
	if depth == "0.0" or depth == "0":
		depth = "None"

	complete += template.format({
		"diameter": hole_dia_ctrl.get_text(),
		"depth": depth,
		"csink_diameter": csink_dia_ctrl.get_text(),
		"csink_angle": csink_angle_ctrl.get_text(),
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
	var hole_dia_ctrl = find_node("hole_dia_ctrl", true, false)
	var hole_depth_ctrl = find_node("hole_depth_ctrl", true, false)
	var csink_dia_ctrl = find_node("csink_dia_ctrl", true, false)
	var csink_angle_ctrl = find_node("csink_angle_ctrl", true, false)
	var clean_ctrl = find_node("clean_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var dims = res.get_string().split(",")
		hole_dia_ctrl.set_text(dims[0])
		csink_dia_ctrl.set_text(dims[1])
		csink_angle_ctrl.set_text(dims[2])

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
