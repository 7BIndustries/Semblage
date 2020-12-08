extends VBoxContainer

class_name FilletControl

var select_ctrl = null
var radius_ctrl = null

var template = ".fillet({fillet_radius})"

func _ready():
	var radius_group = HBoxContainer.new()

	# Add the fillet radius control
	var radius_lbl = Label.new()
	radius_lbl.set_text("Radius: ")
	radius_group.add_child(radius_lbl)
	radius_ctrl = LineEdit.new()
	radius_ctrl.set_text("0.1")
	radius_group.add_child(radius_ctrl)

	add_child(radius_group)

	# Add the face/edge selector control
	select_ctrl = SelectorControl.new()
	add_child(select_ctrl)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = select_ctrl.get_completed_template()
	
	complete += template.format({"fillet_radius": radius_ctrl.get_text()})

	return complete
