extends WindowDialog

signal error

var orig_size = null # The original size of the dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the selector/section controls until they are needed
	var sect_cont = $MarginContainer/VBoxContainer/SectionContainer
	sect_cont.hide()


"""
Called when the Section button is clicked.
"""
func _on_CheckButton_toggled(_button_pressed):
	# Show the selector and section controls if the check button is on, hide otherwise
	var check_btn = $MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton
	var section_cont = $MarginContainer/VBoxContainer/SectionContainer

	if check_btn.pressed:
		section_cont.show()

		orig_size = rect_size
	
		# Make sure the panel is the correct size to contain all controls
		self.rect_size = Vector2(382, 440)
	else:
		section_cont.hide()

		if orig_size != null:
			rect_size = orig_size

"""
Called when the Cancel button is clicked.
"""
func _on_CancelButton_button_down():
	self.hide()


"""
Called when the user clicks the folder button to specify the file path.
"""
func _on_SelectPathButton_button_down():
	var fd = get_parent().get_node("ExportFileDialog")
	fd.clear_filters()
	fd.add_filter('*.svg')
	fd.connect('file_selected', self, '_export_select_finished')
	fd.popup_centered()


"""
Called after the export file selection has been made.
"""
func _export_select_finished(path):
	var path_txt = $MarginContainer/VBoxContainer/PathContainer/PathText
	path_txt.set_text(path)


"""
Called when the user clicks the ok button.
"""
func _on_OkButton_button_down():
	# Make sure the form is valid
	if not self.is_valid():
		emit_signal("error", "There are errors on the form, please correct them.")
		return

	# Let the user know they have not set an export directory
	var pt = $MarginContainer/VBoxContainer/PathContainer/PathText
	if pt.get_text() == "":
		emit_signal("error", "You must set a file path to export to.")

		return

	# Check to see if the user wants to do slicing
	var check_btn = $MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton
	var start_txt = $MarginContainer/VBoxContainer/SectionContainer/StartHeightText
	var end_txt = $MarginContainer/VBoxContainer/SectionContainer/EndHeightText
	var steps_txt = $MarginContainer/VBoxContainer/SectionContainer/StepsText

	if check_btn.pressed:
		var start_height = start_txt.get_text()
		var end_height = end_txt.get_text()
		var steps = steps_txt.get_text()

		# Convert the values to the correct data types
		start_height = float(start_height)
		end_height = float(end_height)
		steps = int(steps)

		# Do some safety checks
		if end_height < start_height:
			emit_signal("error", "End height cannot be less than starting height.")
			return
		if end_height == 0.0:
			emit_signal("error", "End height cannot be zero.")
			return
		if steps == 0:
			emit_signal("error", "Steps must be greater than zero.")

		# Figure out our layer height
		var layer_height = (end_height - start_height) / float(steps)

		var cur_height = start_height

		# Step through and generate an SVG for each layer
		for i in range(0, steps):
			var file_name = pt.get_text().replace(".svg", "_" + str(i) + ".svg")
			_export_to_file(file_name, _collect_output_opts(), cur_height)

			cur_height += layer_height

		# Do a final export right at the end height
		var file_name = pt.get_text().replace(".svg", "_" + str(steps) + ".svg")
		_export_to_file(file_name, _collect_output_opts(), end_height)
	else:
		# Export the single SVG file
		_export_to_file(pt.get_text(), _collect_output_opts(), null)

	# Hide this popup
	hide()


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var width_txt = $MarginContainer/VBoxContainer/DimsContainer/WidthText
	var height_txt = $MarginContainer/VBoxContainer/DimsContainer/HeightText
	var left_txt = $MarginContainer/VBoxContainer/MarginContainer/LeftText
	var top_txt = $MarginContainer/VBoxContainer/MarginContainer/TopText
	var x_txt = $MarginContainer/VBoxContainer/ProjDirContainer/XText
	var y_txt = $MarginContainer/VBoxContainer/ProjDirContainer/YText
	var s_width_txt = $MarginContainer/VBoxContainer/StrokeWidthContainer/WidthText
	var s_r_txt = $MarginContainer/VBoxContainer/StrokeColorContainer/RText
	var s_g_txt = $MarginContainer/VBoxContainer/StrokeColorContainer/GText
	var s_b_txt = $MarginContainer/VBoxContainer/StrokeColorContainer/BText
	var h_r_txt = $MarginContainer/VBoxContainer/HColorContainer/RText
	var h_g_txt = $MarginContainer/VBoxContainer/HColorContainer/GText
	var h_b_txt = $MarginContainer/VBoxContainer/HColorContainer/BText
	var text_start_txt = $MarginContainer/VBoxContainer/SectionContainer/StartHeightText
	var text_end_txt = $MarginContainer/VBoxContainer/SectionContainer/EndHeightText
	var text_steps_txt = $MarginContainer/VBoxContainer/SectionContainer/StepsText

	# Make sure all the number controls have valid values in them
	if not width_txt.is_valid:
		return false
	if not height_txt.is_valid:
		return false
	if not left_txt.is_valid:
		return false
	if not top_txt.is_valid:
		return false
	if not x_txt.is_valid:
		return false
	if not y_txt.is_valid:
		return false
	if not s_width_txt.is_valid:
		return false
	if not s_r_txt.is_valid:
		return false
	if not s_g_txt.is_valid:
		return false
	if not s_b_txt.is_valid:
		return false
	if not h_r_txt.is_valid:
		return false
	if not h_g_txt.is_valid:
		return false
	if not h_b_txt.is_valid:
		return false
	if not text_start_txt.is_valid:
		return false
	if not text_end_txt.is_valid:
		return false
	if not text_steps_txt.is_valid:
		return false

	return true

"""
Called to export a single file to the local file system.
"""
func _export_to_file(svg_path, output_opts, section_height):
	var script_text = get_parent()
	script_text = script_text._convert_component_tree_to_script(false)

	var ct = get_parent().get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	var comp_names = Common.get_all_components(ct)

	for comp_name in comp_names:
		# If the caller provided a section height, use it
		if section_height:
			script_text += "\n" + comp_name + "=build_" + comp_name + "().section(" + str(section_height) + ")"
		else:
			script_text += "\n" + comp_name + "=build_" + comp_name + "()"

		# Make sure something gets exported
		script_text += "\nshow_object(" + comp_name + ")"

	var ret = cqgipy
	ret = ret.export(script_text, "svg", OS.get_user_data_dir(), output_opts)

	# If the export succeeded, move the contents of the export to the final location
	if ret.begins_with("error~"):
		# Let the user know there was an error
		var err = ret.split("~")[1]
		emit_signal("error", err)
	else:
		# Read the exported file contents and write them to their final location
		# Work-around for not being able to write to the broader filesystem via Python
		var stl_text = FileSystem.load_file_text(ret)
		FileSystem.save_component(svg_path, stl_text)


"""
Collects the output option control settings into a string that
can be passed to cq-cli.
"""
func _collect_output_opts():
	var output_opts = ""

	# Shortcuts for the projection direction controls
	var x_dir = $MarginContainer/VBoxContainer/ProjDirContainer/XText
	x_dir = x_dir.get_text()
	var y_dir = $MarginContainer/VBoxContainer/ProjDirContainer/YText
	y_dir = y_dir.get_text()
	var z_dir = $MarginContainer/VBoxContainer/ProjDirContainer/ZText
	z_dir = z_dir.get_text()

	# Shortcuts for the stroke color controls
	var s_red = $MarginContainer/VBoxContainer/StrokeColorContainer/RText
	s_red = s_red.get_text()
	var s_green = $MarginContainer/VBoxContainer/StrokeColorContainer/GText
	s_green = s_green.get_text()
	var s_blue = $MarginContainer/VBoxContainer/StrokeColorContainer/BText
	s_blue = s_blue.get_text()

	# Shortcuts for the hidden color controls
	var h_red = $MarginContainer/VBoxContainer/HColorContainer/RText
	h_red = h_red.get_text()
	var h_green = $MarginContainer/VBoxContainer/HColorContainer/GText
	h_green = h_green.get_text()
	var h_blue = $MarginContainer/VBoxContainer/HColorContainer/BText
	h_blue = h_blue.get_text()

	# Convert the show hidden checkbox into a string we can use
	var show_hidden = "False"
	var chk_box = $MarginContainer/VBoxContainer/HiddenCheckBox
	if chk_box.pressed:
		show_hidden = "True"

	# The SVG output parameter controls
	var width_txt = $MarginContainer/VBoxContainer/DimsContainer/WidthText
	var height_txt = $MarginContainer/VBoxContainer/DimsContainer/HeightText
	var left_txt = $MarginContainer/VBoxContainer/MarginContainer/LeftText
	var top_txt = $MarginContainer/VBoxContainer/MarginContainer/TopText
	var s_width_txt = $MarginContainer/VBoxContainer/StrokeWidthContainer/WidthText

	output_opts += "width:" + width_txt.get_text() + ";"
	output_opts += "height:" + height_txt.get_text() + ";"
	output_opts += "marginLeft:" + left_txt.get_text() + ";"
	output_opts += "marginTop:" + top_txt.get_text() + ";"
	output_opts += "showAxes:False;"
	output_opts += "projectionDir:(" + x_dir + "," + y_dir + "," + z_dir + ");"
	output_opts += "strokeWidth:" + s_width_txt.get_text() + ";"
	output_opts += "strokeColor:(" + s_red + "," + s_green + "," + s_blue + ");"
	output_opts += "hiddenColor:(" + h_red + "," + h_green + "," + h_blue + ");"
	output_opts += "showHidden:" + show_hidden + ";"

	return output_opts
