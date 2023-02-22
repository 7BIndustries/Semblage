extends VBoxContainer

# signal error

class_name LoftControl

var prev_template = null

var template = ".loft(ruled={ruled},combine={combine})"

const ruled_edit_rgx = "(?<=ruled\\=)(.*?)(?=,combine)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\))"

var valid = false

"""
Called when the node enters the scene tree.
"""
func _ready():
	# Add the ruled checkbox
	var ruled_group = HBoxContainer.new()
	ruled_group.name = "ruled_group"
	var ruled_lbl = Label.new()
	ruled_lbl.set_text("Ruled: ")
	ruled_group.add_child(ruled_lbl)
	var ruled_ctrl = CheckBox.new()
	ruled_ctrl.pressed = false
	ruled_ctrl.name = "ruled_ctrl"
	ruled_ctrl.hint_tooltip = tr("RULED_CTRL_HINT_TOOLTIP")
	ruled_group.add_child(ruled_ctrl)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	combine_group.name = "combine_group"
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	var combine_ctrl = OptionButton.new()
	Common.load_option_button(combine_ctrl, ["combine", "cut", "nothing"])
	combine_ctrl.name = "combine_ctrl"
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)

	# Create the button that lets the user know that there is an error on the form
	var error_btn_group = HBoxContainer.new()
	error_btn_group.name = "error_btn_group"
	var error_btn = Button.new()
	error_btn.name = "error_btn"
	error_btn.set_text("!")
	error_btn_group.add_child(error_btn)
	error_btn_group.hide()

	add_child(ruled_group)
	add_child(combine_group)
	add_child(error_btn_group)

	# Pull any component names that already exist in the context
	var comp_names = find_parent("ActionPopupPanel")
	comp_names = comp_names.components

	_validate_form()


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var error_btn = get_node("error_btn_group/error_btn")
	var error_btn_group = get_node("error_btn_group")

	# At this time there is nothing to validate in this control
	if false:
		pass
	else:
		error_btn_group.hide()
		valid = true


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return valid


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var ruled_ctrl = get_node("ruled_group/ruled_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")

	# Get the correct value from the combine control
	var combine_val = "cut"
	var combine_str = combine_ctrl.get_item_text(combine_ctrl.get_selected_id())
	if combine_str == "nothing":
		combine_val = "False"
	elif combine_str == "combine":
		combine_val = "True"
	else:
		combine_val = "\"" + combine_str + "\""

	var complete = template.format({
		"ruled": ruled_ctrl.pressed,
		"combine": combine_val
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
	var ruled_ctrl = get_node("ruled_group/ruled_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")

	prev_template = text_line

	var rgx = RegEx.new()

	# Ruled boolean
	rgx.compile(ruled_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		var ruled = res.get_string()
		ruled_ctrl.pressed = true if ruled == "True" else false

	# Combine boolean
	rgx.compile(combine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var comb = res.get_string()

		# True = combine, False = nothing, cut = cut
		if comb == "True":
			Common.set_option_btn_by_text(combine_ctrl, "combine")
		elif comb == "False":
			Common.set_option_btn_by_text(combine_ctrl, "nothing")
		else:
			Common.set_option_btn_by_text(combine_ctrl, "cut")


"""
Called when the user selects a workplane from the dropdown.
"""
func _on_wire_wp_opt_item_selected():
	_validate_form()
