extends VBoxContainer

class_name ImportComponentControl

var step_template = 'cq.importers.importStep("{import_path}").tag("{comp_name}")'
var dxf_template = 'cq.importers.importDXF("{import_path}").tag("{comp_name}")'

var prev_template = null

const step_path_edit_rgx = "(?<=.importStep\\(\")(.*?)(?=\"\\)\\.tag)"
const dxf_path_edit_rgx = "(?<=.importDXF\\(\")(.*?)(?=\"\\)\\.tag)"
const tag_edit_rgx = "(?<=.tag\\(\")(.*?)(?=\"\\))"

var valid = false


"""
Called when the node enters the scene tree.
"""
func _ready():
	# Allow the user to give the Workplane/component a name
	var name_group = HBoxContainer.new()
	name_group.name = "name_group"
	var wp_name_lbl = Label.new()
	wp_name_lbl.set_text("Name: ")
	name_group.add_child(wp_name_lbl)
	var wp_name_ctrl = WPNameEdit.new()
	wp_name_ctrl.name = "wp_name_ctrl"
	wp_name_ctrl.size_flags_horizontal = 3
	wp_name_ctrl.set_text("change_me")
	wp_name_ctrl.hint_tooltip = tr("WP_NAME_CTRL_HINT_TOOLTIP")
	wp_name_ctrl.connect("text_changed", self, "_on_wp_name_ctrl_text_changed")
	name_group.add_child(wp_name_ctrl)
	add_child(name_group)

	# Allows the user to provide the path to the file to import
	var path_group = HBoxContainer.new()
	path_group.name = "path_group"
	var path_lbl = Label.new()
	path_lbl.set_text("Path: ")
	path_group.add_child(path_lbl)
	var path_ctrl = LineEdit.new()
	path_ctrl.name = "path_ctrl"
	path_ctrl.size_flags_horizontal = 3
	path_group.add_child(path_ctrl)
	var path_btn = Button.new()
	path_btn.name = "path_btn"
	path_btn.set_text("...")
	path_btn.connect("button_down", self, "_on_SelectPathButton_button_down")
	path_group.add_child(path_btn)
	add_child(path_group)

	# Create the button that lets the user know that there is an error on the form
	var error_btn_group = HBoxContainer.new()
	error_btn_group.name = "error_btn_group"
	var error_btn = Button.new()
	error_btn.name = "error_btn"
	error_btn.set_text("!")
	error_btn_group.add_child(error_btn)
	error_btn_group.hide()
	add_child(error_btn_group)

	_validate_form()


"""
Called when the user clicks the folder button to specify the file path.
"""
func _on_SelectPathButton_button_down():
	var fd = get_tree().get_root().get_node("Control").get_node("ImportFileDialog")
	fd.clear_filters()
	fd.add_filter('*.step')
	fd.add_filter('*.stp')
	fd.add_filter('*.dxf')
	fd.connect('file_selected', self, '_export_select_finished')
	fd.popup_centered()


"""
Called when the user clicks the OK button after selecting a path.
"""
func _export_select_finished(path):
	var path_txt = get_node("path_group/path_ctrl")
	path_txt.set_text(path)

	_validate_form()


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return valid


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var path_ctrl = get_node("path_group/path_ctrl")
	var path_str = path_ctrl.get_text()

	var complete = ""

	# Check to see which file type we have
	if path_str.ends_with(".stp") or path_str.ends_with(".step"):
		complete = step_template.format({
			"comp_name": wp_name_ctrl.get_text(),
			"import_path": path_str
		})
	elif path_str.ends_with(".dxf"):
		complete = dxf_template.format({
			"comp_name": wp_name_ctrl.get_text(),
			"import_path": path_str
		})
	else:
		pass

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

	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var path_ctrl = get_node("path_group/path_ctrl")

	var rgx = RegEx.new()

	# Tag/component name
	rgx.compile(tag_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		wp_name_ctrl.set_text(res.get_string())

	# STEP path text
	rgx.compile(step_path_edit_rgx)
	res = rgx.search(text_line)
	if res:
		path_ctrl.set_text(res.get_string())

	# DXF path text
	rgx.compile(dxf_path_edit_rgx)
	res = rgx.search(text_line)
	if res:
		path_ctrl.set_text(res.get_string())


"""
Called when the user changes the component name text.
"""
func _on_wp_name_ctrl_text_changed():
	_validate_form()


"""
Validates the form as the user makes changes.
"""
func _validate_form():
	var wp_name_ctrl = get_node("name_group/wp_name_ctrl")
	var path_ctrl = get_node("path_group/path_ctrl")
	var error_btn_group = get_node("error_btn_group")
	var error_btn = get_node("error_btn_group/error_btn")

	# Start with the error button hidden
	error_btn_group.hide()

	var path_str = path_ctrl.get_text()

	if path_ctrl.get_text() == "":
		error_btn_group.show()
		error_btn.hint_tooltip = "Error Button" #tr("BINARY_OP_ERROR_TWO_COMPONENTS")
		valid = false
	elif not path_str.ends_with(".stp") and not path_str.ends_with(".step") and not path_str.ends_with(".dxf"):
		error_btn_group.show()
		error_btn.hint_tooltip = "Error Button" #tr("BINARY_OP_ERROR_TWO_COMPONENTS")
		valid = false
	elif not wp_name_ctrl.is_valid:
		error_btn_group.show()
		error_btn.hint_tooltip = "Error Button" #tr("BINARY_OP_ERROR_TWO_COMPONENTS")
		valid = false
	else:
		valid = true
