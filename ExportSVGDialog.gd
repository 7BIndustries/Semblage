extends WindowDialog

signal error

var orig_size = null # The original size of the dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the selector/section controls until they are needed
	$MarginContainer/VBoxContainer/SectionContainer.hide()


"""
Called when the Section button is clicked.
"""
func _on_CheckButton_toggled(_button_pressed):
	# Show the selector and section controls if the check button is on, hide otherwise
	if $MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton.pressed:
		$MarginContainer/VBoxContainer/SectionContainer.show()

		self.orig_size = self.rect_size
	
		# Make sure the panel is the correct size to contain all controls
		self.rect_size = Vector2(382, 440)
	else:
		$MarginContainer/VBoxContainer/SectionContainer.hide()

		if orig_size != null:
			self.rect_size = self.orig_size

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
	$MarginContainer/VBoxContainer/PathContainer/PathText.set_text(path)


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
	if $MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton.pressed:
		var start_height = $MarginContainer/VBoxContainer/SectionContainer/StartHeightText.get_text()
		var end_height = $MarginContainer/VBoxContainer/SectionContainer/EndHeightText.get_text()
		var steps = $MarginContainer/VBoxContainer/SectionContainer/StepsText.get_text()

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
	# Make sure all the number controls have valid values in them
	if not $MarginContainer/VBoxContainer/DimsContainer/WidthText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/DimsContainer/HeightText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/MarginContainer/LeftText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/MarginContainer/TopText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/ProjDirContainer/XText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/ProjDirContainer/YText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/StrokeWidthContainer/WidthText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/StrokeColorContainer/RText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/StrokeColorContainer/GText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/StrokeColorContainer/BText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/HColorContainer/RText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/HColorContainer/GText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/HColorContainer/BText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/SectionContainer/StartHeightText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/SectionContainer/EndHeightText.is_valid:
		return false
	if not $MarginContainer/VBoxContainer/SectionContainer/StepsText.is_valid:
		return false

	return true

"""
Called to export a single file to the local file system.
"""
func _export_to_file(svg_path, output_opts, section_height):
	var script_text = get_parent().component_text

	# If the caller provided a section height, use it
	if section_height:
		script_text += "\nresult = result.section(" + str(section_height) + ")"

	# Make sure something gets exported
	script_text += "\nshow_object(result)"

	var ret = cqgipy.export(script_text, "svg", OS.get_user_data_dir(), output_opts)

	# If the export succeeded, move the contents of the export to the final location
	if ret.begins_with("error~"):
		# Let the user know there was an error
		var err = ret.split("~")[1]
		emit_signal("error", err)
	else:
		# Read the exported file contents and write them to their final location
		# Work-around for not being able to write to the broader filesystem via Python
		var stl_text = FileSystem.load_component(ret)
		FileSystem.save_component(svg_path, stl_text)


"""
Collects the output option control settings into a string that
can be passed to cq-cli.
"""
func _collect_output_opts():
	var output_opts = ""

	# Shortcuts for the projection direction controls
	var x_dir = $MarginContainer/VBoxContainer/ProjDirContainer/XText.get_text()
	var y_dir = $MarginContainer/VBoxContainer/ProjDirContainer/YText.get_text()
	var z_dir = $MarginContainer/VBoxContainer/ProjDirContainer/ZText.get_text()

	# Shortcuts for the stroke color controls
	var s_red = $MarginContainer/VBoxContainer/StrokeColorContainer/RText.get_text()
	var s_green = $MarginContainer/VBoxContainer/StrokeColorContainer/GText.get_text()
	var s_blue = $MarginContainer/VBoxContainer/StrokeColorContainer/BText.get_text()

	# Shortcuts for the hidden color controls
	var h_red = $MarginContainer/VBoxContainer/HColorContainer/RText.get_text()
	var h_green = $MarginContainer/VBoxContainer/HColorContainer/GText.get_text()
	var h_blue = $MarginContainer/VBoxContainer/HColorContainer/BText.get_text()

	# Convert the show hidden checkbox into a string we can use
	var show_hidden = "False"
	if $MarginContainer/VBoxContainer/HiddenCheckBox.pressed:
		show_hidden = "True"

	output_opts += "width:" + $MarginContainer/VBoxContainer/DimsContainer/WidthText.get_text() + ";"
	output_opts += "height:" + $MarginContainer/VBoxContainer/DimsContainer/HeightText.get_text() + ";"
	output_opts += "marginLeft:" + $MarginContainer/VBoxContainer/MarginContainer/LeftText.get_text() + ";"
	output_opts += "marginTop:" + $MarginContainer/VBoxContainer/MarginContainer/TopText.get_text() + ";"
	output_opts += "showAxes:False;"
	output_opts += "projectionDir:(" + x_dir + "," + y_dir + "," + z_dir + ");"
	output_opts += "strokeWidth:" + $MarginContainer/VBoxContainer/StrokeWidthContainer/WidthText.get_text() + ";"
	output_opts += "strokeColor:(" + s_red + "," + s_green + "," + s_blue + ");"
	output_opts += "hiddenColor:(" + h_red + "," + h_green + "," + h_blue + ");"
	output_opts += "showHidden:" + show_hidden + ";"

	return output_opts
