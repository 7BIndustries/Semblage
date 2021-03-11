extends VBoxContainer

class_name PolylineControl

var template = ".polyline(listOfXYTuple=[{listOfXYTuple}],forConstruction={forConstruction},includeCurrent={includeCurrent})"

var prev_template = null

var tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,forConstruction)"
var construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
var current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\"\\))"
#var select_edit_rgx = "^.faces\\(.*\\)\\."

var tuple_x_ctrl = null
var tuple_y_ctrl = null
var tuple_ctrl = null
var tuple_ctrl_root = null
var construction_ctrl = null
var current_ctrl = null

#var hide_show_btn = null
#var select_ctrl = null
#var op_ctrl = null

#var operation_visible = false
#var selector_visible = false

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
	tuple_x_ctrl = LineEdit.new()
	tuple_x_ctrl.set_text("10.0")
	pos_group.add_child(tuple_x_ctrl)
	# Y pos
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	pos_group.add_child(y_length_lbl)
	tuple_y_ctrl = LineEdit.new()
	tuple_y_ctrl.set_text("10.0")
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
	construction_group.add_child(construction_ctrl)
	add_child(construction_group)

	# INCLUDE CURRENT
	var current_group = HBoxContainer.new()
	var current_lbl = Label.new()
	current_lbl.set_text("Include Current: ")
	current_group.add_child(current_lbl)
	current_ctrl = CheckBox.new()
	current_ctrl.pressed = false
	current_group.add_child(current_ctrl)
	add_child(current_group)

	# Show the selector control if it is enabled
#	if selector_visible:
#		# Add a horizontal rule to break things up
#		add_child(HSeparator.new())
#
#		# Allow the user to show/hide the selector controls that allow the rect to
#		# be placed on something other than the current workplane
#		hide_show_btn = CheckButton.new()
#		hide_show_btn.set_text("Selectors: ")
#		hide_show_btn.connect("button_down", self, "_show_selectors")
#		add_child(hide_show_btn)
#
#		# Add the face/edge selector control
#		select_ctrl = SelectorControl.new()
#		select_ctrl.hide()
#		select_ctrl.config_visibility(true, false) # Only allow face selection
#		add_child(select_ctrl)

	# Set the operation control if it is enabled
#	if operation_visible:
#		# Add a horizontal rule to break things up
#		add_child(HSeparator.new())
#
#		# Add the Operations control that will allow the user to select what to do (if anything)
#		op_ctrl = OperationsControl.new()
#		add_child(op_ctrl)


"""
Called when the user clicks the add button to add the current
tuple X and Y to the list.
"""
func _add_tuple():
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

	# If the selector control is visible, prepend its contents
#	if selector_visible and select_ctrl.visible:
#		complete += select_ctrl.get_completed_template()

	# Collect the tuple pairs
	var tuple_pairs = Common.collect_pairs(tuple_ctrl)

	complete += template.format({
		"listOfXYTuple": tuple_pairs,
		"forConstruction": construction_ctrl.pressed,
		"includeCurrent": current_ctrl.pressed
		})

#	if operation_visible:
#		# Check to see if there is an operation to apply to this geometry
#		complete += op_ctrl.get_completed_template()

	return complete


"""
Show the selector controls.
"""
#func _show_selectors():
#	if select_ctrl.visible:
#		select_ctrl.hide()
#	else:
#		select_ctrl.show()


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

	# Selector
#	rgx.compile(select_edit_rgx)
#	res = rgx.search(text_line)
#	if res:
#		var sel = res.get_string()
#
#		hide_show_btn.pressed = true
#		select_ctrl.show()
#
#		# Allow the selector control to set itself up appropriately
#		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))

	# Operation
#	op_ctrl.set_values_from_string(text_line)


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
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
	# Set whether or not the selector control is visible
#	self.selector_visible = false #selector_visible
#	self.operation_visible = false #operation_visible
