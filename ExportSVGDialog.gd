extends WindowDialog

var orig_size = null # The original size of the dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the selector/section controls until they are needed
	$MarginContainer/VBoxContainer/SectionContainer.hide()


"""
Called when the Section button is clicked.
"""
func _on_CheckButton_toggled(button_pressed):
	# Show the selector and section controls if the check button is on, hide otherwise
	if $MarginContainer/VBoxContainer/SectionCheckContainer/CheckButton.pressed:
		$MarginContainer/VBoxContainer/SectionContainer.show()

		orig_size = rect_size
	
		# Make sure the panel is the correct size to contain all controls
		rect_size = Vector2(rect_size[0], 415)
	else:
		$MarginContainer/VBoxContainer/SectionContainer.hide()

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
	$MarginContainer/VBoxContainer/PathContainer/PathText.set_text(path)


"""
Called when the user clicks the ok button.
"""
func _on_OkButton_button_down():
	var pt = $MarginContainer/VBoxContainer/PathContainer/PathText

	# Let the user know they have not set an export directory
	if pt.get_text() == "":
		_show_error_dialog("You must set a file path to export to.")

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
			_show_error_dialog("End height cannot be less than starting height.")
			return
		if end_height == 0.0:
			_show_error_dialog("End height cannot be zero.")
			return
		if steps == 0:
			_show_error_dialog("Steps must be greater than zero.")

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
Called to export a single file to the local file system.
"""
func _export_to_file(svg_path, output_opts, section_height):
	var script_text = get_parent().component_text

	# If the caller provided a section height, use it
	if section_height:
		script_text += "\nresult = result.section(" + str(section_height) + ")"

	# Make sure something gets exported
	script_text += "\nshow_object(result)"
	print(script_text)
	# The currently rendered component should be here
	var temp_path = OS.get_user_data_dir() + "/temp_component_svg.py"
	FileSystem.save_component(temp_path, script_text)

	# Set up our command line parameters
	var cur_error_file = OS.get_user_data_dir() + "/error_svg.txt"
	var array = ["--codec", "svg", "--infile", temp_path, "--outfile", svg_path, "--errfile", cur_error_file, "--outputopts", output_opts]
	var args = PoolStringArray(array)

	# Execute the render script
	var success = OS.execute(Settings.get_cq_cli_path(), args, true)

	# Track whether or not execution happened successfully
	if success != 0:
		# Let the user know there was an SVG export error
		_show_error_dialog("There was an error exporting the SVG.")


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


"""
Used any time we need to display the error dialog.
"""
func _show_error_dialog(error_text):
	var ed = get_parent().get_node("ErrorDialog")
	ed.dialog_text = error_text
	ed.popup_centered()

	return
