extends VBoxContainer

class_name Offset2DControl

var prev_template = null

var template = ".offset2D({thickness},kind=\"{kind}\")"

const thickness_edit_rgx = "(?<=.offset2D\\()(.*?)(?=,kind)"
const kind_edit_rgx = "(?<=kind\\=\")(.*?)(?=\"\\))"

const kind_list = ["arc", "intersection", "tangent"]


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the thickness controls
	var thickness_group = HBoxContainer.new()
	var x_length_lbl = Label.new()
	x_length_lbl.set_text("Thickness: ")
	thickness_group.add_child(x_length_lbl)
	var thickness_ctrl = NumberEdit.new()
	thickness_ctrl.name = "thickness_ctrl"
	thickness_ctrl.size_flags_horizontal = 3
	thickness_ctrl.set_text("1.0")
	thickness_ctrl.CanBeNegative = true
	thickness_ctrl.hint_tooltip = tr("OFFSET2D_THICKNESS_CTRL_HINT_TOOLTIP")
	thickness_group.add_child(thickness_ctrl)
	add_child(thickness_group)

	# Allow the user to select the named workplane
	var kind_group = HBoxContainer.new()
	var kind_lbl = Label.new()
	kind_lbl.set_text("Kind: ")
	kind_group.add_child(kind_lbl)
	var kind_ctrl = OptionButton.new()
	kind_ctrl.name = "kind_ctrl"
	Common.load_option_button(kind_ctrl, kind_list)
	kind_ctrl.hint_tooltip = tr("CORNER_KIND_CTRL_HINT_TOOLTIP")
	kind_group.add_child(kind_ctrl)
	add_child(kind_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var thickness_ctrl = find_node("thickness_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not thickness_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var thickness_ctrl = find_node("thickness_ctrl", true, false)
	var kind_ctrl = find_node("kind_ctrl", true, false)

	# Use the simple template
	var complete = template.format({
		"thickness": thickness_ctrl.get_text(),
		"kind": kind_ctrl.get_item_text(kind_ctrl.get_selected_id())
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
	var thickness_ctrl = find_node("thickness_ctrl", true, false)
	var kind_ctrl = find_node("kind_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# The offset thickness
	rgx.compile(thickness_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Thickness
		thickness_ctrl.set_text(res.get_string())

	# The offset kind
	rgx.compile(kind_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(kind_ctrl, res.get_string())
