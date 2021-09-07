extends VBoxContainer

class_name ChamferControl

var prev_template = null

var length_ctrl = null
var asym_length_ctrl = null

var template = ".chamfer({chamfer_length},length2={asym_length})"

const len_edit_rgx = "(?<=.chamfer\\()(.*?)(?=,length2)"
const asym_len_edit_rgx = "(?<=length2\\=)(.*?)(?=\\))"
const select_edit_rgx = "^.faces\\(.*\\)\\.edges\\(.*\\)\\."

func _ready():
	var length_group = HBoxContainer.new()
	var asym_length_group = HBoxContainer.new()

	# Add the chamfer length control
	var length_lbl = Label.new()
	length_lbl.set_text("Length: ")
	length_group.add_child(length_lbl)
	length_ctrl = NumberEdit.new()
	length_ctrl.CanBeZero = false
	length_ctrl.set_text("0.1")
	length_ctrl.hint_tooltip = tr("CHAMFER_LENGTH_CTRL_HINT_TOOLTIP")
	length_group.add_child(length_ctrl)
	add_child(length_group)

	# Add the assymmetric length control
	var asym_length_lbl = Label.new()
	asym_length_lbl.set_text("Asym Length (0 = ignore): ")
	asym_length_group.add_child(asym_length_lbl)
	asym_length_ctrl = NumberEdit.new()
	asym_length_ctrl.set_text("0")
	asym_length_ctrl.hint_tooltip = tr("CHAMFER_ASYM_LENGTH_CTRL_HINT_TOOLTIP")
	asym_length_group.add_child(asym_length_ctrl)
	add_child(asym_length_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not length_ctrl.is_valid:
		return false
	if not asym_length_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Account for the fact that the assymmetrical distance can be None
	var asym_value = "None"
	if asym_length_ctrl.get_text() != "0":
		asym_value = asym_length_ctrl.get_text()

	complete += template.format({
		"chamfer_length": length_ctrl.get_text(),
		"asym_length": asym_value
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

	# Main chamfer length
	rgx.compile(len_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		length_ctrl.set_text(res.get_string())

	# Assymmetrical chamfer length
	rgx.compile(asym_len_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var val = res.get_string()

		# Account for the fact that the value can be None
		if val == "None":
			asym_length_ctrl.set_text("0")
		else:
			asym_length_ctrl.set_text(val)
