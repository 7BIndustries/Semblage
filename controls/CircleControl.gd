extends VBoxContainer

class_name CircleControl

var prev_template = null

var template = ".circle({radius},forConstruction={for_construction})"

var rad_edit_rgx = "(?<=.circle\\()(.*?)(?=,forConstruction)"
var const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\."

var radius_ctrl = null
var for_construction_ctrl = null

var hide_show_btn = null
var select_ctrl = null
var op_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var rad_group = HBoxContainer.new()

	# Width (X length)
	var rad_lbl = Label.new()
	rad_lbl.set_text("Radius: ")
	rad_group.add_child(rad_lbl)
	radius_ctrl = LineEdit.new()
	radius_ctrl.set_text("1.0")
	rad_group.add_child(radius_ctrl)
	add_child(rad_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)

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
	if select_ctrl.visible:
		complete += select_ctrl.get_completed_template()

	complete += template.format({
		"radius": radius_ctrl.get_text(),
		"for_construction": for_construction_ctrl.pressed
		})

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

	# Rect dimensions
	rgx.compile(rad_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false

	# Selector
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var sel = res.get_string()

		_show_selectors()

		# Allow the selector control to set itself up appropriately
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))

	# Operation
	op_ctrl.set_values_from_string(text_line)
