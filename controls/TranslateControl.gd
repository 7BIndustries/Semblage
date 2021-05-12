extends VBoxContainer

class_name TranslateControl

var prev_template = null

var template = ".translate(vec={vec})"

const vec_edit_rgx = "(?<=vec\\=)(.*?)(?=\\))"

var vec_x_ctrl = null
var vec_y_ctrl = null
var vec_z_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the controls for the translation vector
	var vec_lbl_group = VBoxContainer.new()
	var vec_lbl = Label.new()
	vec_lbl.set_text("Translation Vector")
	vec_lbl_group.add_child(vec_lbl)

	var vec_group = HBoxContainer.new()
	# vec X
	var x_lbl = Label.new()
	x_lbl.set_text("X: ")
	vec_group.add_child(x_lbl)
	vec_x_ctrl = NumberEdit.new()
	vec_x_ctrl.CanBeNegative = true
	vec_x_ctrl.set_text("0")
	vec_x_ctrl.hint_tooltip = tr("TRANSLATE_VEC_X_CTRL_HINT_TOOLTIP")
	vec_group.add_child(vec_x_ctrl)
	# vec Y
	var y_lbl = Label.new()
	y_lbl.set_text("Y: ")
	vec_group.add_child(y_lbl)
	vec_y_ctrl = NumberEdit.new()
	vec_y_ctrl.CanBeNegative = true
	vec_y_ctrl.set_text("0")
	vec_y_ctrl.hint_tooltip = tr("TRANSLATE_VEC_Y_CTRL_HINT_TOOLTIP")
	vec_group.add_child(vec_y_ctrl)
	# vec Z
	var z_lbl = Label.new()
	z_lbl.set_text("Z: ")
	vec_group.add_child(z_lbl)
	vec_z_ctrl = NumberEdit.new()
	vec_z_ctrl.CanBeNegative = true
	vec_z_ctrl.set_text("10")
	vec_z_ctrl.hint_tooltip = tr("TRANSLATE_VEC_Z_CTRL_HINT_TOOLTIP")
	vec_group.add_child(vec_z_ctrl)

	vec_lbl_group.add_child(vec_group)
	add_child(vec_lbl_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not vec_x_ctrl.is_valid:
		return false
	if not vec_y_ctrl.is_valid:
		return false
	if not vec_z_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Build the translation vector
	var vec_str = "(" + vec_x_ctrl.get_text() + "," +\
						vec_y_ctrl.get_text() + "," +\
						vec_z_ctrl.get_text() + ")"
	
	complete += template.format({
		"vec": vec_str
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

	# Translation vector
	rgx.compile(vec_edit_rgx)
	var res = rgx.search(text_line)
	var parts = res.get_string().replace("(", "").replace(")", "").split(",")
	if res:
		vec_x_ctrl.set_text(parts[0])
		vec_y_ctrl.set_text(parts[1])
		vec_z_ctrl.set_text(parts[2])
