extends VBoxContainer

class_name FilletControl

var is_binary = false

var prev_template = null

var radius_ctrl = null

var template = ".fillet({fillet_radius})"

const len_edit_rgx = "(?<=.fillet\\()(.*?)(?=\\))"

func _ready():
	var radius_group = HBoxContainer.new()

	# Add the fillet radius control
	var radius_lbl = Label.new()
	radius_lbl.set_text("Radius: ")
	radius_group.add_child(radius_lbl)
	radius_ctrl = NumberEdit.new()
	radius_ctrl.set_text("0.1")
	radius_ctrl.CanBeZero = false
	radius_ctrl.hint_tooltip = tr("FILLET_RADIUS_CTRL_HINT_TOOLTIP")
	radius_group.add_child(radius_ctrl)
	add_child(radius_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not radius_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({"fillet_radius": radius_ctrl.get_text()})

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
	rgx.compile(len_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		radius_ctrl.set_text(res.get_string())
