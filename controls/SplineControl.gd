extends VBoxContainer

class_name SplineControl

signal error

var is_binary = false

var template = ".spline(listOfXYTuple=[{listOfXYTuple}],tangents=[{tangents}],periodic={periodic},forConstruction={forConstruction},includeCurrent={includeCurrent},makeWire={makeWire})"

var prev_template = null

const tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,tangents)"
const tangents_edit_rgx = "(?<=tangents\\=)(.*?)(?=\\,periodic)"
const periodic_edit_rgx = "(?<=periodic\\=)(.*?)(?=\\,forConstruction)"
const construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
const current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\\,makeWire)"
const wire_edit_rgx = "(?<=makeWire\\=)(.*?)(?=\"\\))"

var tuple_x_ctrl = null
var tuple_y_ctrl = null
var tuple_ctrl = null
var tuple_ctrl_root = null
var tan_x_ctrl = null
var tan_y_ctrl = null
var tan_ctrl = null
var tan_ctrl_root = null
var periodic_ctrl = null
var construction_ctrl = null
var current_ctrl = null
var wire_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# POINTS
	var new_tuple_lbl = Label.new()
	new_tuple_lbl.set_text("New Point")
	add_child(new_tuple_lbl)

	# X pos
	var pos_group = HBoxContainer.new()
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("X: ")
	pos_group.add_child(x_length_lbl)
	tuple_x_ctrl = NumberEdit.new()
	tuple_x_ctrl.set_text("10.0")
	tuple_x_ctrl.hint_tooltip = tr("SPLINE_TUPLE_X_CTRL_HINT_TOOLTIP")
	pos_group.add_child(tuple_x_ctrl)
	# Y pos
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	pos_group.add_child(y_length_lbl)
	tuple_y_ctrl = NumberEdit.new()
	tuple_y_ctrl.set_text("10.0")
	tuple_y_ctrl.hint_tooltip = tr("SPLINE_TUPLE_Y_CTRL_HINT_TOOLTIP")
	pos_group.add_child(tuple_y_ctrl)
	add_child(pos_group)

	var tuple_btn_group = HBoxContainer.new()

	# Button to add the current tuple to the list
	var add_tuple_btn = Button.new()
	add_tuple_btn.icon = load("res://assets/icons/add_tree_item_button_flat_ready.svg")
	add_tuple_btn.hint_tooltip = tr("SPLINE_ADD_TUPLE_BTN_HINT_TOOLTIP")
	add_tuple_btn.connect("button_down", self, "_add_tuple")
	tuple_btn_group.add_child(add_tuple_btn)

	# Button to remove the current tuple from the list
	var delete_tuple_btn = Button.new()
	delete_tuple_btn.icon = load("res://assets/icons/delete_tree_item_button_flat_ready.svg")
	delete_tuple_btn.hint_tooltip = tr("SPLINE_DELETE_TUPLE_BTN_HINT_TOOLTIP")
	delete_tuple_btn.connect("button_down", self, "_delete_tuple")
	tuple_btn_group.add_child(delete_tuple_btn)

	add_child(tuple_btn_group)

	# Label for the points list
	var points_lbl = Label.new()
	points_lbl.set_text("Points")
	add_child(points_lbl)

	# The tree to hold the tuples
	tuple_ctrl = Tree.new()
	tuple_ctrl.columns = 2
	tuple_ctrl.rect_min_size = Vector2(50, 50)
	tuple_ctrl.hide_root = true
	tuple_ctrl_root = tuple_ctrl.create_item()
	tuple_ctrl_root.set_text(0, "tuples")
	add_child(tuple_ctrl)

	# TANGENTS
	var new_tangent_lbl = Label.new()
	new_tangent_lbl.set_text("New Tangent")
	add_child(new_tangent_lbl)

	# Tan X
	var tan_group = HBoxContainer.new()
	var x_tan_lbl = Label.new()
	x_tan_lbl.set_text("X: ")
	tan_group.add_child(x_tan_lbl)
	tan_x_ctrl = NumberEdit.new()
	tan_x_ctrl.set_text("1.0")
	tan_x_ctrl.hint_tooltip = tr("SPLINE_TAN_X_CTRL_HINT_TOOLTIP")
	tan_group.add_child(tan_x_ctrl)
	# Tan Y
	var y_tan_lbl = Label.new()
	y_tan_lbl.set_text("Y: ")
	tan_group.add_child(y_tan_lbl)
	tan_y_ctrl = NumberEdit.new()
	tan_y_ctrl.set_text("1.0")
	tan_y_ctrl.hint_tooltip = tr("SPLINE_TAN_Y_CTRL_HINT_TOOLTIP")
	tan_group.add_child(tan_y_ctrl)
	add_child(tan_group)

	var tan_btn_group = HBoxContainer.new()
	# Button to add the current tuple to the list
	var add_tan_btn = Button.new()
	add_tan_btn.icon = load("res://assets/icons/add_tree_item_button_flat_ready.svg")
	add_tan_btn.hint_tooltip = tr("SPLINE_ADD_TAN_BTN_HINT_TOOLTIP")
	add_tan_btn.connect("button_down", self, "_add_tan")
	tan_btn_group.add_child(add_tan_btn)
	add_child(tan_btn_group)
	var delete_tan_btn = Button.new()
	delete_tan_btn.icon = load("res://assets/icons/delete_tree_item_button_flat_ready.svg")
	delete_tan_btn.hint_tooltip = tr("SPLINE_DELETE_TAN_BTN_HINT_TOOLTIP")
	delete_tan_btn.connect("button_down", self, "_delete_tan")
	tan_btn_group.add_child(delete_tan_btn)
	add_child(tan_btn_group)

	# Label for the points list
	var tans_lbl = Label.new()
	tans_lbl.set_text("Tangents")
	add_child(tans_lbl)

	# The tree to hold the tuples
	tan_ctrl = Tree.new()
	tan_ctrl.columns = 2
	tan_ctrl.rect_min_size = Vector2(50, 50)
	tan_ctrl.hide_root = true
	tan_ctrl_root = tan_ctrl.create_item()
	tan_ctrl_root.set_text(0, "tangents")
	add_child(tan_ctrl)

	# PERIODIC
	var periodic_group = HBoxContainer.new()
	var periodic_lbl = Label.new()
	periodic_lbl.set_text("Periodic: ")
	periodic_group.add_child(periodic_lbl)
	periodic_ctrl = CheckBox.new()
	periodic_ctrl.pressed = false
	periodic_ctrl.hint_tooltip = tr("SPLINE_PERIODIC_CTRL_HINT_TOOLTIP")
	periodic_group.add_child(periodic_ctrl)
	add_child(periodic_group)

	# FOR CONSTRUCTION
	var construction_group = HBoxContainer.new()
	var construction_lbl = Label.new()
	construction_lbl.set_text("For Construction: ")
	construction_group.add_child(construction_lbl)
	construction_ctrl = CheckBox.new()
	construction_ctrl.pressed = false
	construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	construction_group.add_child(construction_ctrl)
	add_child(construction_group)

	# INCLUDE CURRENT
	var current_group = HBoxContainer.new()
	var current_lbl = Label.new()
	current_lbl.set_text("Include Current: ")
	current_group.add_child(current_lbl)
	current_ctrl = CheckBox.new()
	current_ctrl.pressed = false
	current_ctrl.hint_tooltip = tr("INCLUDE_CTRL_HINT_TOOLTIP")
	current_group.add_child(current_ctrl)
	add_child(current_group)

	# MAKE WIRE
	var wire_group = HBoxContainer.new()
	var wire_lbl = Label.new()
	wire_lbl.set_text("Make Wire: ")
	wire_group.add_child(wire_lbl)
	wire_ctrl = CheckBox.new()
	wire_ctrl.pressed = false
	wire_ctrl.hint_tooltip = tr("ARC_MAKE_WIRE_CTRL_HINT_TOOLTIP")
	wire_group.add_child(wire_ctrl)
	add_child(wire_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not tuple_x_ctrl.is_valid:
		return false
	if not tan_y_ctrl.is_valid:
		return false

	return true


"""
Called when the user clicks the add button to add the current
tuple X and Y to the list.
"""
func _add_tuple():
	if not is_valid():
		var res = connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		if res != 0:
			print("Error connecting a signal: " + str(res))
		else:
			emit_signal("error", "There is invalid tuple data in the form.")

		return

	# Add the tuple X and Y values to different columns
	var new_tuple_item = tuple_ctrl.create_item(tuple_ctrl_root)

	# Add the items to the tree
	new_tuple_item.set_text(0, tuple_x_ctrl.get_text())
	new_tuple_item.set_text(1, tuple_y_ctrl.get_text())


"""
Allows a tuple tree item to be removed.
"""
func _delete_tuple():
	# Get the selected item in the tuple list/tree
	var selected = tuple_ctrl.get_selected()

	# Make sure there is something to remove
	if selected != null:
		selected.free()


"""
Called when the user clicks the add button to add the current
tangent X and Y to the list.
"""
func _add_tan():
	if not is_valid():
		var res = connect("error", self.find_parent("ActionPopupPanel"), "_on_error")
		if res != 0:
			print("Error connecting a signal: " + str(res))
		else:
			emit_signal("error", "There is invalid tuple data in the form.")

		return

	# Add the tangent X and Y values to different columns
	var new_tan_item = tan_ctrl.create_item(tan_ctrl_root)
	new_tan_item.set_text(0, tan_x_ctrl.get_text())
	new_tan_item.set_text(1, tan_y_ctrl.get_text())


"""
Allows a tuple tree item to be removed.
"""
func _delete_tan():
	# Get the selected item in the tuple list/tree
	var selected = tan_ctrl.get_selected()

	# Make sure there is something to remove
	if selected != null:
		selected.free()


"""
Allows the tuple list to be populated via string.
"""
func _add_tuple_xy(x, y):
	# Add the tuple X and Y values to different columns
	var new_tuple_item = tuple_ctrl.create_item(tuple_ctrl_root)

	# Add the items to the tree
	new_tuple_item.set_text(0, x)
	new_tuple_item.set_text(1, y)


"""
Allows the tangents list to be populated via string.
"""
func _add_tan_xy(x, y):
	# Add the tangent X and Y values to different columns
	var new_tan_item = tan_ctrl.create_item(tan_ctrl_root)
	new_tan_item.set_text(0, x)
	new_tan_item.set_text(1, y)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Collect the tuple pairs
	var tuple_pairs = Common.collect_pairs(tuple_ctrl)

	# Collect the tangent pairs
	var tan_pairs = Common.collect_pairs(tan_ctrl)

	complete += template.format({
		"listOfXYTuple": tuple_pairs,
		"tangents": tan_pairs,
		"periodic": periodic_ctrl.pressed,
		"forConstruction": construction_ctrl.pressed,
		"includeCurrent": current_ctrl.pressed,
		"makeWire": wire_ctrl.pressed,
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

	# Tuples
	rgx.compile(tuple_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Add the items back to the tuple list
		var pairs = res.get_string().split(",")
		for pair in pairs:
			var xy = pair.split(",")
			# Safety catch for a trailing comma in the point list
			if xy.size() < 2:
				continue

			_add_tuple_xy(xy[0], xy[1])

	# Tangents
	rgx.compile(tangents_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Add the items back to the tuple list
		var pairs = res.get_string().split(",")
		for pair in pairs:
			var xy = pair.split(",")
			# Safety catch for a trailing comma in the point list
			if xy.size() < 2:
				continue

			_add_tan_xy(xy[0], xy[1])

	# Periodic
	rgx.compile(periodic_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var per = res.get_string()
		periodic_ctrl.pressed = true if per == "True" else false

	# For construction
	rgx.compile(construction_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		construction_ctrl.pressed = true if constr == "True" else false

	# Include current
	rgx.compile(current_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cur = res.get_string()
		current_ctrl.pressed = true if cur == "True" else false

	# Make wire
	rgx.compile(wire_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var wire = res.get_string()
		wire_ctrl.pressed = true if wire == "True" else false
