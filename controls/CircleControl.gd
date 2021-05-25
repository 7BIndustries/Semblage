extends VBoxContainer

class_name CircleControl

var prev_template = null

var template = ".circle({radius},forConstruction={for_construction})"

const rad_edit_rgx = "(?<=.circle\\()(.*?)(?=,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"

var radius_ctrl = null
var for_construction_ctrl = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the rect dimension controls
	var rad_group = HBoxContainer.new()

	# Width (X length)
	var rad_lbl = Label.new()
	rad_lbl.set_text("Radius: ")
	rad_group.add_child(rad_lbl)
	radius_ctrl = NumberEdit.new()
	radius_ctrl.set_text("1.0")
	radius_ctrl.hint_tooltip = tr("RADIUS_CTRL_HINT_TOOLTIP")
	rad_group.add_child(radius_ctrl)
	add_child(rad_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)
	add_child(const_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not radius_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	complete += template.format({
		"radius": radius_ctrl.get_text(),
		"for_construction": for_construction_ctrl.pressed
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

	# Rect dimensions
	rgx.compile(rad_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the box dimension controls
		var rad = res.get_string()
		radius_ctrl.set_text(rad)

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
