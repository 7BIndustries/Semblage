extends VBoxContainer

class_name RadiusArcControl

var prev_template = null

var template = ".radiusArc(endPoint=({end_point_x},{end_point_y}),radius={radius},forConstruction={for_construction})"

const end_point_edit_rgx = "(?<=endPoint\\=\\()(.*?)(?=\\),radius)"
const radius_edit_rgx = "(?<=radius\\=)(.*?)(?=\\,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


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
	var end_point_x_ctrl = NumberEdit.new()
	end_point_x_ctrl.name = "end_point_x_ctrl"
	end_point_x_ctrl.size_flags_horizontal = 3
	end_point_x_ctrl.set_text("12.0")
	end_point_x_ctrl.hint_tooltip = tr("RADIUS_ARC_END_POINT_X_CTRL_HINT_TOOLTIP")
	end_point_group.add_child(end_point_x_ctrl)
	# End Point Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	end_point_group.add_child(y_lbl)
	var end_point_y_ctrl = NumberEdit.new()
	end_point_y_ctrl.name = "end_point_y_ctrl"
	end_point_y_ctrl.size_flags_horizontal = 3
	end_point_y_ctrl.set_text("0.0")
	end_point_y_ctrl.hint_tooltip = tr("RADIUS_ARC_END_POINT_Y_CTRL_HINT_TOOLTIP")
	end_point_group.add_child(end_point_y_ctrl)

	add_child(end_point_group)

	# Radius
	var radius_group = HBoxContainer.new()
	var radius_lbl = Label.new()
	radius_lbl.set_text("Radius: ")
	radius_group.add_child(radius_lbl)
	var radius_ctrl = NumberEdit.new()
	radius_ctrl.name = "radius_ctrl"
	radius_ctrl.size_flags_horizontal = 3
	radius_ctrl.CanBeNegative = true
	radius_ctrl.set_text("-10.0")
	radius_ctrl.hint_tooltip = tr("RADIUS_ARC_RADIUS_CTRL_HINT_TOOLTIP")
	radius_group.add_child(radius_ctrl)
	add_child(radius_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	var for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.name = "for_construction_ctrl"
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)

	add_child(const_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var end_point_x_ctrl = find_node("end_point_x_ctrl", true, false)
	var end_point_y_ctrl = find_node("end_point_y_ctrl", true, false)
	var radius_ctrl = find_node("radius_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not end_point_x_ctrl.is_valid:
		return false
	if not end_point_y_ctrl.is_valid:
		return false
	if not radius_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var end_point_x_ctrl = find_node("end_point_x_ctrl", true, false)
	var end_point_y_ctrl = find_node("end_point_y_ctrl", true, false)
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"end_point_x": end_point_x_ctrl.get_text(),
		"end_point_y": end_point_y_ctrl.get_text(),
		"radius": radius_ctrl.get_text(),
		"for_construction": for_construction_ctrl.pressed
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
	var end_point_x_ctrl = find_node("end_point_x_ctrl", true, false)
	var end_point_y_ctrl = find_node("end_point_y_ctrl", true, false)
	var radius_ctrl = find_node("radius_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

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

	# Radius
	rgx.compile(radius_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the radius control
		var radius = res.get_string()
		radius_ctrl.set_text(radius)

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
