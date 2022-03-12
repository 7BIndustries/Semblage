extends VBoxContainer

class_name ChainedWorkplaneControl

var prev_template = null

var template = ".workplane(offset={offset},invert={invert},centerOption=\"{center_option}\")" #.tag(\"{comp_name}\")"

const center_option_list = ["CenterOfBoundBox", "CenterOfMass", "ProjectedOrigin"]

const wp_cen_edit_rgx = "(?<=centerOption\\=\")(.*?)(?=\"\\))"
const invert_edit_rgx = "(?<=invert\\=)(.*?)(?=,centerOption)"
const offset_edit_rgx = "(?<=offset\\=)(.*?)(?=,invert)"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add a control for the center option
	var wp_cen_group = HBoxContainer.new()
	var wp_cen_lbl = Label.new()
	wp_cen_lbl.set_text("Center Option: ")
	wp_cen_group.add_child(wp_cen_lbl)
	var wp_cen_ctrl = OptionButton.new()
	wp_cen_ctrl.name = "wp_cen_ctrl"
	Common.load_option_button(wp_cen_ctrl, center_option_list)
	wp_cen_ctrl.hint_tooltip = tr("WP_CEN_CTRL_HINT_TOOLTIP")
	wp_cen_group.add_child(wp_cen_ctrl)
	add_child(wp_cen_group)

	# Allow the user to set the offset for the workplane away from the origin in the direction defined by the normal
	var offset_group = HBoxContainer.new()
	offset_group.name = "offset_group"
	var offset_lbl = Label.new()
	offset_lbl.set_text("Offset: ")
	offset_group.add_child(offset_lbl)
	var offset_ctrl = NumberEdit.new()
	offset_ctrl.name = "offset_ctrl"
	offset_ctrl.set_text("0.0")
	offset_ctrl.size_flags_horizontal = 3
	offset_ctrl.hint_tooltip = tr("WP_OFFSET_CTRL")
	offset_ctrl.CanBeNegative = true
	offset_group.add_child(offset_ctrl)
	add_child(offset_group)

	# Allow the user to set whether the workplane normal is inverted
	var invert_group = HBoxContainer.new()
	var invert_lbl = Label.new()
	invert_lbl.set_text("Invert: ")
	invert_group.add_child(invert_lbl)
	var invert_ctrl = CheckBox.new()
	invert_ctrl.name = "invert_ctrl"
	invert_ctrl.pressed = false
	invert_ctrl.hint_tooltip = tr("INVERT_CTRL_HINT_TOOLTIP")
	invert_group.add_child(invert_ctrl)
	add_child(invert_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var offset_ctrl = get_node("offset_group/offset_ctrl")

	# Make sure all of the numeric controls have valid values
	if not offset_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var wp_cen_ctrl = find_node("wp_cen_ctrl", true, false)
	var invert_ctrl = find_node("invert_ctrl", true, false)
	var offset_ctrl = get_node("offset_group/offset_ctrl")

	var complete = ""

	# Use the template
	complete = template.format({
		"offset": offset_ctrl.get_text(),
		"center_option": wp_cen_ctrl.get_item_text(wp_cen_ctrl.get_selected_id()),
		"invert": invert_ctrl.pressed
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
	var wp_cen_ctrl = find_node("wp_cen_ctrl", true, false)
	var invert_ctrl = find_node("invert_ctrl", true, false)
	var offset_ctrl = get_node("offset_group/offset_ctrl")

	prev_template = text_line

	var rgx = RegEx.new()

	# The workplane center option
	rgx.compile(wp_cen_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wp_cen_ctrl, res.get_string())

	# The offset option
	rgx.compile(offset_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the offset text
		offset_ctrl.set_text(res.get_string())

	# The invert option
	rgx.compile(invert_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var inv = res.get_string()
		invert_ctrl.pressed = true if inv == "True" else false

	# The component (tag) name
#	rgx.compile(tag_edit_rgx)
#	res = rgx.search(text_line)
#	if res:
#		# Fill in the tag/name text
#		wp_name_ctrl.set_text(res.get_string())
