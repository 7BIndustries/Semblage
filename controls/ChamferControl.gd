extends VBoxContainer

class_name ChamferControl

var prev_template = null

var select_ctrl = null
var length_ctrl = null

var template = ".chamfer({chamfer_length})"

var len_edit_rgx = "(?<=.chamfer\\()(.*?)(?=\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\.edges\\(.*\\)\\."

func _ready():
	var length_group = HBoxContainer.new()

	# Add the fillet radius control
	var length_lbl = Label.new()
	length_lbl.set_text("Length: ")
	length_group.add_child(length_lbl)
	length_ctrl = LineEdit.new()
	length_ctrl.set_text("0.1")
	length_group.add_child(length_ctrl)

	add_child(length_group)

	# Add the face/edge selector control
	select_ctrl = SelectorControl.new()
	add_child(select_ctrl)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = select_ctrl.get_completed_template()
	
	complete += template.format({"chamfer_length": length_ctrl.get_text()})

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
		length_ctrl.set_text(res.get_string())

	# Selector
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var sel = res.get_string()

		# Allow the selector control to set itself up appropriately
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))
