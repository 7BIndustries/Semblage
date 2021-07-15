extends VBoxContainer

signal error

class_name UnionControl

var is_binary = true

var prev_template = null

var template = "{first_obj}.union({second_obj},clean={clean},glue={glue},tol={tolerance}).tag(\"{comp_name}\")"

const first_obj_edit_rgx = "(?<=^)(.*?)(?=\\.union)"
const second_obj_edit_rgx = "(?<=.union\\()(.*?)(?=,clean)"
const clean_edit_rgx = "(?<=clean\\=)(.*?)(?=,glue)"
const glue_edit_rgx = "(?<=glue\\=)(.*?)(?=,tol)"
const tolerance_edit_rgx = "(?<=tol\\=)(.*?)(?=\\))"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

var valid = false

"""
Called when the node enters the scene tree.
"""
func _ready():
	# Control to set the first object of the union
	var first_obj_group = VBoxContainer.new()
	first_obj_group.name = "first_obj_group"
	# First object label
	var first_obj_lbl = Label.new()
	first_obj_lbl.set_text("First Component")
	first_obj_group.add_child(first_obj_lbl)
	# First object option control
	var first_object_opt = OptionButton.new()
	first_object_opt.name = "first_object_opt"
	first_object_opt.hint_tooltip = tr("FIRST_OBJECT_OPT_HINT_TOOLTIP")
	first_object_opt.connect("item_selected", self, "_on_first_object_opt_item_selected")
	first_obj_group.add_child(first_object_opt)

	# Control to set the second object of the union
	var second_obj_group = VBoxContainer.new()
	second_obj_group.name = "second_obj_group"
	# Second object label
	var second_obj_lbl = Label.new()
	second_obj_lbl.set_text("Second Component")
	second_obj_group.add_child(second_obj_lbl)
	# Second object option control
	var second_object_opt = OptionButton.new()
	second_object_opt.name = "second_object_opt"
	second_object_opt.hint_tooltip = tr("SECOND_OBJECT_OPT_HINT_TOOLTIP")
	second_object_opt.connect("item_selected", self, "_on_second_object_opt_item_selected")
	second_obj_group.add_child(second_object_opt)

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
	tag_name_group.add_child(tag_name_txt)

	# The tolerance for the fuzzy boolean operation
	var tol_group = VBoxContainer.new()
	tol_group.name = "tol_group"
	# Tolerance label
	var tol_lbl = Label.new()
	tol_lbl.set_text("Fuzzy Bool Tolerance (0=off)")
	tol_group.add_child(tol_lbl)
	# Tolerance number input
	var tol_num = NumberEdit.new()
	tol_num.name = "tol_num"
	tol_num.set_text("0")
	tol_num.hint_tooltip = tr("TOL_NUM_HINT_TOOLTIP")
	tol_group.add_child(tol_num)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	clean_group.name = "clean_group"
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	var clean_ctrl = CheckBox.new()
	clean_ctrl.name = "clean_ctrl"
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)

	# Add the glue checkbox
	var glue_group = HBoxContainer.new()
	glue_group.name = "glue_group"
	var glue_lbl = Label.new()
	glue_lbl.set_text("Glue: ")
	glue_group.add_child(glue_lbl)
	var glue_ctrl = CheckBox.new()
	glue_ctrl.name = "glue_ctrl"
	glue_ctrl.pressed = false
	glue_ctrl.hint_tooltip = tr("GLUE_CTRL_HINT_TOOLTIP")
	glue_group.add_child(glue_ctrl)

	# Create the button that lets the user know that there is an error on the form
	var error_btn_group = HBoxContainer.new()
	error_btn_group.name = "error_btn_group"
	var error_btn = Button.new()
	error_btn.name = "error_btn"
	error_btn.set_text("!")
	error_btn_group.add_child(error_btn)
	error_btn_group.hide()

	add_child(first_obj_group)
	add_child(second_obj_group)
	add_child(tag_name_group)
	add_child(tol_group)
	add_child(clean_group)
	add_child(glue_group)
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
		Common.load_option_button(first_object_opt, comp_names)
		Common.load_option_button(second_object_opt, comp_names)

	_validate_form()


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	var first_object_opt = get_node("first_obj_group/first_object_opt")
	var second_object_opt = get_node("second_obj_group/second_object_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var tol_num = get_node("tol_group/tol_num")
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var glue_ctrl = get_node("glue_group/glue_ctrl")

	# Handle the tolerance not being used
	var tolerance = tol_num.get_text()
	if tolerance == "0":
		tolerance = "None"

	complete = template.format({
		"first_obj": first_object_opt.get_item_text(first_object_opt.selected),
		"second_obj": second_object_opt.get_item_text(second_object_opt.selected),
		"tolerance": tolerance,
		"clean": clean_ctrl.pressed,
		"glue": glue_ctrl.pressed,
		"comp_name": tag_name_txt.get_text()
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

	var first_object_opt = get_node("first_obj_group/first_object_opt")
	var second_object_opt = get_node("second_obj_group/second_object_opt")
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var tol_num = get_node("tol_group/tol_num")
	var clean_ctrl = get_node("clean_group/clean_ctrl")
	var glue_ctrl = get_node("glue_group/glue_ctrl")

	var rgx = RegEx.new()

	# First object
	rgx.compile(first_obj_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(first_object_opt, res.get_string())

	# Second object
	rgx.compile(second_obj_edit_rgx)
	res = rgx.search(text_line)
	if res:
		Common.set_option_btn_by_text(second_object_opt, res.get_string())

	# Tag/component name
	rgx.compile(tag_edit_rgx)
	res = rgx.search(text_line)
	if res:
		tag_name_txt.set_text(res.get_string())

	# Tolerance
	rgx.compile(tolerance_edit_rgx)
	res = rgx.search(text_line)
	if res:
		tol_num.set_text(res.get_string())

	# Clean checkbox
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false

	# Glue checkbox
	rgx.compile(glue_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var glue = res.get_string()
		glue_ctrl.pressed = true if glue == "True" else false

	# Validate the form and populate the component name
	_validate_form()
	if valid:
		_build_new_name()


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var first_object_opt = get_node("first_obj_group/first_object_opt")
	var second_object_opt = get_node("second_obj_group/second_object_opt")
	var error_btn_group = get_node("error_btn_group")
	var error_btn = get_node("error_btn_group/error_btn")

	# Start with the error button hidden
	error_btn_group.hide()

	# There must be at least two objects for a boolean operation to work
	if first_object_opt.get_item_count() <= 1 and second_object_opt.get_item_count() <= 1:
		error_btn_group.show()
		error_btn.hint_tooltip = tr("BINARY_OP_ERROR_TWO_COMPONENTS")
		valid = false
	# The first and second objects cannot be the same
	elif first_object_opt.get_item_text(first_object_opt.selected) == second_object_opt.get_item_text(second_object_opt.selected):
		error_btn_group.show()
		error_btn.hint_tooltip = tr("BINARY_OP_ERROR_TWO_DIFF_COMPONENTS")
		valid = false
	else:
		valid = true


func _build_new_name():
	# If the form is valid we should be able to construct the new component name
	if valid:
		var tag_name_txt = get_node("tag_name_group/tag_name_txt")
		var first_object_opt = get_node("first_obj_group/first_object_opt")
		var second_object_opt = get_node("second_obj_group/second_object_opt")

		# Set the new component name to the combination of both components that are being unioned
		var first_text = first_object_opt.get_item_text(first_object_opt.selected)
		var second_text = second_object_opt.get_item_text(second_object_opt.selected)

		tag_name_txt.set_text(first_text + "_" + second_text)

"""
Tells the Operations dialog if this form contains valid data.
"""
func is_valid():
	return valid


"""
Handles pulling the control information together to tell which items
have been combined in the boolean operation.
"""
func get_combine_map():
	var tag_name_txt = get_node("tag_name_group/tag_name_txt")
	var first_object_opt = get_node("first_obj_group/first_object_opt")
	var second_object_opt = get_node("second_obj_group/second_object_opt")

	# Set the new component name to the combination of both components that are being unioned
	var first_text = first_object_opt.get_item_text(first_object_opt.selected)
	var second_text = second_object_opt.get_item_text(second_object_opt.selected)

	# A new dictionary with the new combined object name as the key
	var map = { tag_name_txt.get_text(): [first_text, second_text] }

	return map


"""
Called when the user selects a first component to be unioned.
"""
func _on_first_object_opt_item_selected(_index):
	_validate_form()

	# Populate the new component name with a combination of both component names
	_build_new_name()


"""
Called when the user selects a first component to be unioned.
"""
func _on_second_object_opt_item_selected(_index):
	_validate_form()

	# Populate the new component name with a combination of both component names
	_build_new_name()
