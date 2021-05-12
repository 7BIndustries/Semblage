extends VBoxContainer

class_name ChainedWorkplaneControl

var prev_template = null

var wp_name_ctrl = null
var wp_cen_ctrl = null
var invert_ctrl = null

var template = ".workplane(invert={invert},centerOption=\"{center_option}\")" #.tag(\"{comp_name}\")"

const center_option_list = ["CenterOfBoundBox", "CenterOfMass", "ProjectedOrigin"]

const wp_cen_edit_rgx = "(?<=centerOption\\=\")(.*?)(?=\"\\))"
const invert_edit_rgx = "(?<=invert\\=)(.*?)(?=,centerOption)"
#var tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Allow the user to give the Workplane/component a name
#	var name_group = HBoxContainer.new()
#	var wp_name_lbl = Label.new()
#	wp_name_lbl.set_text("Name: ")
#	name_group.add_child(wp_name_lbl)
#	wp_name_ctrl = LineEdit.new()
#	wp_name_ctrl.expand_to_text_length = true
#	wp_name_ctrl.set_text("Change")
#	name_group.add_child(wp_name_ctrl)
#	add_child(name_group)

	# Add a control for the center option
	var wp_cen_group = HBoxContainer.new()
	var wp_cen_lbl = Label.new()
	wp_cen_lbl.set_text("Center Option: ")
	wp_cen_group.add_child(wp_cen_lbl)
	wp_cen_ctrl = OptionButton.new()
	Common.load_option_button(wp_cen_ctrl, center_option_list)
	wp_cen_ctrl.hint_tooltip = tr("WP_CEN_CTRL_HINT_TOOLTIP")
	wp_cen_group.add_child(wp_cen_ctrl)
	add_child(wp_cen_group)

	# Allow the user to set whether the workplane normal is inverted
	var invert_group = HBoxContainer.new()
	var invert_lbl = Label.new()
	invert_lbl.set_text("Invert: ")
	invert_group.add_child(invert_lbl)
	invert_ctrl = CheckBox.new()
	invert_ctrl.pressed = false
	invert_ctrl.hint_tooltip = tr("INVERT_CTRL_HINT_TOOLTIP")
	invert_group.add_child(invert_ctrl)
	add_child(invert_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Use the simple template
	complete = template.format({
#		"comp_name": wp_name_ctrl.get_text(),
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
	prev_template = text_line

	var rgx = RegEx.new()

	# The workplane center option
	rgx.compile(wp_cen_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wp_cen_ctrl, res.get_string())

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
