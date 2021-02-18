extends VBoxContainer

class_name ShellControl

var prev_template = null

var template = ".shell(thickness={thickness},kind=\"{kind}\")"

var thickness_edit_rgx = "(?<=thickness\\=)(.*?)(?=\\,)"
var kind_edit_rgx = "(?<=kind\\=\")(.*?)(?=\"\\)"
var select_edit_rgx = "^.faces\\(.*\\)\\."

var thickness_ctrl = null
var kind_ctrl = null

var select_ctrl = null
#var select_ctrl_2 = null

var kind_list = ["arc", "intersection"]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Thickness selection
	var thickness_group = HBoxContainer.new()
	var thickness_lbl = Label.new()
	thickness_lbl.set_text("Thickness: ")
	thickness_group.add_child(thickness_lbl)
	thickness_ctrl = LineEdit.new()
	thickness_ctrl.set_text("0.1")
	thickness_group.add_child(thickness_ctrl)
	add_child(thickness_group)

	# Kind control
	var kind_group = HBoxContainer.new()
	var kind_lbl = Label.new()
	kind_lbl.set_text("Kind: ")
	kind_group.add_child(kind_lbl)
	kind_ctrl = OptionButton.new()
	Common.load_option_button(kind_ctrl, kind_list)
	kind_group.add_child(kind_ctrl)
	add_child(kind_group)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	# Add the face/edge selector control
	select_ctrl = SelectorControl.new()
	select_ctrl.config_visibility(true, false) # Only allow face selection
	add_child(select_ctrl)

	# TODO: Allow selection of additional faces

	# Allow the user to show/hide the selector controls that allow selection of 
	# additional faces
#	var hide_show_btn = Button.new()
#	hide_show_btn.set_text("Additional Face(s)")
#	hide_show_btn.connect("button_down", self, "_show_selectors")
#	add_child(hide_show_btn)

#	select_ctrl_2 = SelectorControl.new()
#	select_ctrl_2.config_visibility(true, false)
#	select_ctrl_2.hide()
#	add_child(select_ctrl_2)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# If the selector control is visible, prepend its contents
	complete += select_ctrl.get_completed_template()

	complete += template.format({
		"thickness": thickness_ctrl.get_text(),
		"kind": kind_ctrl.get_item_text(kind_ctrl.get_selected_id())
		})

	return complete


"""
Show the selector controls.
"""
#func _show_selectors():
#	if select_ctrl_2.visible:
#		select_ctrl_2.hide()
#	else:
#		select_ctrl_2.show()


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

	# Thickness edit
	rgx.compile(thickness_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		thickness_ctrl.set_text(res.get_string())

	# Kind edit
	rgx.compile(kind_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(kind_ctrl, res.get_string())

	# Selector
	rgx.compile(select_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var sel = res.get_string()

		# Allow the selector control to set itself up appropriately
		select_ctrl.set_values_from_string(sel.left(sel.length() - 1))
