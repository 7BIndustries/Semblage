extends VBoxContainer

class_name PolarArrayControl

var prev_template = null

var template = ".polarArray({radius},startAngle={startAngle},angle={angle},count={count},fill={fill},rotate={rotate})"

var radius_edit_rgx = "(?<=.polarArray\\()(.*?)(?=,startAngle)"
var start_angle_edit_rgx = "(?<=startAngle\\=)(.*?)(?=\\,angle)"
var angle_edit_rgx = "(?<=angle\\=)(.*?)(?=\\,count)"
var count_edit_rgx = "(?<=count\\=)(.*?)(?=\\,fill)"
var fill_edit_rgx = "(?<=fill\\=)(.*?)(?=\\,rotate)"
var rotate_edit_rgx = "(?<=rotate\\=)(.*?)(?=\\))"
#var select_edit_rgx = "^.faces\\(.*\\)\\."

var radius_ctrl = null
var start_angle_ctrl = null
var angle_ctrl = null
var count_ctrl = null
var fill_ctrl = null
var rotate_ctrl = null

#var hide_show_btn = null
#var select_ctrl = null
#var op_ctrl = null

#var operation_visible = true
#var selector_visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the radius controls
	var rad_group = HBoxContainer.new()
	var rad_lbl = Label.new()
	rad_lbl.set_text("Radius: ")
	rad_group.add_child(rad_lbl)
	radius_ctrl = LineEdit.new()
	radius_ctrl.set_text("1.0")
	rad_group.add_child(radius_ctrl)
	add_child(rad_group)

	# Start Angle
	var start_angle_group = HBoxContainer.new()
	var start_angle_lbl = Label.new()
	start_angle_lbl.set_text("Start Angle: ")
	start_angle_group.add_child(start_angle_lbl)
	start_angle_ctrl = LineEdit.new()
	start_angle_ctrl.set_text("0.0")
	start_angle_group.add_child(start_angle_ctrl)
	add_child(start_angle_group)

	# Angle
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = LineEdit.new()
	angle_ctrl.set_text("360.0")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

	# Count
	var count_group = HBoxContainer.new()
	var count_lbl = Label.new()
	count_lbl.set_text("Count: ")
	count_group.add_child(count_lbl)
	count_ctrl = LineEdit.new()
	count_ctrl.set_text("5")
	count_group.add_child(count_ctrl)
	add_child(count_group)

	# Fill
	var fill_group = HBoxContainer.new()
	var fill_lbl = Label.new()
	fill_lbl.set_text("Fill: ")
	fill_group.add_child(fill_lbl)
	fill_ctrl = CheckBox.new()
	fill_ctrl.pressed = true
	fill_group.add_child(fill_ctrl)
	add_child(fill_group)

	# Rotate
	var rotate_group = HBoxContainer.new()
	var rotate_lbl = Label.new()
	rotate_lbl.set_text("Rotate: ")
	rotate_group.add_child(rotate_lbl)
	rotate_ctrl = CheckBox.new()
	rotate_ctrl.pressed = true
	rotate_group.add_child(rotate_ctrl)
	add_child(rotate_group)

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
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# If the selector control is visible, prepend its contents
#	if selector_visible and select_ctrl.visible:
#		complete += select_ctrl.get_completed_template()

	complete += template.format({
		"radius": radius_ctrl.get_text(),
		"startAngle": start_angle_ctrl.get_text(),
		"angle": angle_ctrl.get_text(),
		"count": count_ctrl.get_text(),
		"fill": fill_ctrl.pressed,
		"rotate": rotate_ctrl.pressed
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

	# Radius
	rgx.compile(radius_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# Start angle
	rgx.compile(start_angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var angle = res.get_string()
		start_angle_ctrl.set_text(angle)

	# Angle
	rgx.compile(angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var angle = res.get_string()
		angle_ctrl.set_text(angle)

	# Count
	rgx.compile(count_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var count = res.get_string()
		count_ctrl.set_text(count)

	# Fill
	rgx.compile(fill_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var fill = res.get_string()
		fill_ctrl.pressed = true if fill == "True" else false

	# Rotate
	rgx.compile(rotate_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var rotate = res.get_string()
		rotate_ctrl.pressed = true if rotate == "True" else false

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
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	pass
	# Set whether or not the selector control is visible
#	self.selector_visible = selector_visible
#	self.operation_visible = operation_visible
