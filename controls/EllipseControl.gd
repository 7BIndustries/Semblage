extends VBoxContainer

class_name EllipseControl

var prev_template = null

var template = ".ellipse({x_radius},{y_radius},rotation_angle={rotation_angle},forConstruction={forConstruction})"

var radius_edit_rgx = "(?<=.ellipseArc\\()(.*?)(?=,angle1)"
var rotation_angle_edit_rgx = "(?<=rotation_angle\\=)(.*?)(?=\\,sense)"
var for_construction_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\."

var x_radius_ctrl = null
var y_radius_ctrl = null
var rotation_angle_ctrl = null
var for_construction_ctrl = null

var hide_show_btn = null
var select_ctrl = null
var op_ctrl = null

var operation_visible = true
var selector_visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	# X Radius
	var x_radius_group = HBoxContainer.new()
	var x_radius_lbl = Label.new()
	x_radius_lbl.set_text("X Radius: ")
	x_radius_group.add_child(x_radius_lbl)
	x_radius_ctrl = LineEdit.new()
	x_radius_ctrl.set_text("5.0")
	x_radius_group.add_child(x_radius_ctrl)
	add_child(x_radius_group)

	# Y Radius
	var y_radius_group = HBoxContainer.new()
	var y_radius_lbl = Label.new()
	y_radius_lbl.set_text("Y Radius: ")
	y_radius_group.add_child(y_radius_lbl)
	y_radius_ctrl = LineEdit.new()
	y_radius_ctrl.set_text("10.0")
	y_radius_group.add_child(y_radius_ctrl)
	add_child(y_radius_group)

	# Rotation angle
	var rotation_angle_group = HBoxContainer.new()
	var rotation_angle_lbl = Label.new()
	rotation_angle_lbl.set_text("Rotation Angle: ")
	rotation_angle_group.add_child(rotation_angle_lbl)
	rotation_angle_ctrl = LineEdit.new()
	rotation_angle_ctrl.set_text("0.0")
	rotation_angle_group.add_child(rotation_angle_ctrl)
	add_child(rotation_angle_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)

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
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# If the selector control is visible, prepend its contents
	if selector_visible and select_ctrl.visible:
		complete += select_ctrl.get_completed_template()

	complete += template.format({
		"x_radius": x_radius_ctrl.get_text(),
		"y_radius": y_radius_ctrl.get_text(),
		"rotation_angle": rotation_angle_ctrl.get_text(),
		"forConstruction": for_construction_ctrl.pressed
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

	# X and Y Radii
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the X and Y radii controls
		var xy = res.get_string().split(",")
		x_radius_ctrl.set_text(xy[0])
		y_radius_ctrl.set_text(xy[1])

	# Rotation angle
	rgx.compile(rotation_angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the rotation angle controls
		var rotation_angle = res.get_string()
		rotation_angle_ctrl.set_text(rotation_angle)

	# For construction
	rgx.compile(for_construction_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false

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
