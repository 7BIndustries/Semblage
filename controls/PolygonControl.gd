extends VBoxContainer

class_name PolygonControl

var prev_template = null

var template = ".polygon(nSides={nSides},diameter={diameter},forConstruction={for_construction})"

const nsides_edit_rgx = "(?<=nSides\\=)(.*?)(?=,diameter)"
const dia_edit_rgx = "(?<=diameter\\=)(.*?)(?=\\,forConstruction)"
const const_edit_rgx = "(?<=forConstruction\\=)(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the number of sides controls
	var nsides_group = HBoxContainer.new()
	var nsides_lbl = Label.new()
	nsides_lbl.set_text("Number of Sides: ")
	nsides_group.add_child(nsides_lbl)
	var nsides_ctrl = NumberEdit.new()
	nsides_ctrl.name = "nsides_ctrl"
	nsides_ctrl.size_flags_horizontal = 3
	nsides_ctrl.NumberFormat = "int"
	nsides_ctrl.set_text("5")
	nsides_ctrl.MinValue = 3
	nsides_ctrl.MaxValue = 999
	nsides_ctrl.hint_tooltip = tr("POLYGON_NSIDES_CTRL_HINT_TOOLTIP")
	nsides_group.add_child(nsides_ctrl)
	add_child(nsides_group)

	# Add the diameter controls
	var dia_group = HBoxContainer.new()
	var dia_lbl = Label.new()
	dia_lbl.set_text("Diameter: ")
	dia_group.add_child(dia_lbl)
	var dia_ctrl = NumberEdit.new()
	dia_ctrl.name = "dia_ctrl"
	dia_ctrl.size_flags_horizontal = 3
	dia_ctrl.set_text("10.0")
	dia_ctrl.hint_tooltip = tr("POLYGON_DIA_CTRL_HINT_TOOLTIP")
	dia_group.add_child(dia_ctrl)
	add_child(dia_group)

	# Add the for construction control
	var const_group = HBoxContainer.new()
	var const_lbl = Label.new()
	const_lbl.set_text("For Construction: ")
	const_group.add_child(const_lbl)
	var for_construction_ctrl = CheckBox.new()
	for_construction_ctrl.name = "for_construction_ctrl"
	for_construction_ctrl.pressed = false
	for_construction_ctrl.hint_tooltip = tr("FOR_CONSTRUCTION_CTRL_HINT_TOOLTIP")
	const_group.add_child(for_construction_ctrl)

	add_child(const_group)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var nsides_ctrl = find_node("nsides_ctrl", true, false)
	var dia_ctrl = find_node("dia_ctrl", true, false)

	# Make sure all of the numeric controls have valid values
	if not nsides_ctrl.is_valid:
		return false
	if not dia_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var nsides_ctrl = find_node("nsides_ctrl", true, false)
	var dia_ctrl = find_node("dia_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	var complete = ""

	complete += template.format({
		"nSides": nsides_ctrl.get_text(),
		"diameter": dia_ctrl.get_text(),
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
	var nsides_ctrl = find_node("nsides_ctrl", true, false)
	var dia_ctrl = find_node("dia_ctrl", true, false)
	var for_construction_ctrl = find_node("for_construction_ctrl", true, false)

	prev_template = text_line

	var rgx = RegEx.new()

	# Number of sides
	rgx.compile(nsides_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the end point controls
		var nsides = res.get_string()
		nsides_ctrl.set_text(nsides)

	# Diameter
	rgx.compile(dia_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sagitta control
		var dia = res.get_string()
		dia_ctrl.set_text(dia)

	# For construction
	rgx.compile(const_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var constr = res.get_string()
		for_construction_ctrl.pressed = true if constr == "True" else false
