extends VBoxContainer

class_name TextControl

var txt_ctrl = null
var font_size_ctrl = null
var distance_ctrl = null
var cut_ctrl = null
var font_ctrl = null
var font_path_ctrl = null
var kind_ctrl = null
var halign_ctrl = null
var valign_ctrl = null
var combine_ctrl = null
var clean_ctrl = null

var prev_template = null

var template = ".text({txt},fontsize={font_size},distance={distance},cut={cut},font={font},fontPath={font_path},kind={kind},halign={halign},valign={valign},combine={combine},clean={clean})"

const txt_edit_rgx = "(?<=.text\\()(.*?)(?=,fontsize)"
const font_size_edit_rgx = "(?<=fontsize\\=\\()(.*?)(?=,distance)"
const distance_edit_rgx = "(?<=distance\\=\\()(.*?)(?=,cut)"
const cut_edit_rgx = "(?<=cut\\=\\()(.*?)(?=,font)"
const font_edit_rgx = "(?<=font\\=\\()(.*?)(?=,font_path)"
const font_path_edit_rgx = "(?<=fontPath\\=\\()(.*?)(?=,kind)"
const kind_edit_rgx = "(?<=kind\\=\\()(.*?)(?=,halign)"
const halign_edit_rgx = "(?<=halign\\=\\()(.*?)(?=,valign)"
const valign_edit_rgx = "(?<=valign\\=\\()(.*?)(?=,combine)"
const combine_edit_rgx = "(?<=combine\\=\\()(.*?)(?=,clean)"
const clean_edit_rgx = "(?<=clean\\=\\()(.*?)(?=\\))"


# Called when the node enters the scene tree for the first time.
func _ready():
	# The text to generate
	var txt_group = HBoxContainer.new()
	var txt_ctrl_lbl = Label.new()
	txt_ctrl_lbl.set_text("Text: ")
	txt_group.add_child(txt_ctrl_lbl)
	txt_ctrl = LineEdit.new()
	txt_ctrl.expand_to_text_length = true
	txt_ctrl.set_text("Change This")
	txt_ctrl.hint_tooltip = ToolTips.get_tts().text_txt_ctrl_hint_tooltip
	txt_group.add_child(txt_ctrl)
	add_child(txt_group)

	# Distance
	var distance_group = HBoxContainer.new()
	var distance_ctrl_lbl = Label.new()
	distance_ctrl_lbl.set_text("Text Depth: ")
	distance_group.add_child(distance_ctrl_lbl)
	distance_ctrl = NumberEdit.new()
	distance_ctrl.expand_to_text_length = true
	distance_ctrl.set_text("5")
	distance_ctrl.hint_tooltip = ToolTips.get_tts().text_distance_ctrl_hint_tooltip
	distance_group.add_child(distance_ctrl)
	add_child(distance_group)

	# Cut checkbox
	var cut_group = HBoxContainer.new()
	var cut_lbl = Label.new()
	cut_lbl.set_text("Cut: ")
	cut_group.add_child(cut_lbl)
	cut_ctrl = CheckBox.new()
	cut_ctrl.pressed = false
	cut_ctrl.hint_tooltip = ToolTips.get_tts().text_cut_ctrl_hint_tooltip
	cut_group.add_child(cut_ctrl)
	add_child(cut_group)

	# Add the combine checkbox
	var combine_group = HBoxContainer.new()
	var combine_lbl = Label.new()
	combine_lbl.set_text("Combine: ")
	combine_group.add_child(combine_lbl)
	combine_ctrl = CheckBox.new()
	combine_ctrl.pressed = true
	combine_ctrl.hint_tooltip = tr("COMBINE_CTRL_HINT_TOOLTIP")
	combine_group.add_child(combine_ctrl)
	add_child(combine_group)

	# Add the clean checkbox
	var clean_group = HBoxContainer.new()
	var clean_lbl = Label.new()
	clean_lbl.set_text("Clean: ")
	clean_group.add_child(clean_lbl)
	clean_ctrl = CheckBox.new()
	clean_ctrl.pressed = true
	clean_ctrl.hint_tooltip = tr("CLEAN_CTRL_HINT_TOOLTIP")
	clean_group.add_child(clean_ctrl)
	add_child(clean_group)

	# Add a horizontal rule to break things up
	add_child(HSeparator.new())

	var font_settings_lbl = Label.new()
	font_settings_lbl.set_text("Font Settings")
	add_child(font_settings_lbl)

	# Font size
	var font_size_group = HBoxContainer.new()
	var font_size_ctrl_lbl = Label.new()
	font_size_ctrl_lbl.set_text("Size: ")
	font_size_group.add_child(font_size_ctrl_lbl)
	font_size_ctrl = NumberEdit.new()
	font_size_ctrl.expand_to_text_length = true
	font_size_ctrl.NumberFormat = "int"
	font_size_ctrl.set_text("12")
	font_size_ctrl.hint_tooltip = ToolTips.get_tts().text_font_size_ctrl_hint_tooltip
	font_size_group.add_child(font_size_ctrl)
	add_child(font_size_group)

	# Font type
	var font_group = HBoxContainer.new()
	var font_ctrl_lbl = Label.new()
	font_ctrl_lbl.set_text("Type: ")
	font_group.add_child(font_ctrl_lbl)
	font_ctrl = LineEdit.new()
	font_ctrl.expand_to_text_length = true
	font_ctrl.set_text("Arial")
	font_ctrl.hint_tooltip = ToolTips.get_tts().text_font_ctrl_hint_tooltip
	font_group.add_child(font_ctrl)
	add_child(font_group)

	# Font path
	var font_path_group = HBoxContainer.new()
	var font_path_ctrl_lbl = Label.new()
	font_path_ctrl_lbl.set_text("Custom Path: ")
	font_path_group.add_child(font_path_ctrl_lbl)
	font_path_ctrl = LineEdit.new()
	font_path_ctrl.expand_to_text_length = true
	font_path_ctrl.set_text("")
	font_path_ctrl.hint_tooltip = ToolTips.get_tts().text_font_path_ctrl_hint_tooltip
	font_path_group.add_child(font_path_ctrl)
	add_child(font_path_group)

	# Kind
	var kind_group = HBoxContainer.new()
	var kind_ctrl_lbl = Label.new()
	kind_ctrl_lbl.set_text("Style: ")
	kind_group.add_child(kind_ctrl_lbl)
	kind_ctrl = OptionButton.new()
	Common.load_option_button(kind_ctrl, ["regular", "bold", "italic"])
	kind_ctrl.hint_tooltip = ToolTips.get_tts().text_font_kind_ctrl_hint_tooltip
	kind_group.add_child(kind_ctrl)
	add_child(kind_group)

	# Horizontal alignment
	var halign_group = HBoxContainer.new()
	var halign_ctrl_lbl = Label.new()
	halign_ctrl_lbl.set_text("Horizontal Alignment: ")
	halign_group.add_child(halign_ctrl_lbl)
	halign_ctrl = OptionButton.new()
	Common.load_option_button(halign_ctrl, ["center", "left", "right"])
	halign_ctrl.hint_tooltip = ToolTips.get_tts().text_halign_ctrl_hint_tooltip
	halign_group.add_child(halign_ctrl)
	add_child(halign_group)

	# Vertical alignment
	var valign_group = HBoxContainer.new()
	var valign_ctrl_lbl = Label.new()
	valign_ctrl_lbl.set_text("Vertical Alignment: ")
	valign_group.add_child(valign_ctrl_lbl)
	valign_ctrl = OptionButton.new()
	Common.load_option_button(valign_ctrl, ["center", "top", "bottom"])
	valign_ctrl.hint_tooltip = ToolTips.get_tts().text_valign_ctrl_hint_tooltip
	valign_group.add_child(valign_ctrl)
	add_child(valign_group)


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	# Make sure all of the numeric controls have valid values
	if not distance_ctrl.is_valid:
		return false
	if not font_size_ctrl.is_valid:
		return false

	return true


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var complete = ""

	# Make sure to handle the possible Python None value in the font path
	var font_path = font_path_ctrl.get_text()
	if font_path == "":
		font_path = "None"
	else:
		font_path = "\"\"" + font_path + "\"\""

	# Fill out the main template
	complete += template.format({
		"txt": "\"\"" + txt_ctrl.get_text() + "\"\"",
		"font_size": font_size_ctrl.get_text(),
		"distance": distance_ctrl.get_text(),
		"cut": cut_ctrl.pressed,
		"combine": combine_ctrl.pressed,
		"clean": clean_ctrl.pressed,
		"font": "\"\"" + font_ctrl.get_text() + "\"\"",
		"font_path": font_path,
		"kind": "\"\"" + kind_ctrl.get_item_text(kind_ctrl.get_selected_id()) + "\"\"",
		"halign": "\"\"" + halign_ctrl.get_item_text(halign_ctrl.get_selected_id()) + "\"\"",
		"valign": "\"\"" + valign_ctrl.get_item_text(valign_ctrl.get_selected_id()) + "\"\""
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

	# The text
	rgx.compile(txt_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var txt = res.get_string().replace("\"", "")
		txt_ctrl.set_text(txt)

	# Font size
	rgx.compile(font_size_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var font_size = res.get_string()
		font_size_ctrl.set_text(font_size)

	# Distance
	rgx.compile(distance_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var dist = res.get_string()
		distance_ctrl.set_text(dist)

	# Cut boolean
	rgx.compile(cut_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var cut = res.get_string()
		cut_ctrl.pressed = true if cut == "True" else false

	# Combine boolean
	rgx.compile(combine_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var comb = res.get_string()
		combine_ctrl.pressed = true if comb == "True" else false

	# Clean boolean
	rgx.compile(clean_edit_rgx)
	res = rgx.search(text_line)
	if res:
		var clean = res.get_string()
		clean_ctrl.pressed = true if clean == "True" else false

	# Font
	rgx.compile(font_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var font = res.get_string()
		font_ctrl.set_text(font)

	# Font path
	rgx.compile(font_path_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var font_path = res.get_string()

		# Handle the Python None type
		if font_path == "None":
			font_path = ""

		font_path_ctrl.set_text(font_path)

	# Font kind
	rgx.compile(kind_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var kind = res.get_string()
		Common.set_option_btn_by_text(kind_ctrl, kind)

	# Horizontal alignment
	rgx.compile(halign_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var halign = res.get_string()
		Common.set_option_btn_by_text(halign_ctrl, halign)

	# Vertical alignment
	rgx.compile(valign_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Fill in the sphere radius control
		var valign = res.get_string()
		Common.set_option_btn_by_text(valign_ctrl, valign)
