extends VBoxContainer

var ControlsCommon = load("res://controls/Common.gd").new()

class_name SlotControl

var prev_template = null

var template = ".slot2D(length={length},diameter={diameter},angle={angle})"

var length_edit_rgx = "(?<=.slot2D\\(length\\=)(.*?)(?=,diameter)"
var diameter_edit_rgx = "(?<=\\,diameter\\=)(.*?)(?=,angle)"
var angle_edit_rgx = "(?<=\\,angle\\=)(.*?)(?=\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\."

var length_ctrl = null
var diameter_ctrl = null
var angle_ctrl = null

var hide_show_btn = null
var select_ctrl = null
var op_ctrl = null

var operation_visible = true
var selector_visible = true

# Called when the node enters the scene tree for the first time
func _ready():
	# Slot length
	var length_group = HBoxContainer.new()
	var length_lbl = Label.new()
	length_lbl.set_text("Length: ")
	length_group.add_child(length_lbl)
	length_ctrl = LineEdit.new()
	length_ctrl.set_text("5.0")
	length_group.add_child(length_ctrl)
	add_child(length_group)

	# Diameter
	var diameter_group = HBoxContainer.new()
	var diameter_lbl = Label.new()
	diameter_lbl.set_text("Diameter: ")
	diameter_group.add_child(diameter_lbl)
	diameter_ctrl = LineEdit.new()
	diameter_ctrl.set_text("0.5")
	diameter_group.add_child(diameter_ctrl)
	add_child(diameter_group)

	# Angle
	var angle_group = HBoxContainer.new()
	var angle_lbl = Label.new()
	angle_lbl.set_text("Angle: ")
	angle_group.add_child(angle_lbl)
	angle_ctrl = LineEdit.new()
	angle_ctrl.set_text("0")
	angle_group.add_child(angle_ctrl)
	add_child(angle_group)

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

		# The selector control for where to locate the slot
		select_ctrl = SelectorControl.new()
		select_ctrl.config_visibility(true, false)
		select_ctrl.hide()
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

	# Fill out the main template
	complete += template.format({
		"length": length_ctrl.get_text(),
		"diameter": diameter_ctrl.get_text(),
		"angle": angle_ctrl.get_text()
		})

	if operation_visible:
		# Check to see if there is an operation to apply to this geometry
		complete += op_ctrl.get_completed_template()

	return complete


"""
Show the selector controls.
"""
func _show_selectors():
	if hide_show_btn.pressed:
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

	# Slot length
	rgx.compile(length_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the slot length
		var l = res.get_string()
		length_ctrl.set_text(l)

	# Slot diameter
	rgx.compile(diameter_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the slot diameter
		var d = res.get_string()
		diameter_ctrl.set_text(d)

	# Angle
	rgx.compile(angle_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the angle value
		var a = res.get_string()
		angle_ctrl.set_text(a)

	# Selectors
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		hide_show_btn.pressed = true

		var sel = res.get_string()
		# Pass the selector string to the selector control
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))

		select_ctrl.show()

	# Operation
	op_ctrl.set_values_from_string(text_line)


"""
Allows the caller to configure what is visible, useful for the Sketch tool.
"""
func config(selector_visible=true, operation_visible=true):
	# Set whether or not the selector control is visible
	self.selector_visible = selector_visible
	self.operation_visible = operation_visible
