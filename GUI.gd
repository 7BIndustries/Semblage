extends Control

var open_file_path # The component/CQ file that the user opened
var component_text # The text of the current component's script
var safe_distance = 0 # The distance away the camera should be placed to be able to view the components
var status # The status bar that keeps the user appraised of what is going on
var cur_temp_file # The path to the current temp file
var cur_error_file # The path to the current error file, if needed
var executing = false # Whether or not a script is currently executing
var home_transform # Allows us to move the camera back to the starting location/rotation/etc
var origin_transform # Allows us to move the orgin camera view back to a starting transform
var cam # The main camera for the 3D view
var origin_cam # The camera showing the orientation of the component(s) via an origin indicator
var light # Supplemental light that follows the camera
var vp # The 3D viewport
var tabs # The tab container for component documents
var object_tree = null
var history_tree = null
var object_tree_root = null
var history_tree_root = null

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/OriginViewportContainer/OriginViewport/OriginOrbitCamera
	cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera
	light = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/OmniLight
	vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport
	tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs

	# Set the default tab to let the user know where to start
	tabs.set_tab_title(0, "Start")

	# Start off with the base script text
	_reset_component_text()

	# Get the object and history trees ready to use
	_init_history_tree()
	_init_object_tree()

	cur_temp_file = OS.get_user_data_dir() + "/temp_component.json"

	# Empty the temporary component file so that it can be reused
	FileSystem.clear_file(cur_temp_file)

	# Make sure the window is maximized on start
	OS.set_window_maximized(true)

	# Let the user know the app is ready to use
	status = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status.text = " Ready"

"""
Used to do things like check if a semb process is generating a component.
"""
func _process(delta):
	# Error file handling
	if executing && cur_error_file != null:
		var cur_file = File.new()

		# If we are executing and there is an error file, display the error
		if cur_file.file_exists(cur_error_file):
			cur_file.open(cur_error_file, File.READ)

			# Load the JSON from the file
			var error_string = cur_file.get_as_text()

			# Display the error to the user
			$ErrorDialog.dialog_text = error_string
			$ErrorDialog.popup_centered()

			# Empty the temporary component file so that it can be reused
			FileSystem.clear_file(cur_temp_file)

			# Prevent us from entering this code block again
			cur_error_file = null

			executing = false
			
			status.text = " Generation Error"
			
#			if error_string.ends_with("semb_process_finished"):
#				error_string = error_string.replace("semb_process_finished", "")
#
#				$ErrorDialog.dialog_text = error_string
#				$ErrorDialog.popup_centered()
#
#				# Prevent us from entering this code block again
#				cur_temp_file = null
#				cur_error_file = null
#
#				executing = false
#
#				status.text = " Generation Error"

			# Remove the current temp file since we no longer need it
#			var array = [cur_temp_file, cur_error_file]
#			var args = PoolStringArray(array)
#			OS.execute("rm", args, false)

		cur_file.close()

	# JSON file handling
	if executing:
		var cur_file = File.new()

		# If we are executing and the file exists, process it
		if cur_file.file_exists(cur_temp_file):
			cur_file.open(cur_temp_file, File.READ)

			# Get the JSON text from the file
			var json_string = cur_file.get_as_text()

			if json_string.ends_with("semb_process_finished"):
				json_string = json_string.replace("semb_process_finished", "")

				# Load the JSON into the scene
				load_component_json(json_string)

				# Empty the temporary component file so that it can be reused
				FileSystem.clear_file(cur_temp_file)

				executing = false

			# Remove the current temp file since we no longer need it
#			var array = [cur_temp_file]
#			var args = PoolStringArray(array)
#			OS.execute("rm", args, false)

		cur_file.close()


"""
Handler for when the Open Component button is clicked.
"""
func _on_OpenButton_button_down():
	$OpenDialog.popup_centered()

"""
Handles rendering the user-selected file to the 3DView.
"""
func _on_OpenDialog_file_selected(path):
	# Clear the viewport for the next component that is loaded
	self._clear_viewport()

	# Save the open file path for use later
	open_file_path = path

	# Let the user know the name of the file they are trying to open
	tabs.set_tab_title(0, open_file_path)

	# Load the component text to handle later
	component_text = FileSystem.load_component(open_file_path)

	# If this is a Semblage component file, load it into the history and object trees
	if component_text.begins_with("# Semblage v"):
		# Prevent the user from reloading the script manually
		$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.hide()

		# Load the component into the history and object trees and then render it
		load_semblage_component(component_text)
		_render_history_tree()
	else:
		# Allow the user to reload the script manually
		$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.show()

		_render_non_semblage(open_file_path)


"""
Loads a Semblage component file into the history and object trees.
"""
func load_semblage_component(text):
	var lines = text.split("\n")

	# Start the component text off with what we know the first 3 lines will be
	_reset_component_text()

	# Step through all the lines and look for statements that need to be replayed
	for line in lines:
		if line.begins_with("result = result"):
			# Update the context string in the ContextHandler
			var addition = line.replace("result = result", "")

			# Add the current item to the history tree
			Common.add_item_to_tree(addition, history_tree, history_tree_root)

			# Find any object name (if present) that needs to be displayed in the list
			var new_object = ContextHandler.get_object_from_template(addition)
			Common.add_item_to_tree(new_object, object_tree, object_tree_root)

			component_text = ContextHandler.update_context_string(component_text, addition)


"""
Generates a component using the semb CLI, which returns JSON.
"""
func _render_non_semblage(path):
	# If component text has been passed, it have probably been modified from any file contents
	if component_text != null:
		# We want to write the component text to a temporary file and render the result of executing that
		var temp_component_path = OS.get_user_data_dir() + "/temp_component_path.py"
		
		# We append the show_object here so that it is not part of the context going forward
		FileSystem.save_component(temp_component_path, component_text + "\nshow_object(result)")
		
		# Switch path to pass that to cq-cli
		path = temp_component_path

	# Get the date and time and use it to construct the unique file id
	var date_time = OS.get_datetime()
	var file_id = str(date_time["year"]) + "_" +  str(date_time["month"]) + "_" + str(date_time["day"]) + "_" + str(date_time["hour"]) + "_" + str(date_time["minute"]) + "_" + str(date_time["second"])

	# Construct the directory where the temporary JSON file can be written
	cur_error_file = OS.get_user_data_dir() + "/error_" + file_id + ".txt"

	# Temporary location and name of the file to convert
	var array = ["--codec", "semb", "--infile", path, "--outfile", cur_temp_file, "--errfile", cur_error_file]
	var args = PoolStringArray(array)

	# Execute the render script
	var success = OS.execute(Settings.get_cq_cli_path(), args, false)

	# Track whether or not execution happened successfully
	if success == -1:
		status.text = "Execution error"
	else:
		executing = true
		status.text = "Generating component..."

"""
Calculates the proper Y position to set the camera to fit a component or
assembly in the viewport.
"""
func get_safe_camera_distance(max_dim):
	var x = vp.get_visible_rect().size.x
	var y = vp.get_visible_rect().size.y

	var dist = max_dim / sin(PI / 180.0 * cam.fov * 0.5)

	return dist


"""
Loads a generated component into a mesh.
"""
func load_component_json(json_string):
	status.text = "Redering component..."

	var new_safe_dist = 0

	# Convert all of the returned results to meshes that can be displayed
	var component_json = JSON.parse(json_string).result
	for component in component_json["components"]:
		# If we've found a larger dimension, save the safe distance, which is the maximum dimension of any component
		var max_dim = component["largestDim"]

		# Make sure the zoom speed works with the size of the model
		cam.ZOOMSPEED = 0.075 * max_dim

		# Get the new safe/sane camera distance
		new_safe_dist = get_safe_camera_distance(max_dim)

		# Get the mesh instance and the maximum distance
		var mesh_data = Meshes.gen_component_mesh(component)
		vp.add_child(mesh_data)

	# Only reset the view if the same distance changed
	if new_safe_dist != safe_distance:
		# Find the safe distance for the camera based on the maximum distance of any vertex from the origin
		safe_distance = new_safe_dist # get_safe_camera_distance(max_dist)

		# Set the camera to the safe distance and have it look at the origin
		cam.look_at_from_position(Vector3(0, -safe_distance, 0), Vector3(0, 0, 0), Vector3(0, 0, 1))
		origin_cam.look_at_from_position(Vector3(0, -3, 0), Vector3(0, 0, 0), Vector3(0, 0, 1))
		light.look_at_from_position(Vector3(0, -safe_distance, -safe_distance), Vector3(0, 0, 0), Vector3(0, 0, 1))

		# Save this transform as the home transform
		home_transform = cam.get_transform()
		origin_transform = origin_cam.get_transform()

	status.text = "Redering component...done."


"""
Handler that is called when the user clicks the button for the home view.
"""
func _on_HomeViewButton_button_down():
	# Reset the tranform for the camera back to the one we saved when the scene loaded
	if home_transform != null: cam.transform = home_transform

	# Reset the origin indicator camera back to the view we saved on scene load
	if origin_transform != null: origin_cam.transform = origin_transform


"""
Handler that is called when the user clicks the button to close the current component/view.
"""
func _on_CloseButton_button_down():
	# Reset the tranform for the camera back to the one we saved when the scene loaded
	if cam != null && home_transform != null: cam.transform = home_transform

	# Set the default tab name
	tabs.set_tab_title(0, "Start")
	
	open_file_path = null
	_reset_component_text()

	self._clear_viewport()
	
	# Get the tree views set up for the next object
	self.history_tree.clear()
	self.object_tree.clear()
	self._init_history_tree()
	self._init_object_tree()

	# Prevent the user from reloading the script manually
	$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.hide()


"""
Initializes the object tree so that it can be added to as the component changes.
"""
func _init_object_tree():
	object_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/ObjectTree")

	# Create the root of the object tree
	self.object_tree_root = object_tree.create_item()
	self.object_tree_root.set_text(0, "Workspace")


"""
Initializes the history tree so that it can be added to as the component changes.
"""
func _init_history_tree():
	history_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/HistoryTree")

	# Create the root of the history tree
	self.history_tree_root = history_tree.create_item()
	self.history_tree_root.set_text(0, "cq")


"""
Handles the event of the user pressing the Reload button to reload a component 
from file.
"""
func _on_ReloadButton_button_down():
	self._clear_viewport()
	self.history_tree.clear()

	_render_non_semblage(open_file_path)

"""
Removes all MeshInstances from a viewport to prepare for something new to be loaded.
"""
func _clear_viewport():
	# Grab the viewport and its children
	var children = vp.get_children()

	# Remove any child that is not the camera, assuming everything else is a MeshInstance
	for child in children:
		if child.get_name() != "MainOrbitCamera" and child.get_name() != "OmniLight":
			vp.remove_child(child)


"""
Retries the updated context and makes it the current one.
"""
func _on_ActionPopupPanel_ok_signal(edit_mode, new_template, new_context):
	self._clear_viewport()

	# If we have untessellated objects (i.e. workplanes), display placeholders for them
	var untesses = ContextHandler.get_untessellateds(new_template)
	if len(untesses) > 0:
		for untess in untesses:
			var meshes = Meshes.gen_workplane_meshes(untess["origin"], untess["normal"])
			for mesh in meshes:
				vp.add_child(mesh)

	# Save the updated component text
	component_text = new_context

	# Find any object name (if present) that needs to be displayed in the list
	var new_object = ContextHandler.get_object_from_template(new_template)

	# If we are in edit mode, do not try to add anything to the history
	if edit_mode:
		# Update the edited entry within the history tree
		var prev_template = history_tree.get_selected().get_text(0) # $ActionPopupPanel.get_prev_template()
		Common.update_tree_item(history_tree, prev_template, new_template)

		# Update the component name in the object tree if the object name was changed
#		if new_object:
#			var prev_object = $ActionPopupPanel.get_prev_object_addition()
#			Common.update_tree_item(object_tree, prev_object, new_object)
	else:
		# Add the current item to the history tree
		Common.add_item_to_tree(new_template, history_tree, history_tree_root)

		# Add the componenent name to the object tree if it had a name
		if new_object:
			Common.add_item_to_tree(new_object, object_tree, object_tree_root)

	# Render the component
	_render_history_tree()


"""
Collects all of the history tree items and renders them into an
object in the 3D view.
"""
func _render_history_tree():
	# Start to build the preview string based on what is in the actions list
	_reset_component_text()
#	var script_text = "# Semblage v1\nimport cadquery as cq\nresult=cq"

	# Search the tree and update the matchine entry in the tree
	var cur_item = history_tree_root.get_children()
	while true:
		if cur_item == null:
			break
		else:
			component_text += cur_item.get_text(0)

			cur_item = cur_item.get_next()

	var script_text = component_text + "\nshow_object(result)"

	# We want to write the component text to a temporary file and render the result of executing that
	var temp_component_path = OS.get_user_data_dir() + "/temp_component_path.py"
	
	# We append the show_object here so that it is not part of the context going forward
	FileSystem.save_component(temp_component_path, script_text)

	# Get the date and time and use it to construct the unique file id
	var date_time = OS.get_datetime()
	var file_id = str(date_time["year"]) + "_" +  str(date_time["month"]) + "_" + str(date_time["day"]) + "_" + str(date_time["hour"]) + "_" + str(date_time["minute"]) + "_" + str(date_time["second"])

	# Construct the directory where the temporary JSON file can be written
	cur_error_file = OS.get_user_data_dir() + "/error_" + file_id + ".txt"

	# Temporary location and name of the file to convert
	var array = ["--codec", "semb", "--infile", temp_component_path, "--outfile", cur_temp_file, "--errfile", cur_error_file]
	var args = PoolStringArray(array)

	# Execute the render script
	var success = OS.execute(Settings.get_cq_cli_path(), args, false)

	# Track whether or not execution happened successfully
	if success == -1:
		status.text = "Execution error"
	else:
		executing = true
		status.text = "Generating component..."


"""
Fired when the Action popup needs to be displayed.
"""
func _on_DocumentTabs_activate_action_popup(mouse_pos):
	$ActionPopupPanel.activate_popup(component_text, false)


"""
Allows a user to edit a history entry by double-clicking on the entry in the History
Tree.
"""
func _on_HistoryTree_item_activated():
	var item_text = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/HistoryTree.get_selected().get_text(0)

	$ActionPopupPanel.activate_edit_mode(component_text, item_text)


"""
Called when the user clicks the Make button.
"""
func _on_MakeButton_button_down():
	var pos = $GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton.rect_position
	var size = $GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton.rect_size

	# Clear any previous items
	_clear_toolbar_popup()

	# Toggle the visiblity of the popup
	if $ToolbarPopupPanel.visible:
		$ToolbarPopupPanel.hide()
	else:
		$ToolbarPopupPanel.rect_position = Vector2(pos.x, pos.y + size.y)
		$ToolbarPopupPanel.show()

	# Add the STL export button
	var stl_item = Button.new()
	stl_item.set_text("STL")
	stl_item.connect("button_down", self, "_show_export_stl")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(stl_item)

	# Add the STEP export button
	var step_item = Button.new()
	step_item.set_text("STEP")
	step_item.connect("button_down", self, "_show_export_step")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(step_item)


"""
Called when the user clicks the save button.
"""
func _on_SaveButton_button_down():
	var pos = $GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton.rect_position
	var size = $GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton.rect_size

	# Clear any previous items
	_clear_toolbar_popup()

	# Toggle the visiblity of the popup
	if $ToolbarPopupPanel.visible:
		$ToolbarPopupPanel.hide()
	else:
		$ToolbarPopupPanel.rect_position = Vector2(pos.x, pos.y + size.y)
		$ToolbarPopupPanel.show()

	# Add the Save Component button
	var save_item = Button.new()
	save_item.set_text("Save")
	save_item.connect("button_down", self, "_save_component")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(save_item)

	# Add the Save As button
	var save_as_item = Button.new()
	save_as_item.set_text("Save As")
	save_as_item.connect("button_down", self, "_save_component_as")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(save_as_item)


"""
Called when the Save component button is clicked.
"""
func _save_component():
	$ToolbarPopupPanel.hide()

	if self.open_file_path == null:
		_save_component_as()
	else:
		# Save the current component's text to the specified file
		_save_component_text()


"""
Called when the Save As component button is clicked.
"""
func _save_component_as():
	$ToolbarPopupPanel.hide()

	$SaveDialog.current_file = "component.py"
	$SaveDialog.popup_centered()


"""
Called when a user selects the component's save location.
"""
func _on_SaveDialog_file_selected(path):
	if path != null:
		# Keep track of where the currently open file is
		self.open_file_path = path

		# Save the current component's text to the specified file
		_save_component_text()


"""
Handles the heavy lifting of saving the component text to file.
"""
func _save_component_text():
	var file = File.new()
	file.open(self.open_file_path, File.WRITE)
	file.store_string(self.component_text + "\nshow_object(result)")
	file.close()


"""
Clears any previous items that were in the popup.
"""
func _clear_toolbar_popup():
	# Clear the previous control item(s) from the DynamicContainer
	for child in $ToolbarPopupPanel/ToolbarPopupVBox.get_children():
		$ToolbarPopupPanel/ToolbarPopupVBox.remove_child(child)


"""
Sets up the export dialog for STL.
"""
func _show_export_stl():
	$ToolbarPopupPanel.hide()
	$ExportDialog.current_file = "component.stl"
	$ExportDialog.popup_centered()


"""
Sets up the export dialog for STEP.
"""
func _show_export_step():
	$ToolbarPopupPanel.hide()
	$ExportDialog.current_file = "component.step"
	$ExportDialog.popup_centered()


"""
Called when the user selects an export file location.
"""
func _on_ExportDialog_file_selected(path):
	var extension = path.split(".")[-1]

	# Make sure the user gave a valid extension
	if extension != "stl" and extension != "step":
		status.text = "Export only supports the 'stl' and 'step' file extensions. Please try again."
		return


	# Come up with a unique ID for the error file
	var date_time = OS.get_datetime()
	var file_id = str(date_time["year"]) + "_" +  str(date_time["month"]) + "_" + str(date_time["day"]) + "_" + str(date_time["hour"]) + "_" + str(date_time["minute"]) + "_" + str(date_time["second"])

	# The currently rendered component should be here
	var temp_file = OS.get_user_data_dir() + "/temp_component_path.py"

	# Set up our command line parameters
	var cur_error_file = OS.get_user_data_dir() + "/error_" + file_id + ".txt"
	var array = ["--codec", extension, "--infile", temp_file, "--outfile", path, "--errfile", cur_error_file]
	var args = PoolStringArray(array)

	# Execute the render script
	var success = OS.execute(Settings.get_cq_cli_path(), args, false)

	# Track whether or not execution happened successfully
	if success == -1:
		status.text = "Export error"


"""
Gives a single place to reset the component text when starting up
or closing a previous component.
"""
func _reset_component_text():
	component_text = "# Semblage v1\nimport cadquery as cq\nresult=cq"


"""
Called when the user clicks on the button to delete an item from
the history tree.
"""
func _on_DeleteButton_button_down():
	var selected = history_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Make sure the user is not trying to delete something they should not
	if selected.get_text(0) == "cq":
		return
	if selected.get_text(0).begins_with(".Workplane"):
		return

	# Remove the item from the history tree
	selected.free()

	self._clear_viewport()
	self._render_history_tree()


"""
Called when the user clicks on the button to move an item up the
history tree.
"""
func _on_MoveUpButton_button_down():
	var selected = history_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Make sure the user is not trying to move something they should not
	if selected.get_text(0) == "cq":
		return
	if selected.get_text(0).begins_with(".Workplane"):
		return

	# Move the item up the history tree one position
	Common.move_tree_item_up(history_tree, selected)

	self._clear_viewport()
	self._render_history_tree()

"""
Called when the user clicks on the button to move an item up the
history tree.
"""
func _on_MoveDownButton_button_down():
	var selected = history_tree.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Make sure the user is not trying to move something they should not
	if selected.get_text(0) == "cq":
		return
	if selected.get_text(0).begins_with(".Workplane"):
		return

	# Move the item down in the history tree one position
	Common.move_tree_item_down(history_tree, selected)

	self._clear_viewport()
	self._render_history_tree()
