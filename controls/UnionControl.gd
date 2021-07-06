extends VBoxContainer

signal error

class_name UnionControl

var prev_template = null

var template = "{first_obj}.union({second_obj},clean={clean},glue={combine},tol={tolerance}).tag(\"{comp_name}\")"

const first_obj = "(?<=^)(.*?)(?=\\.union)"
const second_obj_edit_rgx = "(?<=.union\\()(.*?)(?=,clean)"
const clean_edit_rgx = "(?<=clean\\=\\()(.*?)(?=\\),glue)"
const glue_edit_rgx = "(?<=glue\\=\\()(.*?)(?=\\),clean)"
const tolerance_edit_rgx = "(?<=tol\\=\\()(.*?)(?=\\))"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

var valid = false

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
	second_object_opt.connect("item_selected", self, "_on_second_object_opt_item_selected")
	second_obj_group.add_child(second_object_opt)

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
		error_btn.hint_tooltip = "There must be two components for a boolean operation to be used."
		valid = false
	# The first and second objects cannot be the same
	elif first_object_opt.get_item_text(first_object_opt.selected) == second_object_opt.get_item_text(second_object_opt.selected):
		error_btn_group.show()
		error_btn.hint_tooltip = "Two different components must be selected for a union."
		valid = false


"""
Tells the Operations dialog if this form contains valid data.
"""
func is_valid():
	return valid


"""
Called when the user selects a first component to be unioned.
"""
func _on_first_object_opt_item_selected(_index):
	_validate_form()


"""
Called when the user selects a first component to be unioned.
"""
func _on_second_object_opt_item_selected(_index):
	_validate_form()
