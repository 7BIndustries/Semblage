extends VBoxContainer

class_name PolarLineToControl

var prev_template = null

var template = ".polarLine({distance},{angle},forConstruction={for_construction})"

const dims_edit_rgx = "(?<=.polarLine\\()(.*?)(?=,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the distance controls
	var dist_group = HBoxContainer.new()
	var dist_lbl = Label.new()
	dist_lbl.set_text("Distance: ")
	dist_group.add_child(dist_lbl)
	var distance_ctrl = NumberEdit.new()
	distance_ctrl.name = "distance_ctrl"
	distance_ctrl.size_flags_horizontal = 3
	distance_ctrl.set_text("1.0")
	distance_ctrl.hint_tooltip = tr("POLAR_LINE_TO_DISTANCE_CTRL_HINT_TOOLTIP")
	dist_group.add_child(distance_ctrl)
	add_child(dist_group)
	
	# Add angle controls
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	var angle_ctrl = NumberEdit.new()
	angle_ctrl.name = "angle_ctrl"
	angle_ctrl.size_flags_horizontal = 3
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("1.0")
	angle_ctrl.hint_tooltip = tr("POLAR_LINE_ANGLE_CTRL_HINT_TOOLTIP")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

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
	var distance_ctrl = find_node("distance_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not distance_ctrl.is_valid:
		return false
	if not angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var distance_ctrl = find_node("distance_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"distance": distance_ctrl.get_text(),
		"angle": angle_ctrl.get_text(),
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
	var distance_ctrl = find_node("distance_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Distance and Angle dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var da = res.get_string().split(",")
		distance_ctrl.set_text(da[0])
		angle_ctrl.set_text(da[1])

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
