extends VBoxContainer

signal error

class_name LoftControl

var is_binary = false

var prev_template = null

var template = "{wire_component}.loft(filled={filled},ruled={ruled},combine={combine}).tag(\"{comp_name}\")"

const wire_component_edit_rgx = "(?<=^)(.*?)(?=\\.loft)"
const filled_edit_rgx = "(?<=filled\\=)(.*?)(?=\\,ruled)"
const ruled_edit_rgx = "(?<=.ruled\\()(.*?)(?=,combine)"
const combine_edit_rgx = "(?<=combine\\=)(.*?)(?=\\,)"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

var valid = false

"""
Called when the node enters the scene tree.
"""
func _ready():
	# Control to set which component to pull wires from for the loft
	var wire_wp_group = VBoxContainer.new()
	wire_wp_group.name = "wire_wp_group"
	# Wire workplane label
	var wire_wp_lbl = Label.new()
	wire_wp_lbl.set_text("Component to Pull Wires From")
	wire_wp_group.add_child(wire_wp_lbl)
	# Wire workplane option control
	var wire_wp_opt = OptionButton.new()
	wire_wp_opt.name = "wire_wp_opt"
	wire_wp_opt.hint_tooltip = tr("LOFT_WIRE_WP_OPT_HINT_TOOLTIP")
	wire_wp_opt.connect("item_selected", self, "_on_wire_wp_opt_item_selected")
	wire_wp_group.add_child(wire_wp_opt)

	# Control to set the tag name of the resulting object
	var tag_name_group = VBoxContainer.new()
	tag_name_group.name = "tag_name_group"
	# Tag name label
	var tag_name_lbl = Label.new()
	tag_name_lbl.set_text("New Component Name")
	tag_name_group.add_child(tag_name_lbl)
	# Tag name input text
	var tag_name_txt = LineEdit.new()
	tag_name_txt.name = "tag_name_txt"
	tag_name_txt.hint_tooltip = tr("WP_NAME_CTRL_HINT_TOOLTIP")
	tag_name_txt.set_text("loft1")
	tag_name_txt.connect("text_changed", self, "_on_tag_text_changed")
	tag_name_group.add_child(tag_name_txt)

	# Add the filled checkbox
	var filled_group = HBoxContainer.new()
	filled_group.name = "filled_group"
	var filled_lbl = Label.new()
	filled_lbl.set_text("Filled: ")
	filled_group.add_child(filled_lbl)
	var filled_ctrl = CheckBox.new()
	filled_ctrl.pressed = true
	filled_ctrl.name = "filled_ctrl"
	filled_ctrl.hint_tooltip = tr("FILLED_CTRL_HINT_TOOLTIP")
	filled_group.add_child(filled_ctrl)

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
	var combine_ctrl = CheckBox.new()
	combine_ctrl.pressed = true
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

	add_child(wire_wp_group)
	add_child(tag_name_group)
	add_child(filled_group)
	add_child(ruled_group)
	add_child(combine_group)
	add_child(error_btn_group)

		# Pull any component names that already exist in the context
	var orig_ctx = find_parent("ActionPopupPanel").original_context
	var objs = ContextHandler.get_objects_from_context(orig_ctx)

	# Collect all of the object options into an array of strings
	# We want users to still be able to look through the operations, so do not error until they click ok
	var comp_names = []
	if objs != null:
		for obj in objs:
			comp_names.append(obj.get_string())

		# Load up both component option buttons with the names of the found components
		Common.load_option_button(wire_wp_opt, comp_names)

	_validate_form()


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var wire_wp_opt = get_node("wire_wp_group/wire_wp_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var error_btn = get_node("error_btn_group/error_btn")
	var error_btn_group = get_node("error_btn_group")

	# Check to make sure that the workplane/tag name is valid
	var valid_tag_name = Common._validate_tag_name(tag_name_txt.get_text())

	# Validate the workplane/tag name characters
	if not valid_tag_name:
		error_btn_group.show()
		error_btn.hint_tooltip = tr("TAG_NAME_CHARACTER_ERROR")
		valid = false
	elif wire_wp_opt.get_item_text(wire_wp_opt.selected) == "":
		error_btn_group.show()
		error_btn.hint_tooltip = tr("NO_COMPONENT_SELECTED_ERROR")
		valid = false
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
	var wire_wp_opt = get_node("wire_wp_group/wire_wp_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var filled_ctrl = get_node("filled_group/filled_ctrl")
	var ruled_ctrl = get_node("ruled_group/ruled_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")

	var complete = template.format({
		"wire_component": wire_wp_opt.get_item_text(wire_wp_opt.get_selected_id()),
		"comp_name": tag_name_txt.get_text(),
		"filled": filled_ctrl.pressed,
		"ruled": ruled_ctrl.pressed,
		"combine": combine_ctrl.pressed
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
	var wire_wp_opt = get_node("wire_wp_group/wire_wp_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var filled_ctrl = get_node("filled_group/filled_ctrl")
	var ruled_ctrl = get_node("ruled_group/ruled_ctrl")
	var combine_ctrl = get_node("combine_group/combine_ctrl")

	prev_template = text_line

	var rgx = RegEx.new()

	# Wire component name
	rgx.compile(wire_component_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(wire_wp_opt, res.get_string())

	# Tag/component name
	rgx.compile(tag_edit_rgx)
	res = rgx.search(text_line)
	if res:
		tag_name_txt.set_text(res.get_string())

	# Filled boolean
	rgx.compile(filled_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var filled = res.get_string()
		filled_ctrl.pressed = true if filled == "True" else false

	# Ruled boolean
	rgx.compile(ruled_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var ruled = res.get_string()
		ruled_ctrl.pressed = true if ruled == "True" else false

	# Combine boolean
	rgx.compile(combine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var comb = res.get_string()
		combine_ctrl.pressed = true if comb == "True" else false


"""
Called when the user changes the tag (new component name) text.
"""
func _on_tag_text_changed(_new_text):
	_validate_form()


"""
Called when the user selects a workplane from the dropdown.
"""
func _on_wire_wp_opt_item_selected():
	_validate_form()
