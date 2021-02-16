extends VBoxContainer

class_name SectionControl

var height_ctrl = null

var prev_template = null

var template = ".section({height})"

var height_edit_rgx = "(?<=.section\\()(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Height
	var height_group = HBoxContainer.new()
	var height_lbl = Label.new()
	height_lbl.set_text("Height: ")
	height_group.add_child(height_lbl)
	height_ctrl = LineEdit.new()
	height_ctrl.set_text("2.5")
	height_group.add_child(height_ctrl)
	add_child(height_group)


"""
Fills out the template and returns it.
"""
func get_completed_template():	
	var complete = template.format({
		"height": height_ctrl.get_text()
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

	# The wedge dimensions
	rgx.compile(height_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the wedge dimension controls
		var height = res.get_string()
		height_ctrl.set_text(height)
