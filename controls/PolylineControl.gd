extends VBoxContainer

class_name PolylineControl

signal error

var template = ".polyline(listOfXYTuple=[{listOfXYTuple}],forConstruction={forConstruction},includeCurrent={includeCurrent})"

var prev_template = null

const tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,forConstruction)"
const construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
const current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\"\\))"

var tuple_x_ctrl = null
var tuple_y_ctrl = null
var tuple_ctrl = null
var tuple_ctrl_root = null
var construction_ctrl = null
var current_ctrl = null


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
	tuple_x_ctrl.hint_tooltip = tr("POLYLINE_TUPLE_X_CTRL_HINT_TOOLTIP")
	pos_group.add_child(tuple_x_ctrl)
	# Y pos
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	pos_group.add_child(y_length_lbl)
	tuple_y_ctrl = NumberEdit.new()
	tuple_y_ctrl.set_text("10.0")
	tuple_y_ctrl.hint_tooltip = tr("POLYLINE_TUPLE_Y_CTRL_HINT_TOOLTIP")
	pos_group.add_child(tuple_y_ctrl)
	add_child(pos_group)

	var tuple_btn_group = HBoxContainer.new()

	# Button to add the current tuple to the list
	var add_tuple_btn = Button.new()
	add_tuple_btn.icon = load("res://assets/icons/add_tree_item_button_flat_ready.svg")
	add_tuple_btn.connect("button_down", self, "_add_tuple")
	tuple_btn_group.add_child(add_tuple_btn)

	# Button to remove the current tuple from the list
	var delete_tuple_btn = Button.new()
	delete_tuple_btn.icon = load("res://assets/icons/delete_tree_item_button_flat_ready.svg")
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
	if not tuple_x_ctrl.is_valid:
		return false
	if not tuple_y_ctrl.is_valid:
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
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Collect the tuple pairs
	var tuple_pairs = Common.collect_pairs(tuple_ctrl)

	complete += template.format({
		"listOfXYTuple": tuple_pairs,
		"forConstruction": construction_ctrl.pressed,
		"includeCurrent": current_ctrl.pressed
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
			_add_tuple_xy(xy[0], xy[1])

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


"""
Allows the tuple list to be populated via string.
"""
func _add_tuple_xy(x, y):
	# Add the tuple X and Y values to different columns
	var new_tuple_item = tuple_ctrl.create_item(tuple_ctrl_root)

	# Add the items to the tree
	new_tuple_item.set_text(0, x)
	new_tuple_item.set_text(1, y)
