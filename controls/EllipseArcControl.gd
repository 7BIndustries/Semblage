extends VBoxContainer

class_name EllipseArcControl

var prev_template = null

var template = ".ellipseArc({x_radius},{y_radius},angle1={angle1},angle2={angle2},rotation_angle={rotation_angle},sense={sense},forConstruction={forConstruction},startAtCurrent={startAtCurrent},makeWire={makeWire})"

const radius_edit_rgx = "(?<=.ellipseArc\\()(.*?)(?=,angle1)"
const angle1_edit_rgx = "(?<=angle1\\=)(.*?)(?=\\,angle2)"
const angle2_edit_rgx = "(?<=angle2\\=)(.*?)(?=\\,rotation_angle)"
const rotation_angle_edit_rgx = "(?<=rotation_angle\\=)(.*?)(?=\\,sense)"
const sense_edit_rgx = "(?<=sense\\=)(.*?)(?=\\,forConstruction)"
const for_construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,startAtCurrent)"
const start_at_current_edit_rgx = "(?<=startAtCurrent\\=)(.*?)(?=\\,makeWire)"
const make_wire_edit_rgx = "(?<=makeWire\\=)(.*?)(?=\\))"

const sense_option_list = ["Clockwise", "Counter-Clockwise"]

var x_radius_ctrl = null
var y_radius_ctrl = null
var angle_1_ctrl = null
var angle_2_ctrl = null
var rotation_angle_ctrl = null
var sense_ctrl = null
var for_construction_ctrl = null
var start_at_current_ctrl = null
var make_wire_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# X Radius
	var x_radius_group = HBoxContainer.new()
	var x_radius_lbl = Label.new()
	x_radius_lbl.set_text("X Radius: ")
	x_radius_group.add_child(x_radius_lbl)
	x_radius_ctrl = NumberEdit.new()
	x_radius_ctrl.set_text("5.0")
	x_radius_ctrl.hint_tooltip = ToolTips.get_tts().arc_x_radius_ctrl_hint_tooltip
	x_radius_group.add_child(x_radius_ctrl)
	add_child(x_radius_group)

	# Y Radius
	var y_radius_group = HBoxContainer.new()
	var y_radius_lbl = Label.new()
	y_radius_lbl.set_text("Y Radius: ")
	y_radius_group.add_child(y_radius_lbl)
	y_radius_ctrl = NumberEdit.new()
	y_radius_ctrl.set_text("10.0")
	y_radius_ctrl.hint_tooltip = ToolTips.get_tts().arc_y_radius_ctrl_hint_tooltip
	y_radius_group.add_child(y_radius_ctrl)
	add_child(y_radius_group)

	# Angle 1
	var angle_1_group = HBoxContainer.new()
	var angle_1_lbl = Label.new()
	angle_1_lbl.set_text("Angle 1: ")
	angle_1_group.add_child(angle_1_lbl)
	angle_1_ctrl = NumberEdit.new()
	angle_1_ctrl.MaxValue = 360.0
	angle_1_ctrl.set_text("360.0")
	angle_1_ctrl.hint_tooltip = ToolTips.get_tts().arc_angle_1_ctrl_hint_tooltip
	angle_1_group.add_child(angle_1_ctrl)
	add_child(angle_1_group)

	# Angle 2
	var angle_2_group = HBoxContainer.new()
	var angle_2_lbl = Label.new()
	angle_2_lbl.set_text("Angle 2: ")
	angle_2_group.add_child(angle_2_lbl)
	angle_2_ctrl = NumberEdit.new()
	angle_2_ctrl.MaxValue = 360.0
	angle_2_ctrl.set_text("360.0")
	angle_2_ctrl.hint_tooltip = ToolTips.get_tts().arc_angle_2_ctrl_hint_tooltip
	angle_2_group.add_child(angle_2_ctrl)
	add_child(angle_2_group)

	# Rotation angle
	var rotation_angle_group = HBoxContainer.new()
	var rotation_angle_lbl = Label.new()
	rotation_angle_lbl.set_text("Rotation Angle: ")
	rotation_angle_group.add_child(rotation_angle_lbl)
	rotation_angle_ctrl = NumberEdit.new()
	rotation_angle_ctrl.MaxValue = 360.0
	rotation_angle_ctrl.set_text("360.0")
	rotation_angle_ctrl.hint_tooltip = ToolTips.get_tts().arc_rotation_angle_ctrl_hint_tooltip
	rotation_angle_group.add_child(rotation_angle_ctrl)
	add_child(rotation_angle_group)

	# Sense
	var sense_group = HBoxContainer.new()
	var sense_lbl = Label.new()
	sense_lbl.set_text("Sense: ")
	sense_group.add_child(sense_lbl)
	sense_ctrl = OptionButton.new()
	Common.load_option_button(sense_ctrl, sense_option_list)
	sense_ctrl.hint_tooltip = ToolTips.get_tts().arc_sense_ctrl_hint_tooltip
	sense_group.add_child(sense_ctrl)
	add_child(sense_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = ToolTips.get_tts().for_construction_ctrl_hint_tooltip
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)

	# Start at current
	var start_at_current_group = HBoxContainer.new()
	var start_at_current_lbl = Label.new()
	start_at_current_lbl.set_text("Start at Current: ")
	start_at_current_group.add_child(start_at_current_lbl)
	start_at_current_ctrl = CheckBox.new()
	start_at_current_ctrl.pressed = false
	start_at_current_ctrl.hint_tooltip = ToolTips.get_tts().arc_start_at_current_ctrl_hint_tooltip
	start_at_current_group.add_child(start_at_current_ctrl)
	add_child(start_at_current_group)

	# Make wire
	var make_wire_group = HBoxContainer.new()
	var make_wire_lbl = Label.new()
	make_wire_lbl.set_text("Make Wire: ")
	make_wire_group.add_child(make_wire_lbl)
	make_wire_ctrl = CheckBox.new()
	make_wire_ctrl.pressed = false
	make_wire_ctrl.hint_tooltip = ToolTips.get_tts().arc_make_wire_ctrl_hint_tooltip
	make_wire_group.add_child(make_wire_ctrl)
	add_child(make_wire_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not x_radius_ctrl.is_valid:
		return false
	if not y_radius_ctrl.is_valid:
		return false
	if not angle_1_ctrl.is_valid:
		return false
	if not angle_2_ctrl.is_valid:
		return false
	if not rotation_angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Get the sense drop-down's value
	var sen = sense_ctrl.get_item_text(sense_ctrl.get_selected_id())
	if sen == "Clockwise":
		sen = "-1"
	else:
		sen = "1"

	complete += template.format({
		"x_radius": x_radius_ctrl.get_text(),
		"y_radius": y_radius_ctrl.get_text(),
		"angle1": angle_1_ctrl.get_text(),
		"angle2": angle_2_ctrl.get_text(),
		"rotation_angle": rotation_angle_ctrl.get_text(),
		"sense": sen,
		"forConstruction": for_construction_ctrl.pressed,
		"startAtCurrent": start_at_current_ctrl.pressed,
		"makeWire": make_wire_ctrl.pressed
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

	# X and Y Radii
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the X and Y radii controls
		var xy = res.get_string().split(",")
		x_radius_ctrl.set_text(xy[0])
		y_radius_ctrl.set_text(xy[1])

	# Angle 1
	rgx.compile(angle1_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle 1 controls
		var angle = res.get_string()
		angle_1_ctrl.set_text(angle)

	# Angle 2
	rgx.compile(angle2_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle 2 controls
		var angle = res.get_string()
		angle_2_ctrl.set_text(angle)

	# Rotation angle
	rgx.compile(rotation_angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the rotation angle controls
		var rotation_angle = res.get_string()
		rotation_angle_ctrl.set_text(rotation_angle)

	# Sense
	rgx.compile(sense_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the rotation angle controls
		var sense = res.get_string()
		if sense == "-1":
			sense = "Clockwise"
		else:
			sense = "Counter-Clockwise"

		Common.set_option_btn_by_text(sense_ctrl, sense)

	# For construction
	rgx.compile(for_construction_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false

	# Start at current
	rgx.compile(start_at_current_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cur = res.get_string()
		start_at_current_ctrl.pressed = true if cur == "True" else false

	# Make wire
	rgx.compile(make_wire_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var make_wire = res.get_string()
		make_wire_ctrl.pressed = true if make_wire == "True" else false


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
