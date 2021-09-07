extends WindowDialog

signal error

var orig_size = null # The original size of the dialog


# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the selector/section controls until they are needed
	var sect_cont = $MainVBoxContainer/SectionContainer
	sect_cont.hide()
	
	self.rect_size = Vector2(355, 125)


"""
Called when the Section button is clicked.
"""
func _on_CheckButton_toggled(_button_pressed):
	# Show the selector and section controls if the check button is on, hide otherwise
	var chk_btn = $MainVBoxContainer/CheckContainer/CheckButton
	var sect_cont = $MainVBoxContainer/SectionContainer

	if chk_btn.pressed:
		sect_cont.show()

		orig_size = self.rect_size
	
		# Make sure the panel is the correct size to contain all controls
		self.rect_size = Vector2(355, 210)
	else:
		sect_cont.hide()

		if orig_size != null:
			self.rect_size = orig_size


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
	fd.add_filter('*.dxf')
	fd.connect('file_selected', self, '_export_select_finished')
	fd.popup_centered()


"""
Called after the export file selection has been made.
"""
func _export_select_finished(path):
	var path_txt = $MainVBoxContainer/HBoxContainer/PathText
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
	var pt = $MainVBoxContainer/HBoxContainer/PathText
	if pt.get_text() == "":
		emit_signal("error", "You must set a file path to export to.")

		return
	
	# Check to see if the user wants to do slicing
	var chk_btn = $MainVBoxContainer/CheckContainer/CheckButton
	if chk_btn.pressed:
		var start_height = $MainVBoxContainer/SectionContainer/StartHeightContainer/StartHeightText
		start_height = start_height.get_text()
		var end_height = $MainVBoxContainer/SectionContainer/EndHeightContainer/EndHeightText
		end_height = end_height.get_text()
		var steps = $MainVBoxContainer/SectionContainer/StepsContainer/StepsText
		steps = steps.get_text()

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
			var file_name = pt.get_text().replace(".dxf", "_" + str(i) + ".dxf")
			_export_to_file(file_name, cur_height)

			cur_height += layer_height

		# Do a final export right at the end height
		var file_name = pt.get_text().replace(".dxf", "_" + str(steps) + ".dxf")
		_export_to_file(file_name, end_height)
	else:
		# Export the single SVG file
		_export_to_file(pt.get_text(), null)

	# Hide this popup
	hide()


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	var start_txt = $MainVBoxContainer/SectionContainer/StartHeightContainer/StartHeightText
	var end_txt = $MainVBoxContainer/SectionContainer/EndHeightContainer/EndHeightText
	var steps_txt = $MainVBoxContainer/SectionContainer/StepsContainer/StepsText

	# Make sure all the number controls have valid values in them
	if not start_txt.is_valid:
		return false
	if not end_txt.is_valid:
		return false
	if not steps_txt.is_valid:
		return false

	return true

"""
Called to export a single file to the local file system.
"""
func _export_to_file(dxf_path, section_height):
	var script_text = get_parent()
	script_text = script_text._convert_component_tree_to_script(false)
	var ct = get_parent().get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	var comp_names = Common.get_all_components(ct)

	# Make sure that there are sections made for all components
	for comp_name in comp_names:
		# If the caller provided a section height, use it
		if section_height:
			script_text += "\n" + comp_name + "=" + comp_name + ".section(" + str(section_height) + ")"

		# Make sure something gets exported
		script_text += "\nshow_object(" + comp_name + ")"

	var ret = cqgipy
	ret = ret.export(script_text, "dxf", OS.get_user_data_dir())

	# If the export succeeded, move the contents of the export to the final location
	if ret.begins_with("error~"):
		# Let the user know there was an error
		var err = ret.split("~")[1]
		emit_signal("error", err)
	else:
		# Read the exported file contents and write them to their final location
		# Work-around for not being able to write to the broader filesystem via Python
		var dxf_text = FileSystem.load_file_text(ret)
		FileSystem.save_component(dxf_path, dxf_text)
