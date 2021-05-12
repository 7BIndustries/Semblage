extends VBoxContainer

class_name TangentArcPointControl

var prev_template = null

var template = ".tangentArcPoint(endpoint=({end_point_x},{end_point_y}),forConstruction={for_construction},relative={relative})"

const end_point_edit_rgx = "(?<=endpoint\\=)(.*?)(?=,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,relative)"
const relative_edit_rgx = "(?<=relative\\=)(.*?)(?=\\))"

var end_point_x_ctrl = null
var end_point_y_ctrl = null
var for_construction_ctrl = null
var relative_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var end_point_group_lbl = Label.new()
	end_point_group_lbl.set_text("End Point")
	add_child(end_point_group_lbl)

	# Add the end point vector controls
	var end_point_group = HBoxContainer.new()
	# End Point X
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	end_point_group.add_child(x_length_lbl)
	end_point_x_ctrl = NumberEdit.new()
	end_point_x_ctrl.set_text("0.0")
	end_point_x_ctrl.hint_tooltip = tr("TANGENT_ARC_END_POINT_X_CTRL_HINT_TOOLTIP")
	end_point_group.add_child(end_point_x_ctrl)
	# End Point Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	end_point_group.add_child(y_lbl)
	end_point_y_ctrl = NumberEdit.new()
	end_point_y_ctrl.set_text("0.0")
	end_point_y_ctrl.hint_tooltip = tr("TANGENT_ARC_END_POINT_Y_CTRL_HINT_TOOLTIP")
	end_point_group.add_child(end_point_y_ctrl)

	add_child(end_point_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)

	# Add the relative control
	var relative_group = HBoxContainer.new()
	var relative_lbl = Label.new()
	relative_lbl.set_text("Relative: ")
	relative_group.add_child(relative_lbl)
	relative_ctrl = CheckBox.new()
	relative_ctrl.pressed = true
	relative_ctrl.hint_tooltip = tr("TANGENT_ARC_RELATIVE_CTRL_HINT_TOOLTIP")
	relative_group.add_child(relative_ctrl)
	add_child(relative_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not end_point_x_ctrl.is_valid:
		return false
	if not end_point_y_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"end_point_x": end_point_x_ctrl.get_text(),
		"end_point_y": end_point_y_ctrl.get_text(),
		"for_construction": for_construction_ctrl.pressed,
		"relative": relative_ctrl.pressed
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

	# End Point
	rgx.compile(end_point_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the end point controls
		var xy = res.get_string().split(",")
		end_point_x_ctrl.set_text(xy[0])
		end_point_y_ctrl.set_text(xy[1])

	# Relative
	rgx.compile(relative_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var relative = res.get_string()
		relative_ctrl.pressed = true if relative == "True" else false

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
