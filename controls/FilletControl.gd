extends VBoxContainer

class_name FilletControl

var prev_template = null

#var select_ctrl = null
var radius_ctrl = null
#var hide_show_btn = null

var template = ".fillet({fillet_radius})"

var len_edit_rgx = "(?<=.fillet\\()(.*?)(?=\\))"
#var select_edit_rgx = "^.faces\\(.*\\)\\.edges\\(.*\\)\\."

func _ready():
	var radius_group = HBoxContainer.new()

	# Add the fillet radius control
	var radius_lbl = Label.new()
	radius_lbl.set_text("Radius: ")
	radius_group.add_child(radius_lbl)
	radius_ctrl = LineEdit.new()
	radius_ctrl.set_text("0.1")
	radius_group.add_child(radius_ctrl)
	add_child(radius_group)

	# Add a horizontal rule to break things up
#	add_child(HSeparator.new())

	# Allow the user to show/hide the selector controls that allow the rect to 
	# be placed on something other than the current workplane
#	hide_show_btn = CheckButton.new()
#	hide_show_btn.set_text("Selectors: ")
#	hide_show_btn.connect("button_down", self, "_show_selectors")
#	add_child(hide_show_btn)

	# Add the face/edge selector control
#	select_ctrl = SelectorControl.new()
#	select_ctrl.hide()
#	add_child(select_ctrl)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""
	
#	if select_ctrl.visible:
#		complete += select_ctrl.get_completed_template()
	
	complete += template.format({"fillet_radius": radius_ctrl.get_text()})

	return complete


"""
Show the selector controls.
"""
#func _show_selectors():
#	if hide_show_btn.pressed:
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
	rgx.compile(len_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		radius_ctrl.set_text(res.get_string())

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
