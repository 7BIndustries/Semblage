extends VBoxContainer

class_name SplitControl

var prev_template = null

var template = ".workplane({offset}).split(keepTop={keep_top},keepBottom={keep_bottom})"

var offset_edit_rgx = "(?<=.workplane\\()(.*?)(?=\\)\\.)"
var keep_top_edit_rgx = "(?<=\\.split\\(keepTop\\=)(.*?)(?=\\,keepBottom)"
var keep_bottom_edit_rgx = "(?<=keepBottom\\=)(.*?)(?=\\))"
var select_edit_rgx = "^.faces\\(.*\\)\\."

var offset_ctrl = null
var keep_top_ctrl = null
var keep_bottom_ctrl = null

var hide_show_btn = null
var select_ctrl = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the controls for the offset of the split workplane
	var offset_group = HBoxContainer.new()
	var offset_lbl = Label.new()
	offset_lbl.set_text("Offset: ")
	offset_group.add_child(offset_lbl)
	offset_ctrl = LineEdit.new()
	offset_ctrl.set_text("-0.5")
	offset_group.add_child(offset_ctrl)
	add_child(offset_group)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	# Add the keep top checkbox
	var keep_top_group = HBoxContainer.new()
	var keep_top_lbl = Label.new()
	keep_top_lbl.set_text("Keep Top: ")
	keep_top_group.add_child(keep_top_lbl)
	keep_top_ctrl = CheckBox.new()
	keep_top_ctrl.pressed = false
	keep_top_ctrl.connect("button_down", self, "_keep_top_ctrl_button_down_event")
	keep_top_group.add_child(keep_top_ctrl)
	add_child(keep_top_group)

	# Add the keep bottom checkbox
	var keep_bottom_group = HBoxContainer.new()
	var keep_bottom_lbl = Label.new()
	keep_bottom_lbl.set_text("Keep Bottom: ")
	keep_bottom_group.add_child(keep_bottom_lbl)
	keep_bottom_ctrl = CheckBox.new()
	keep_bottom_ctrl.pressed = true
	keep_bottom_ctrl.connect("button_down", self, "_keep_bottom_ctrl_button_down_event")
	keep_bottom_group.add_child(keep_bottom_ctrl)
	add_child(keep_bottom_group)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	# Allow the user to show/hide the selector controls that allow the rect to 
	# be placed on something other than the current workplane
	hide_show_btn = CheckButton.new()
	hide_show_btn.set_text("Selectors: ")
	hide_show_btn.pressed = true
	hide_show_btn.connect("button_down", self, "_show_selectors")
	add_child(hide_show_btn)

	# Add the face/edge selector control
	select_ctrl = SelectorControl.new()
	select_ctrl.show()
	select_ctrl.config_visibility(true, false) # Only allow face selection
	add_child(select_ctrl)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# If the selector control is visible, prepend its contents
	if select_ctrl.visible:
		complete += select_ctrl.get_completed_template()

	complete += template.format({
		"offset": offset_ctrl.get_text(),
		"keep_top": keep_top_ctrl.pressed,
		"keep_bottom": keep_bottom_ctrl.pressed
		})

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

	# Split offset
	rgx.compile(offset_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var offset = res.get_string()
		offset_ctrl.set_text(offset)

	# Keep top checkbox
	rgx.compile(keep_top_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var keep_top = res.get_string()
		keep_top_ctrl.pressed = true if keep_top == "True" else false

	# Keep bottom checkbox
	rgx.compile(keep_bottom_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var keep_bottom = res.get_string()
		keep_bottom_ctrl.pressed = true if keep_bottom == "True" else false

	# Selector
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var sel = res.get_string()

		hide_show_btn.pressed = true
		select_ctrl.show()

		# Allow the selector control to set itself up appropriately
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))
	else:
		hide_show_btn.pressed = false
		select_ctrl.hide()


"""
Called when the keep top button is clicked so that we can make
the top and bottom mutually exlusive for now.
"""
func _keep_top_ctrl_button_down_event():
	if keep_top_ctrl.pressed:
		keep_bottom_ctrl.pressed = false


"""
Called when the keep bottom button is clicked so that we can make
the top and bottom mutually exlusive for now.
"""
func _keep_bottom_ctrl_button_down_event():
	if keep_bottom_ctrl.pressed:
		keep_top_ctrl.pressed = false
