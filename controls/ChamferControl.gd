extends VBoxContainer

class_name ChamferControl

var select_ctrl = null
var length_ctrl = null

var template = ".chamfer({chamfer_length})"

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
