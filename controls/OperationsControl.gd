extends VBoxContainer

var ControlsCommon = load("res://controls/Common.gd").new()

class_name OperationsControl

var prev_template = null

var op_list = ["None", "Extrude", "Blind Cut"] #, "Revolve", "Thru Cut"

var op_ctrl = null
var extrude_lbl = null
var extrude_ctrl = null
var cut_blind_ctrl = null

var extrude_edit_rgx = ".extrude\\(.*\\)"
var cut_blind_edit_rgx = ".cutBlind\\(.*\\)"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Whether to cut, extrude or do nothing
	var op_group = HBoxContainer.new()
	var op_lbl = Label.new()
	op_lbl.set_text("Operation: ")
	op_group.add_child(op_lbl)
	op_ctrl = OptionButton.new()
	ControlsCommon.load_option_button(op_ctrl, op_list)
	op_ctrl.connect("item_selected", self, "_op_ctrl_item_selected")
	op_group.add_child(op_ctrl)
	add_child(op_group)

	# The Extrude control, which will be hidden unless it is needed
	extrude_ctrl = ExtrudeControl.new()
	extrude_ctrl.hide()
	add_child(extrude_ctrl)

	# The Cut Blind control, which will be hidden unless it is needed
	cut_blind_ctrl = BlindCutControl.new()
	cut_blind_ctrl.hide()
	add_child(cut_blind_ctrl)


"""
Called when the user selects a new Operation from the Operations option button.
"""
func _op_ctrl_item_selected(index):
	# Hide all of the existing controls and start fresh
	extrude_ctrl.hide()

	# Figure out which controls, if any, to show
	if op_ctrl.get_item_text(index) == "Extrude":
		cut_blind_ctrl.hide()
		extrude_ctrl.show()
	elif op_ctrl.get_item_text(index) == "Blind Cut":
		extrude_ctrl.hide()
		cut_blind_ctrl.show()


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# If None is selected, we do not need to do additional checking
	var op_selected = op_ctrl.get_item_text(op_ctrl.get_selected_id())
	if op_selected == "None":
		return ""

	# If the selector control is visible, prepend its contents
	if extrude_ctrl.visible:
		complete += extrude_ctrl.get_completed_template()
	elif cut_blind_ctrl.visible:
		complete += cut_blind_ctrl.get_completed_template()

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

	# Extrude
	rgx.compile(extrude_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		ControlsCommon.set_option_btn_by_text(op_ctrl, "Extrude")
		extrude_ctrl.set_values_from_string(res.get_string())
		extrude_ctrl.show()

	# Cut blind
	rgx.compile(cut_blind_edit_rgx)
	res = rgx.search(text_line)
	if res:
		ControlsCommon.set_option_btn_by_text(op_ctrl, "Blind Cut")
		cut_blind_ctrl.set_values_from_string(res.get_string())
		cut_blind_ctrl.show()
