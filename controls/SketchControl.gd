extends HBoxContainer

class_name SketchControl

var prev_template = null

var template = "{sketch}"

var local_context = "import cadquery as cq\nresult = cq.Workplane('XY')"

var context_adds = []

var two_d_action_ctrl = null
var select_ctrl = null
var hide_show_btn = null
var dynamic_cont = null
var op_list = null
var two_d_preview = null
var actions = null
var two_d_actions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the 2D Actions panel on the left
	var two_d_group = VBoxContainer.new()
	# Allow the user to show/hide the selector controls that allow the rect to 
	# be placed on something other than the current workplane
	hide_show_btn = CheckButton.new()
	hide_show_btn.set_text("Sketch Location Selectors")
	hide_show_btn.connect("button_down", self, "_show_selectors")
	two_d_group.add_child(hide_show_btn)

	# The selector control for where to locate the slot
	select_ctrl = SelectorControl.new()
	select_ctrl.config_visibility(true, false)
	select_ctrl.hide()
	two_d_group.add_child(select_ctrl)

	# Add a horizontal rule to break things up
	two_d_group.add_child(HSeparator.new())

	var sketch_actions_lbl = Label.new()
	sketch_actions_lbl.set_text("Sketch Actions")
	two_d_group.add_child(sketch_actions_lbl)
	two_d_action_ctrl = OptionButton.new()
	two_d_group.add_child(two_d_action_ctrl)

	# Add the container for the dynamic 2D sketch control
	dynamic_cont = MarginContainer.new()
	two_d_group.add_child(dynamic_cont)

	# Grab all of the applicable 2D actions
	for action in actions.keys():
		if actions[action].group == "2D":
			two_d_action_ctrl.add_item(actions[action].name)
			two_d_actions[action] = actions[action]

	# Make sure to populate the correct control when the user switches the Action
	two_d_action_ctrl.connect("item_selected", self, "_switch_action_control")

	# Add the default control to the dynamic container
	var cont1 = two_d_actions[two_d_actions.keys()[0]].control
	cont1.config(false, false)
	dynamic_cont.add_child(cont1)

	# Add button to add the 2D operation to a list
	var add_btn = Button.new()
	add_btn.set_text("Add")
	add_btn.connect("button_down", self, "_add_action")
	two_d_group.add_child(add_btn)

	# Add a horizontal rule to break things up
	two_d_group.add_child(HSeparator.new())

	# List to keep track of the 2D operations and make them editable
	op_list = ItemList.new()
	op_list.auto_height = true
	two_d_group.add_child(op_list)

	add_child(two_d_group)

	# Add the 2D preview area
	var two_d_preview_cont = MarginContainer.new()
	two_d_preview = TextureRect.new()
	two_d_preview.rect_size = Vector2(100, 100)
	two_d_preview_cont.rect_size = Vector2(100, 100)
	two_d_preview_cont.add_child(two_d_preview)
	add_child(two_d_preview_cont)
	load_image("/home/jwright/Downloads/sample_2D_render.svg")


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Collect all of the 2D Action items from the list
	var cur_context = ""
	for i in range(0, op_list.get_item_count()):
		cur_context += op_list.get_item_text(i)

	# If the selector control is visible, prepend its contents
	if hide_show_btn.pressed:
		complete += select_ctrl.get_completed_template()

	complete += template.format({
		"sketch": cur_context
	})

	return complete


"""
Show the selector controls.
"""
func _show_selectors():
	if hide_show_btn.pressed:
		select_ctrl.hide()
	else:
		select_ctrl.show()


"""
When in edit mode, returns the previous template string that needs to
be replaced.
"""
func get_previous_template():
	return prev_template


"""
Allows the user to add 2D actions to the context.
"""
func _add_action():
	# Add the completed context from the selected 2D control
	var add = dynamic_cont.get_children()[0].get_completed_template()

	# Add the completed Action to the list 
	op_list.add_item(add)
	local_context += add


"""
Populates the dynamic control area based on the Action the user selected.
"""
func _switch_action_control(index):
	# Get the newly selected item
	var selected = two_d_action_ctrl.get_item_text(index)

	# Clear the previous control item(s) from the DynamicContainer
	for child in dynamic_cont.get_children():
		dynamic_cont.remove_child(child)

	# Add the action control if it exists
	if actions[selected].control != null:
		var cont1 = actions[selected].control
		cont1.config(false, false)
		dynamic_cont.add_child(cont1)

"""
Allows an image to be loaded into the 2D preview.
"""
func load_image(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.create_from_image(image)
	two_d_preview.set_texture(texture)

"""
Allows the Action dialog to know this control is different.
"""
func get_class():
	return "SketchControl"
