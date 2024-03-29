extends VBoxContainer

class_name SlotControl

var prev_template = null

var template = ".slot2D(length={length},diameter={diameter},angle={angle})"

const length_edit_rgx = "(?<=.slot2D\\(length\\=)(.*?)(?=,diameter)"
const diameter_edit_rgx = "(?<=\\,diameter\\=)(.*?)(?=,angle)"
const angle_edit_rgx = "(?<=\\,angle\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time
func _ready():
	# Slot length
	var length_group = HBoxContainer.new()
	var length_lbl = Label.new()
	length_lbl.set_text("Length: ")
	length_group.add_child(length_lbl)
	var length_ctrl = NumberEdit.new()
	length_ctrl.name = "length_ctrl"
	length_ctrl.size_flags_horizontal = 3
	length_ctrl.set_text("5.0")
	length_ctrl.hint_tooltip = tr("SLOT_LENGTH_CTRL_HINT_TOOLTIP")
	length_group.add_child(length_ctrl)
	add_child(length_group)

	# Diameter
	var diameter_group = HBoxContainer.new()
	var diameter_lbl = Label.new()
	diameter_lbl.set_text("Diameter: ")
	diameter_group.add_child(diameter_lbl)
	var diameter_ctrl = NumberEdit.new()
	diameter_ctrl.name = "diameter_ctrl"
	diameter_ctrl.size_flags_horizontal = 3
	diameter_ctrl.set_text("0.5")
	diameter_ctrl.hint_tooltip = tr("SLOT_DIAMETER_CTRL_HINT_TOOLTIP")
	diameter_group.add_child(diameter_ctrl)
	add_child(diameter_group)

	# Angle
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	var angle_ctrl = NumberEdit.new()
	angle_ctrl.name = "angle_ctrl"
	angle_ctrl.size_flags_horizontal = 3
	angle_ctrl.MaxValue = 360.0
	angle_ctrl.set_text("0")
	angle_ctrl.hint_tooltip = tr("SLOT_ANGLE_CTRL_HINT_TOOLTIP")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var length_ctrl = find_node("length_ctrl", true, false)
	var diameter_ctrl = find_node("diameter_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not length_ctrl.is_valid:
		return false
	if not diameter_ctrl.is_valid:
		return false
	if not angle_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var length_ctrl = find_node("length_ctrl", true, false)
	var diameter_ctrl = find_node("diameter_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)

	var complete = ""

	# Fill out the main template
	complete += template.format({
		"length": length_ctrl.get_text(),
		"diameter": diameter_ctrl.get_text(),
		"angle": angle_ctrl.get_text()
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
	var length_ctrl = find_node("length_ctrl", true, false)
	var diameter_ctrl = find_node("diameter_ctrl", true, false)
	var angle_ctrl = find_node("angle_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Slot length
	rgx.compile(length_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the slot length
		var l = res.get_string()
		length_ctrl.set_text(l)

	# Slot diameter
	rgx.compile(diameter_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the slot diameter
		var d = res.get_string()
		diameter_ctrl.set_text(d)

	# Angle
	rgx.compile(angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle value
		var a = res.get_string()
		angle_ctrl.set_text(a)
