extends VBoxContainer

class_name RArrayControl

var prev_template = null

var template = ".rarray({xSpacing},{ySpacing},{xCount},{yCount},center={centered})"

var dims_edit_rgx = "(?<=.rarray\\()(.*?)(?=,center)"
var centered_edit_rgx = "(?<=center\\=)(.*?)(?=\\))"
#var select_edit_rgx = "^.faces\\(.*\\)\\."

var x_spacing_ctrl = null
var y_spacing_ctrl = null
var x_count_ctrl = null
var y_count_ctrl = null
var centered_ctrl = null

#var hide_show_btn = null
#var select_ctrl = null
#var op_ctrl = null

#var operation_visible = true
#var selector_visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	var spacing_lbl = Label.new()
	spacing_lbl.set_text("Spacing")
	add_child(spacing_lbl)

	# Add the rarray dimension controls
	var spacing_group = HBoxContainer.new()
	# X spacing
	var x_spacing_lbl = Label.new()
	x_spacing_lbl.set_text("X: ")
	spacing_group.add_child(x_spacing_lbl)
	x_spacing_ctrl = LineEdit.new()
	x_spacing_ctrl.set_text("1.0")
	spacing_group.add_child(x_spacing_ctrl)
	# Y spacing
	var y_spacing_lbl = Label.new()
	y_spacing_lbl.set_text("Y: ")
	spacing_group.add_child(y_spacing_lbl)
	y_spacing_ctrl = LineEdit.new()
	y_spacing_ctrl.set_text("1.0")
	spacing_group.add_child(y_spacing_ctrl)
	add_child(spacing_group)

	var count_lbl = Label.new()
	count_lbl.set_text("Count")
	add_child(count_lbl)

	# Add the rarray dimension controls
	var count_group = HBoxContainer.new()
	# X spacing
	var x_count_lbl = Label.new()
	x_count_lbl.set_text("X: ")
	count_group.add_child(x_count_lbl)
	x_count_ctrl = LineEdit.new()
	x_count_ctrl.set_text("1")
	count_group.add_child(x_count_ctrl)
	# Y spacing
	var y_count_lbl = Label.new()
	y_count_lbl.set_text("Y: ")
	count_group.add_child(y_count_lbl)
	y_count_ctrl = LineEdit.new()
	y_count_ctrl.set_text("1")
	count_group.add_child(y_count_ctrl)
	add_child(count_group)

	# Add the centered control
	var centered_group = HBoxContainer.new()
	var centered_lbl = Label.new()
	centered_lbl.set_text("Centered: ")
	centered_group.add_child(centered_lbl)
	centered_ctrl = CheckBox.new()
	centered_ctrl.pressed = true
	centered_group.add_child(centered_ctrl)
	add_child(centered_group)

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
		"xSpacing": x_spacing_ctrl.get_text(),
		"ySpacing": y_spacing_ctrl.get_text(),
		"xCount": x_count_ctrl.get_text(),
		"yCount": y_count_ctrl.get_text(),
		"centered": centered_ctrl.pressed
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

	# Rect dimensions
	rgx.compile(dims_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var sc = res.get_string().split(",")
		x_spacing_ctrl.set_text(sc[0])
		y_spacing_ctrl.set_text(sc[1])
		x_count_ctrl.set_text(sc[2])
		y_count_ctrl.set_text(sc[3])

	# Centered
	rgx.compile(centered_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cen = res.get_string()
		centered_ctrl.pressed = true if cen == "True" else false

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
