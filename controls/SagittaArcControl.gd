extends VBoxContainer

class_name SagittaArcControl

var prev_template = null

var template = ".sagittaArc(endPoint=({end_point_x},{end_point_y}),sag={sag},forConstruction={for_construction})"

var end_point_edit_rgx = "(?<=endPoint\\=)(.*?)(?=,sag)"
var sag_edit_rgx = "(?<=sag\\=)(.*?)(?=\\,forConstruction)"
var const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"

var end_point_x_ctrl = null
var end_point_y_ctrl = null
var sag_ctrl = null
var for_construction_ctrl = null


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
	end_point_x_ctrl.set_text("10.0")
	end_point_group.add_child(end_point_x_ctrl)
	# End Point Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	end_point_group.add_child(y_lbl)
	end_point_y_ctrl = NumberEdit.new()
	end_point_y_ctrl.set_text("0.0")
	end_point_group.add_child(end_point_y_ctrl)

	add_child(end_point_group)

	# Sagitta
	var sag_group = HBoxContainer.new()
	var sag_lbl = Label.new()
	sag_lbl.set_text("Sag: ")
	sag_group.add_child(sag_lbl)
	sag_ctrl = NumberEdit.new()
	sag_ctrl.CanBeNegative = true
	sag_ctrl.set_text("-1.0")
	sag_group.add_child(sag_ctrl)
	add_child(sag_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	const_group.add_child(for_construction_ctrl)

	add_child(const_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not end_point_x_ctrl.is_valid:
		return false
	if not end_point_y_ctrl.is_valid:
		return false
	if not sag_ctrl.is_valid:
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
		"sag": sag_ctrl.get_text(),
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

	# Sagitta
	rgx.compile(sag_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sagitta control
		var sag = res.get_string()
		sag_ctrl.set_text(sag)

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
