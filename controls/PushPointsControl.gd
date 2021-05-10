extends VBoxContainer

class_name PushPointsControl

signal error

var prev_template = null

var point_list_ctrl = null
var point_lr_ctrl = null
var point_tb_ctrl = null

var template = ".pushPoints([{point_list}])"

const point_list_edit_rgx = "(?<=.pushPoints\\(\\[)(.*?)(?=\\]\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# The point list control
	var point_list_lbl = Label.new()
	point_list_lbl.set_text("Point List")
	point_list_ctrl = ItemList.new()
	point_list_ctrl.auto_height = true
	point_list_ctrl.connect("item_activated", self, "_populate_point_controls_from_list")
	add_child(point_list_lbl)
	add_child(point_list_ctrl)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	# Left to right control
	var point_lr_group = HBoxContainer.new()
	var point_lr_lbl = Label.new()
	point_lr_lbl.set_text("Point Left-to-Right: ")
	point_lr_group.add_child(point_lr_lbl)
	point_lr_ctrl = NumberEdit.new()
	point_lr_ctrl.set_text("1.0")
	point_lr_ctrl.hint_tooltip = tr("PUSH_POINTS_POINT_LR_CTRL_HINT_TOOLTIP")
	point_lr_group.add_child(point_lr_ctrl)
	add_child(point_lr_group)

	# Top to bottom control
	var point_tb_group = HBoxContainer.new()
	var point_tb_lbl = Label.new()
	point_tb_lbl.set_text("Point Top-to-Bottom: ")
	point_tb_group.add_child(point_tb_lbl)
	point_tb_ctrl = NumberEdit.new()
	point_tb_ctrl.set_text("1.0")
	point_tb_ctrl.hint_tooltip = tr("PUSH_POINTS_POINT_TB_CTRL_HINT_TOOLTIP")
	point_tb_group.add_child(point_tb_ctrl)
	add_child(point_tb_group)

	# Button to add, edit or delete current point to the point list
	var btn_group = HBoxContainer.new()
	var add_point_btn = Button.new()
	add_point_btn.set_text("Add")
	add_point_btn.connect("button_down", self, "_add_current_point_to_list")
	btn_group.add_child(add_point_btn)
	var edit_point_btn = Button.new()
	edit_point_btn.set_text("Edit")
	edit_point_btn.connect("button_down", self, "_edit_current_point")
	btn_group.add_child(edit_point_btn)
	var delete_point_btn = Button.new()
	delete_point_btn.set_text("Delete")
	delete_point_btn.connect("button_down", self, "_delete_current_point")
	btn_group.add_child(delete_point_btn)
	add_child(btn_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not point_lr_ctrl.is_valid:
		return false
	if not point_tb_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Collect all of the points from the ItemList
	var points = ""
	for i in range(0, point_list_ctrl.get_item_count(), 1):
		# See if we need to prepend a comma
		if i > 0:
			points += ","

		points += "(" + point_list_ctrl.get_item_text(i) + ")"

	complete += template.format({
		"point_list": points
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

	# Clear the previous point list
	for i in range(0, point_list_ctrl.get_item_count(), 1):
		point_list_ctrl.remove_item(i)

	var rgx = RegEx.new()

	# Point list
	rgx.compile(point_list_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Extract the points
		var points = res.get_string().split(")")
		for point in points:
			var clean_point = point.replace(",(", "").replace("(", "")
			if clean_point != "":
				point_list_ctrl.add_item(clean_point)


"""
Adds the current values of the left-to-right and top-to-bottom fields as points.
"""
func _add_current_point_to_list():
	if not is_valid():
		connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		emit_signal("error", "There is invalid tuple data in the form.")

		return

	point_list_ctrl.add_item(point_lr_ctrl.get_text() + "," + point_tb_ctrl.get_text())


"""
Allows the user to edit the currently selected point.
"""
func _edit_current_point():
	if not is_valid():
		connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		emit_signal("error", "There is invalid tuple data in the form.")

		return

	# Item to edit
	var selected_id = point_list_ctrl.get_selected_items()[0]

	# Replacement text
	var item_text = point_lr_ctrl.get_text() + "," + point_tb_ctrl.get_text()

	point_list_ctrl.set_item_text(selected_id, item_text)


"""
Allows the user to delete the currently selected point.
"""
func _delete_current_point():
	# Item to delete
	var selected_id = point_list_ctrl.get_selected_items()[0]
	point_list_ctrl.remove_item(selected_id)


"""
Fills in the point controls from an item that is selected in the list
"""
func _populate_point_controls_from_list(id):
	# Extract the points from the selected item
	var points = point_list_ctrl.get_item_text(id).split(",")

	# Set the point input controls
	point_lr_ctrl.set_text(points[0])
	point_tb_ctrl.set_text(points[1])


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
