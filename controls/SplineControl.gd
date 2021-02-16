extends VBoxContainer

class_name SplineControl

var template = ".spline(listOfXYTuple=[{listOfXYTuple}],tangents=[{tangents}],periodic={periodic},forConstruction={forConstruction},includeCurrent={includeCurrent},makeWire={makeWire})"

var prev_template = null

var tuple_edit_rgx = "(?<=listOfXYTuple\\=)(.*?)(?=\\,tangents)"
var tangents_edit_rgx = "(?<=tangents\\=)(.*?)(?=\\,periodic)"
var periodic_edit_rgx = "(?<=periodic\\=)(.*?)(?=\\,forConstruction)"
var construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\,includeCurrent)"
var current_edit_rgx = "(?<=includeCurrent\\=)(.*?)(?=\\,makeWire)"
var wire_edit_rgx = "(?<=makeWire\\=)(.*?)(?=\"\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\."

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

var hide_show_btn = null
var select_ctrl = null
var op_ctrl = null

var operation_visible = true
var selector_visible = true


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
	tuple_x_ctrl.set_text("1.0")
	pos_group.add_child(tuple_x_ctrl)
	# Y pos
	var y_length_lbl = Label.new()
	y_length_lbl.set_text("Y: ")
	pos_group.add_child(y_length_lbl)
	tuple_y_ctrl = LineEdit.new()
	tuple_y_ctrl.set_text("1.0")
	pos_group.add_child(tuple_y_ctrl)
	add_child(pos_group)

	# Button to add the current tuple to the list
	var add_tuple_btn = Button.new()
	add_tuple_btn.set_text("ADD")
	add_tuple_btn.connect("button_down", self, "_add_tuple")
	add_child(add_tuple_btn)

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
	tan_x_ctrl = LineEdit.new()
	tan_x_ctrl.set_text("1.0")
	tan_group.add_child(tan_x_ctrl)
	# Tan Y
	var y_tan_lbl = Label.new()
	y_tan_lbl.set_text("Y: ")
	tan_group.add_child(y_tan_lbl)
	tan_y_ctrl = LineEdit.new()
	tan_y_ctrl.set_text("1.0")
	tan_group.add_child(tan_y_ctrl)
	add_child(tan_group)

	# Button to add the current tuple to the list
	var add_tan_btn = Button.new()
	add_tan_btn.set_text("ADD")
	add_tan_btn.connect("button_down", self, "_add_tan")
	add_child(add_tan_btn)

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
	periodic_group.add_child(periodic_ctrl)
	add_child(periodic_group)

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

	# MAKE WIRE
	var wire_group = HBoxContainer.new()
	var wire_lbl = Label.new()
	wire_lbl.set_text("Make Wire: ")
	wire_group.add_child(wire_lbl)
	wire_ctrl = CheckBox.new()
	wire_ctrl.pressed = false
	wire_group.add_child(wire_ctrl)
	add_child(wire_group)

	# Show the selector control if it is enabled
	if selector_visible:
		# Add a horizontal rule to break things up
		add_child(HSeparator.new())

		# Allow the user to show/hide the selector controls that allow the rect to
		# be placed on something other than the current workplane
		hide_show_btn = CheckButton.new()
		hide_show_btn.set_text("Selectors: ")
		hide_show_btn.connect("button_down", self, "_show_selectors")
		add_child(hide_show_btn)

		# Add the face/edge selector control
		select_ctrl = SelectorControl.new()
		select_ctrl.hide()
		select_ctrl.config_visibility(true, false) # Only allow face selection
		add_child(select_ctrl)

	# Set the operation control if it is enabled
	if operation_visible:
		# Add a horizontal rule to break things up
		add_child(HSeparator.new())

		# Add the Operations control that will allow the user to select what to do (if anything)
		op_ctrl = OperationsControl.new()
		add_child(op_ctrl)


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
Called when the user clicks the add button to add the current
tangent X and Y to the list.
"""
func _add_tan():
	# Add the tangent X and Y values to different columns
	var new_tan_item = tan_ctrl.create_item(tan_ctrl_root)
	new_tan_item.set_text(0, tan_x_ctrl.get_text().get_text())
	new_tan_item.set_text(1, tan_y_ctrl.get_text().get_text())


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

	# If the selector control is visible, prepend its contents
	if selector_visible and select_ctrl.visible:
		complete += select_ctrl.get_completed_template()

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

	if operation_visible:
		# Check to see if there is an operation to apply to this geometry
		complete += op_ctrl.get_completed_template()

	return complete


"""
Show the selector controls.
"""
func _show_selectors():
	if select_ctrl.visible:
		select_ctrl.hide()
	else:
		select_ctrl.show()


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

	# Tangents
	rgx.compile(tangents_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Add the items back to the tuple list
		var pairs = res.get_string().split(",")
		for pair in pairs:
			var xy = pair.split(",")
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

	# Selector
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var sel = res.get_string()

		hide_show_btn.pressed = true
		select_ctrl.show()

		# Allow the selector control to set itself up appropriately
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))

	# Operation
	op_ctrl.set_values_from_string(text_line)


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	# Set whether or not the selector control is visible
	self.selector_visible = selector_visible
	self.operation_visible = operation_visible
