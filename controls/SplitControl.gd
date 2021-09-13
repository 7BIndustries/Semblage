extends VBoxContainer

class_name SplitControl

var prev_template = null

var template = ".workplane({offset}).split(keepTop={keep_top},keepBottom={keep_bottom})"

const offset_edit_rgx = "(?<=.workplane\\()(.*?)(?=\\)\\.)"
const keep_top_edit_rgx = "(?<=\\.split\\(keepTop\\=)(.*?)(?=\\,keepBottom)"
const keep_bottom_edit_rgx = "(?<=keepBottom\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the controls for the offset of the split workplane
	var offset_group = HBoxContainer.new()
	var offset_lbl = Label.new()
	offset_lbl.set_text("Offset: ")
	offset_group.add_child(offset_lbl)
	var offset_ctrl = NumberEdit.new()
	offset_ctrl.name = "offset_ctrl"
	offset_ctrl.size_flags_horizontal = 3
	offset_ctrl.set_text("-0.5")
	offset_ctrl.CanBeNegative = true
	offset_ctrl.hint_tooltip = tr("WP_OFFSET_CTRL")
	offset_group.add_child(offset_ctrl)
	add_child(offset_group)

	# Add a horizontal rule to break things up
#	add_child(HSeparator.new())

	# Add the keep top checkbox
	var keep_top_group = HBoxContainer.new()
	var keep_top_lbl = Label.new()
	keep_top_lbl.set_text("Keep Top: ")
	keep_top_group.add_child(keep_top_lbl)
	var keep_top_ctrl = CheckBox.new()
	keep_top_ctrl.name = "keep_top_ctrl"
	keep_top_ctrl.pressed = false
	keep_top_ctrl.hint_tooltip = tr("SPLIT_KEEP_TOP_CTRL_HINT_TOOLTIP")
#	keep_top_ctrl.connect("button_down", self, "_keep_top_ctrl_button_down_event")
	keep_top_group.add_child(keep_top_ctrl)
	add_child(keep_top_group)

	# Add the keep bottom checkbox
	var keep_bottom_group = HBoxContainer.new()
	var keep_bottom_lbl = Label.new()
	keep_bottom_lbl.set_text("Keep Bottom: ")
	keep_bottom_group.add_child(keep_bottom_lbl)
	var keep_bottom_ctrl = CheckBox.new()
	keep_bottom_ctrl.name = "keep_bottom_ctrl"
	keep_bottom_ctrl.pressed = true
	keep_bottom_ctrl.hint_tooltip = tr("SPLIT_KEEP_BOTTOM_CTRL_HINT_TOOLTIP")
#	keep_bottom_ctrl.connect("button_down", self, "_keep_bottom_ctrl_button_down_event")
	keep_bottom_group.add_child(keep_bottom_ctrl)
	add_child(keep_bottom_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var offset_ctrl = find_node("offset_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not offset_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var offset_ctrl = find_node("offset_ctrl", true, false)
	var keep_top_ctrl = find_node("keep_top_ctrl", true, false)
	var keep_bottom_ctrl = find_node("keep_bottom_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"offset": offset_ctrl.get_text(),
		"keep_top": keep_top_ctrl.pressed,
		"keep_bottom": keep_bottom_ctrl.pressed
		})

	return complete


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
	var offset_ctrl = find_node("offset_ctrl", true, false)
	var keep_top_ctrl = find_node("keep_top_ctrl", true, false)
	var keep_bottom_ctrl = find_node("keep_bottom_ctrl", true, false)

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


"""
Called when the keep top button is clicked so that we can make
the top and bottom mutually exlusive for now.
"""
#func _keep_top_ctrl_button_down_event():
#	var keep_top_ctrl = find_node("keep_top_ctrl", true, false)
#	var keep_bottom_ctrl = find_node("keep_bottom_ctrl", true, false)
#
#	if keep_top_ctrl.pressed:
#		keep_bottom_ctrl.pressed = false


"""
Called when the keep bottom button is clicked so that we can make
the top and bottom mutually exlusive for now.
"""
#func _keep_bottom_ctrl_button_down_event():
#	var keep_top_ctrl = find_node("keep_top_ctrl", true, false)
#	var keep_bottom_ctrl = find_node("keep_bottom_ctrl", true, false)
#
#	if keep_bottom_ctrl.pressed:
#		keep_top_ctrl.pressed = false
