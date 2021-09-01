extends Control

var VERSIONNUM = "0.4.0-alpha"

var open_file_path # The component/CQ file that the user opened
var confirm_component_text = null
var safe_distance = 0 # The distance away the camera should be placed to be able to view the components
var combined = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the default tab to let the user know where to start
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	tabs.set_tab_title(0, "Start")

	# Get the component and param trees ready to use
	_init_component_tree()
	_init_params_tree()

	# Make sure the window is maximized on start
	OS.set_window_maximized(true)

	# Set the tooltips of the main controls
	$GUI/VBoxContainer/PanelContainer/Toolbar/OpenButton.hint_tooltip = tr("OPEN_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton.hint_tooltip = tr("SAVE_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton.hint_tooltip = tr("MAKE_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.hint_tooltip = tr("RELOAD_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/CloseButton.hint_tooltip = tr("CLOSE_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/HomeViewButton.hint_tooltip = tr("HOME_VIEW_BUTTON_HINT_TOOLTIP")
	$GUI/VBoxContainer/PanelContainer/Toolbar/AboutButton.hint_tooltip = tr("ABOUT_BUTTON_HINT_TOOLTIP")

	# Let the user know the app is ready to use
	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text(" Ready")


"""
Handles shortcut keys.
"""
func _input(event):
	if event.is_action_pressed("SaveComponent"):
		_save_component()


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
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	tabs.set_tab_title(0, open_file_path)

	# Load the component text to handle later
	var check_component_text = FileSystem.load_file_text(open_file_path)

	# Check to make sure that only cadquery is imported for safety reasons
	var imports = Security.CheckImports(check_component_text)
	if imports.size() > 0:
		# Makes sure that the confirmation dialog can trigger a component load
		confirm_component_text = check_component_text

		var txt = "It appears that the file you are opening contains extra imports.\nSemblage components are simply Python scripts, so certain\n types of imports can be a security risk. Please review the extra\nimports below to ensure they are acceptable.\n\n"
		txt += PoolStringArray(imports).join("\n")
		txt += "\n\nDo you still want to open the component file?"
		$ConfirmationDialog.dialog_text = txt
		$ConfirmationDialog.popup_centered()
	else:
		_load_component(check_component_text)


"""
Shortcut method for collecting the script text from the component
tree, executing it, and rendering the result.
"""
func _execute_and_render():
	var component_text = self._convert_component_tree_to_script(true)
	self._render_component_text(component_text)


"""
Used with the open dialog to load a component.
"""
func _load_component(component_text):
	# If this is a Semblage component file, load it into the component tree
	if Security.IsSemblageFile(component_text):
		# Prevent the user from reloading the script manually
		$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.hide()

		# Load the component into the component tree and then render it
		load_semblage_component(component_text)
		self._execute_and_render()

		# Set the default view
		_home_view()
#	else:
#		# Allow the user to reload the script manually
#		$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.show()
#
#		# Render the component and set the camera view to the default
#		_render_non_semblage(open_file_path)
#		_home_view()


"""
Allows the trees holding the parameters and components to be cleared
and reset.
"""
func _reset_trees():
	var params_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree")
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	params_tree.clear()
	component_tree.clear()
	_init_params_tree()
	_init_component_tree()


"""
Loads a Semblage component file into the component tree.
"""
func load_semblage_component(text):
	var lines = text.split("\n")

	# Reset the trees
	_reset_trees()

	# Load any parameters that are in the script file
	var rgx = RegEx.new()
	rgx.compile("(?<=# start_params)((.|\n)*)(?=# end_params)")
	var res = rgx.search(text)
	if res:
		# Get the name and value and add them to the tree
		var params_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree")
		var params_tree_root = _get_params_tree_root(params_tree)

		# Step through all the parameters lines and add them to the tree
		var params = res.get_string().split("\n")
		for param in params:
			if param == "":
				continue

			var param_parts = param.split("=")
			Common.add_columns_to_tree(param_parts, params_tree, params_tree_root)

	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	var component_tree_root = _get_component_tree_root(component_tree)

	var cur_component = null

	# Step through all the lines and look for statements that need to be replayed
	for line in lines:
		var new_operation = null

		# Check to see if this is a component definition
		if line.find("=") > 0 and line.split("=")[1].begins_with("cq"):
			# Get the component name from the beginning
			var new_component = line.split("=")[0]

			# Save this new component name as the current for use later
			cur_component = new_component
			Common.add_component(new_component, component_tree)

			# See if there is metadata attached to this component
			if line.find("#") > 0:
				# We want to attach the metadata to the last component added
				var this_component = Common.get_last_component(component_tree)

				# Parse and save the meta data from the component's file
				var meta_str = line.split("# ")[1]
				var meta = JSON.parse(meta_str).result

				this_component.set_metadata(0, meta)
		# See if we have a binary operation
		elif cur_component != null and line.find("=") > 0 and not line.split("=")[1].begins_with(cur_component):
			new_operation = line.replace(cur_component + "=", "")
		# See if we have a normal operation
		elif cur_component != null and line.begins_with(cur_component + "=" + cur_component):
			# Update the context string in the ContextHandler
			new_operation = line.replace(cur_component + "=" + cur_component, "")

		# Only add the new operation if there is something to add
		if new_operation != null:
			# Add the current item to the component tree
			Common.add_operation(cur_component, new_operation, component_tree)

	# Selecting the first component in the list is a sane default
	component_tree_root.get_children().select(0)

	# Step through all the components and set their visibility properly
	var cur_item = component_tree_root.get_children()
	while true:
		if cur_item == null:
			break
		else:
			# Change the tree item name and collapse it if it is hidden
			if cur_item.get_metadata(0) != null and not cur_item.get_metadata(0)["visible"]:
				cur_item.set_suffix(0, " (hidden)")
				cur_item.set_collapsed(true)

			cur_item = cur_item.get_next()


"""
Steps through each component and their operations to collect
them into a script.
"""
func _convert_component_tree_to_script(include_show):
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# Reset the component show_object text
	var show_text = ""

	# Start off the component script text
	var component_text = "# Semblage v" + VERSIONNUM + "\nimport cadquery as cq\n"

	# Prepend any parameters
	component_text += "# start_params\n"
	component_text += _collect_parameters()
	component_text += "# end_params\n"

	var cur_comp = component_tree.get_root().get_children()

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_comp == null:
			break
		else:
			# Start the component off
			component_text += cur_comp.get_text(0) + "=cq  # " + JSON.print(cur_comp.get_metadata(0)) + "\n"

			# See if we are supposed to skip rendering this component
			if cur_comp.get_metadata(0) != null and cur_comp.get_metadata(0)["visible"]:
				show_text += "show_object(" + cur_comp.get_text(0) + ")\n"

			# Walk through any operations attached to this component
			var cur_op = cur_comp.get_children()
			while true:
				if cur_op == null:
					break
				else:
					# Assemble the operation step for a non-binary operation
					if cur_op.get_text(0).begins_with("."):
						component_text += cur_comp.get_text(0)  + "=" + cur_comp.get_text(0) + cur_op.get_text(0) + "\n"
					else:
						component_text += cur_comp.get_text(0)  + "=" + cur_op.get_text(0) + "\n"

				# Move to the next child operation, if there is one
				cur_op = cur_op.get_next()

			# Move to the next component, if there is one
			cur_comp = cur_comp.get_next()

	# See if the user has requested that the show text be included
	if include_show:
		component_text += show_text

	return component_text


"""
Collect parameters to be appended to the component text.
"""
func _collect_parameters():
	var param_text = ""

	# Attempt to get the parameter tree and its root item
	var params_tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree
	var params_tree_root = _get_params_tree_root(params_tree)

	# Loop through any parameters that are present and append them to the params section text
	var cur_param_item = params_tree_root.get_children()
	while true:
		if cur_param_item == null:
			break
		else:
			param_text += cur_param_item.get_text(0) + "=" + cur_param_item.get_text(1) + "\n"

			cur_param_item = cur_param_item.get_next()

	return param_text

"""
Generates a component using the semb CLI, which returns JSON.
"""
#func _render_non_semblage(path):
#	# Load the component's text from file
#	component_text = FileSystem.load_file_text(path)
#
#	# Render the loaded script text
#	_render_component_text()


"""
Uses Python to execute the current component_text, tessellate
the results, and display that in the 3D view.
"""
func _render_component_text(component_text):
	# Render the script text collected from the component tree, but only if there is something to render
	if component_text.ends_with("=cq\n"):
		return
	else:
		$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Rednering component...")

	# Clear the 3D viewport
	self._clear_viewport()

	# If we have untessellated objects (i.e. workplanes), display placeholders for them
	var untesses = ContextHandler.get_untessellateds(component_text)
	if len(untesses) > 0:
		for untess in untesses:
			var meshes = Meshes.gen_workplane_meshes(untess["origin"], untess["normal"])
			for mesh in meshes:
				$GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport.add_child(mesh)

	# Pass the script to the Python layer to convert it to tessellated JSON
	var component_json = cqgipy.build(component_text)

	# If there was an error, display it
	if component_json.begins_with("error~"):
		# Let the user know there was an error
		var err = component_json.split("~")[1]
		$ErrorDialog.dialog_text = err
		$ErrorDialog.popup_centered()
	else:
		# Load the JSON into the scene
		load_component_json(component_json)

	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Rednering component...done")


"""
Calculates the proper Y position to set the camera to fit a component or
assembly in the viewport.
"""
func get_safe_camera_distance(max_dim):
#	var x = vp.get_visible_rect().size.x
#	var y = vp.get_visible_rect().size.y
	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera

	var dist = max_dim / sin(PI / 180.0 * cam.fov * 0.5)

	return dist


"""
Loads a generated component into a mesh.
"""
func load_component_json(json_string):
	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Redering component...")

	# Get a reference to the 3D viewport
	var vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport
	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera
	var origin_cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/OriginViewportContainer/OriginViewport/OriginOrbitCamera
	var light = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/OmniLight

	var new_safe_dist = 0

	# Convert all of the returned results to meshes that can be displayed
	var component_json = JSON.parse(json_string).result
	for component in component_json["components"]:
		# If we've found a larger dimension, save the safe distance, which is the maximum dimension of any component
		var max_dim = component["largestDim"]
		var min_dim = component["smallestDim"]

		# Make sure the line width will be appropriate, even if this is a 2D object
		if min_dim == 0:
			min_dim = max_dim
	
		# Make sure the zoom speed works with the size of the model
		cam.ZOOMSPEED = 0.075 * max_dim

		# Get the new safe/sane camera distance
		new_safe_dist = get_safe_camera_distance(max_dim)

		# Get the mesh instance and the maximum distance
		var mesh_data = Meshes.gen_component_mesh(component)
		vp.add_child(mesh_data)

		# Add the edge representations
		for edge in component["cqEdges"]:
			var line = Meshes.gen_line_mesh(0.010 * min_dim, edge)
			vp.add_child(line)

	# Only reset the view if the same distance changed
	if new_safe_dist != safe_distance:
		# Find the safe distance for the camera based on the maximum distance of any vertex from the origin
		safe_distance = new_safe_dist # get_safe_camera_distance(max_dist)

		_home_view()

	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Redering component...done.")


"""
Helps make sure that each function runs atomically for tests.
"""
func _get_component_tree_root(component_tree):
	var component_tree_root = component_tree.get_root()
	if component_tree_root == null:
		_init_component_tree()
		component_tree_root = component_tree.get_root()

	return component_tree_root


"""
Allows the tests to run and helps make sure each function can run atomically.
"""
func _get_params_tree_root(params_tree):
	var params_tree_root = params_tree.get_root()
	if params_tree_root == null:
		_init_params_tree()
		params_tree_root = params_tree.get_root()

	return params_tree_root

"""
Handler that is called when the user clicks the button for the home view.
"""
func _on_HomeViewButton_button_down():
	# Reset the camera to the default starting position and rotation
	_home_view()


"""
Allows the origin camera, main 3D camera, and light to be returned to a
known poisition and orientation.
"""
func _home_view():
	# If the safe distance has not been set, there is nothing to do
	if self.safe_distance == 0:
		return

	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera
	var origin_cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/OriginViewportContainer/OriginViewport/OriginOrbitCamera
	var light = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/OmniLight

	# Adjust the safe distance so that the component fits well within the viewport
	var sd = self.safe_distance * 0.5

	# Set the main camera, the axis indicator camera, and the light to the default locations
	cam.look_at_from_position(Vector3(sd, sd, sd), Vector3(0, 0, 0), Vector3(0, 0, 1))
	origin_cam.look_at_from_position(Vector3(3, 3, 3), Vector3(0, 0, 0), Vector3(0, 0, 1))
	light.look_at_from_position(Vector3(self.safe_distance, self.safe_distance, self.safe_distance), Vector3(0, 0, 0), Vector3(0, 0, 1))

"""
Handler that is called when the user clicks the button to close the current component/view.
"""
func _on_CloseButton_button_down():
	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera

	# Reset the tranform for the camera back to the default
	_home_view()

	# Set the default tab name
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	tabs.set_tab_title(0, "Start")
	
	self._clear_viewport()
	
	# Get the tree views set up for the next component
	self._reset_trees()

	# Prevent the user from reloading the script manually
	$GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton.hide()

	# Let the user know the UI is ready to procede
	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Ready")


"""
Initializes the component tree so that it can be added to as the component changes.
"""
func _init_component_tree():
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# Create the root of the component tree
	var component_tree_root = component_tree.create_item()
	component_tree_root.set_text(0, "Workspace")


"""
Initializes the parameters tree so that items can be added to it.
"""
func _init_params_tree():
	var params_tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	# Create the root of the parameters tree
	var params_tree_root = params_tree.create_item()
	params_tree_root.set_text(0, "params")


"""
Handles the event of the user pressing the Reload button to reload a component 
from file.
"""
func _on_ReloadButton_button_down():
	pass
#	self._clear_viewport()

#	_render_non_semblage(open_file_path)

"""
Removes all MeshInstances from a viewport to prepare for something new to be loaded.
"""
func _clear_viewport():
	var vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport

	# Grab the viewport and its children
	var children = vp.get_children()

	# Remove any child that is not the camera, assuming everything else is a MeshInstance
	for child in children:
		if child.get_name() != "MainOrbitCamera" and child.get_name() != "OmniLight":
			vp.remove_child(child)
			child.free()


"""
Retries the updated context and makes it the current one.
"""
func _on_ActionPopupPanel_ok_signal(edit_mode, new_template, new_context, combine_map):
	var vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")
	var component_tree_root = _get_component_tree_root(component_tree)

	var old_component = null

	# If a component is selected, save the old component name
	if component_tree.get_selected():
		old_component = ContextHandler.get_component_from_template(component_tree.get_selected().get_text(0))

	# Find any component name (if present) that needs to be displayed in the list
	var new_component = ContextHandler.get_component_from_template(new_template)

	# Check to see if this is the first item that is being added to the component tree
	var is_first = component_tree_root.get_children() == null

	# We are in edit mode
	if edit_mode:
		# If the old component name does not match the new one, we want to update it
		var prev_template = ""

		# Get the selected item
		var sel = component_tree.get_selected()
		if sel:
			prev_template = sel.get_text(0)

		# Update the item text in the component tree
		Common.update_component_tree_item(component_tree, prev_template, new_template)

		# Update the component parent treeitem text
		if new_component:
			Common.update_component_tree_item(component_tree, old_component, new_component)

			# Make sure that the parent that was edited is selected for future operations
			Common.select_tree_item_by_text(component_tree, new_component)
	else:
		# Add the componenent name to the component tree if it had a name
		if new_component:
			# Add the component
			Common.add_component(new_component, component_tree)
			Common.add_operation(new_component, new_template, component_tree)

			# If there was a binary (i.e. boolean) operation, nest components as appropriate
			if combine_map != null:
				# Save this combine map
				combined = combine_map

				# Set the items that were combined to be invisible
				for cm in combine_map:
					for cmi in combine_map[cm]:
						Common.set_component_tree_item_visibility(component_tree, cmi, false)

			Common.select_tree_item_by_text(component_tree, new_component)
		else:
			# If there is an item selected in the component tree, use that
			var sel = component_tree.get_selected()
			if sel != null:
				new_component = sel.get_text(0)

			Common.add_operation(new_component, new_template, component_tree)

	# Render the component
	_execute_and_render()

	# If this is the first item being added, set the default view
	if is_first:
		_home_view()

"""
Fired when the Action popup needs to be displayed.
"""
func _on_DocumentTabs_activate_action_popup():
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# If an operation is selected, we need to select its parent component
	if component_tree.get_selected() != null and component_tree.get_selected().get_text(0).begins_with("."):
		component_tree.get_selected().get_parent().select(0)

	# Get the info that the operations dialog uses to set up the next operation
	var op_text = Common.get_last_op(component_tree)
	var comps = Common.get_all_components(component_tree)

	$ActionPopupPanel.activate_popup(op_text, false, comps)


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
		$ToolbarPopupPanel.rect_size = Vector2(100, 100)
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

	# Add the SVG export button
	var svg_item = Button.new()
	svg_item.set_text("SVG")
	svg_item.connect("button_down", self, "_show_export_svg")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(svg_item)

	# Add the DXF export button
	var dxf_item = Button.new()
	dxf_item.set_text("DXF")
	dxf_item.connect("button_down", self, "_show_export_dxf")
	$ToolbarPopupPanel/ToolbarPopupVBox.add_child(dxf_item)


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
Called when the About button is clicked.
"""
func _on_AboutButton_button_down():
	$AboutDialog.semblage_version = VERSIONNUM
	$AboutDialog.popup_centered()


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
	$SaveDialog.clear_filters()
	$SaveDialog.add_filter('*.py')
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
	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("")

	var file = File.new()
	file.open(self.open_file_path, File.WRITE)
	file.store_string(self._convert_component_tree_to_script(true))
	file.close()

	$GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel.set_text("Component saved")


"""
Figures out whether or not a component should be displayed.
"""
#func _should_show(component):
#	var should_show = true
#
#	# If there are combined items, search the list to see if it should be displayed
#	if combined.size() > 0:
#		if component in combined[combined.keys()[0]]:
#			should_show = false
#
#	return should_show


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
Sets up and shows the export dialog for SVG.
"""
func _show_export_svg():
	$ToolbarPopupPanel.hide()
	$ExportSVGDialog.popup_centered()


"""
Sets up and shows the export dialog for DXF.
"""
func _show_export_dxf():
	$ToolbarPopupPanel.hide()
	$ExportDXFDialog.popup_centered()

"""
Called when the user selects an export file location.
"""
func _on_ExportDialog_file_selected(path):
	var extension = path.split(".")[-1]

	# Make sure the user gave a valid extension
	if extension != "stl" and extension != "step":
		$AddParameterDialog/VBoxContainer/StatusLabel.text = "Export only supports the 'stl' and 'step' file extensions. Please try again."
		return

	var component_name = _get_component_name()

	var export_text = _convert_component_tree_to_script(true)

	# Export the file to the user data directory temporarily
	var ret = cqgipy.export(export_text, extension, OS.get_user_data_dir())

	# If the export succeeded, move the contents of the export to the final location
	if ret.begins_with("error~"):
		# Let the user know there was an error
		var err = ret.split("~")[1]
		$ErrorDialog.dialog_text = err
		$ErrorDialog.popup_centered()
	else:
		# Read the exported file contents and write them to their final location
		# Work-around for not being able to write to the broader filesystem via Python
		var stl_text = FileSystem.load_file_text(ret)
		FileSystem.save_component(path, stl_text)


"""
Called when the user confirms that they still want to open
a component file.
"""
func _on_ConfirmationDialog_confirmed():
	_load_component(confirm_component_text)


"""
Called when a new parameter is being added via the Parameter dialog.
"""
func _on_AddParameterDialog_add_parameter(new_param):
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	Common.add_columns_to_tree(new_param, tree, tree.get_root())

	self._execute_and_render()


"""
Called when a parameter entry is selected for editing.
"""
func _on_ParametersTree_item_activated():
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	var name_text = tree.get_selected().get_text(0)
	var value_text = tree.get_selected().get_text(1)

	$AddParameterDialog.activate_edit_mode(name_text, value_text)

	# We do not need the popup menu anymore
	$DataPopupPanel.hide()


"""
Called when the user is completed editing a parameter.
"""
func _on_AddParameterDialog_edit_parameter(new_param):
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	self._update_param_tree_items(tree, new_param[0], new_param[1])

	# Render the component tree unless the user is just pre-loading parameters
	self._execute_and_render()


"""
Called when the user wants to update a parameter in the tree.
"""
func _update_param_tree_items(tree, name, new_value):
	var cur_item = tree.get_root().get_children()

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			# If we have a text match, update the matching TreeItem's text
			if cur_item.get_text(0) == name:
				cur_item.set_text(1, new_value)
				break

			cur_item = cur_item.get_next()


"""
Called to collect the pairs from the parameters tree.
"""
func _collect_param_tree_pairs(tree):
	var items = []

	var cur_item = tree.get_root().get_children()

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			var new_item = []

			# Add this pair to the items that are collected
			new_item.append(cur_item.get_text(0))
			new_item.append(cur_item.get_text(1))
			items.append(new_item)

			cur_item = cur_item.get_next()

	return items


"""
Collects all the names of the components in the components tree.
"""
func _get_component_names():
	var names = []
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree

	var cur_item = tree.get_root().get_children()

	# Search the tree and collect the component names
	while true:
		if cur_item == null:
			break
		else:
			names.append(cur_item.get_text(0))

			cur_item = cur_item.get_next()

	return names


"""
Converts the human-readable component name into something that can
be used as a varaible.
"""
func _get_component_name():
	var comp_name = "result"
	var names = _get_component_names()

	# Figure out which component name to pass back
	if names.size() == 0:
		comp_name = "result"
	elif names.size() == 1:
		comp_name = names[0]
	else:
		# This will need to select the proper name later
		comp_name = names[0]

	return comp_name


"""
Allows an arbitrary error to be displayed to the user.
"""
func _on_error(error_text):
	var dlg = $ErrorDialog
	dlg.dialog_text = error_text
	dlg.popup_centered()


"""
Called when an item in the component list is double clicked.
"""
func _on_ComponentTree_item_activated():
	# Call the same code as if the user right clicked on the item and selected Edit
	_edit_tree_item()


"""
Allows the ActionPopupPanel to show error messages.
"""
func _on_ActionPopupPanel_error(error_text):
	_on_error(error_text)


"""
Clears any previously added items from the data popup.
"""
func _clear_data_popup():
	# Clear the previous control item(s) from the DynamicContainer
	for child in $DataPopupPanel/DataPopupVBox.get_children():
		$DataPopupPanel/DataPopupVBox.remove_child(child)


"""
The user clicks the Cancel button within the data popup.
"""
func _cancel_data_popup():
	$DataPopupPanel.hide()


"""
The user wants to remove a tree item, like an operation or component.
"""
func _remove_tree_item():
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var sel = ct.get_selected()
	if not sel:
		return

	# If deleting an operation, select its component
	if sel.get_text(0).begins_with("."):
		sel.get_parent().select(0)

	# Remove the selected item from the tree
	ct.get_root().remove_child(sel)
	sel.free()

	# Workaround to force the tree to update
	ct.visible = false
	ct.visible = true

	# We do not need the popup menu anymore
	$DataPopupPanel.hide()

	# Render any changes to the component tree
	self._execute_and_render()


"""
The user clicked the Edit tree menu item.
"""
func _edit_tree_item():
	# Get the selected item
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var sel = ct.get_selected()
	if sel:
		sel = sel.get_text(0)
	else:
		return

	$DataPopupPanel.hide()

	# Get the text that will tell the Operations dialog what might come next
	var prev_text = Common.get_last_op(ct)
	if not prev_text:
		prev_text = _convert_component_tree_to_script(false)

	# Get the component names that are in the component tree
	var comp_names = Common.get_all_components(ct)

	# If the selected item starts with a period, it is an operation item
	if sel.begins_with("."):
		$ActionPopupPanel.activate_edit_mode(prev_text, sel, comp_names)
	else:
		var edit_child = ct.get_selected().get_children()

		# Check to see if this is a binary operation
		if edit_child == null:
			edit_child = ct.get_selected()

		edit_child.select(0)
		$ActionPopupPanel.activate_edit_mode(prev_text, edit_child.get_text(0), comp_names)


"""
Hiding a component in the tree causes it to not have a show_object call
in the final script output.
"""
func _show_hide_tree_item():
	# Get the selected item
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var sel = ct.get_selected()
	if not sel:
		return

	# Toggle the show/hide state
	var meta = sel.get_metadata(0)
	if meta["visible"]:
		# Collapse the tree item as a visual cue that it is being rendered again
		sel.collapsed = true

		# Let the user know this component is hidden
		sel.set_suffix(0, " (hidden)")

		# Toggle the metadata
		sel.set_metadata(0, {"visible": false})
	else:
		# Collapse the tree item as a visual cue that it is being rendered again
		sel.collapsed = false

		# Stop telling the user that this component is hidden
		sel.set_suffix(0, "")

		# Toggle the metadata
		sel.set_metadata(0, {"visible": true})

	# We do not need the popup menu anymore
	$DataPopupPanel.hide()

	# Render any changes to the component tree
	self._execute_and_render()


"""
Called when the user right clicks on the Component tree.
"""
func _on_ComponentTree_activate_data_popup():
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var pos = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree.get_local_mouse_position()
	var size = Vector2(50, 100)

	var popup_height = 75

	# If there is nothing in the tree, do not display the menu
	if not ct.get_selected():
		return

	# Lets us know whether or not a component is selected
	var is_component = not ct.get_selected().get_text(0).begins_with(".")

	# If we are selecting a Component, there are some different options
	if is_component:
		popup_height = 100

	# Clear any previous items
	_clear_data_popup()

	# Toggle the visiblity of the popup
	if $DataPopupPanel.visible:
		$DataPopupPanel.hide()
	else:
		$DataPopupPanel.rect_position = Vector2(pos.x, pos.y + size.y)
		$DataPopupPanel.rect_size = Vector2(100, popup_height)
		$DataPopupPanel.show()

	# Add the Edit item
	var edit_item = Button.new()
	edit_item.set_text("Edit")
	edit_item.connect("button_down", self, "_edit_tree_item")
	$DataPopupPanel/DataPopupVBox.add_child(edit_item)

	# Add the Remove item
	var remove_item = Button.new()
	remove_item.set_text("Remove")
	remove_item.connect("button_down", self, "_remove_tree_item")
	$DataPopupPanel/DataPopupVBox.add_child(remove_item)

	# This is a component, allow the user to show and hide it
	if is_component:
		# Add the Show/Hide item
		var show_hide_item = Button.new()
		show_hide_item.set_text("Show/Hide")
		show_hide_item.connect("button_down", self, "_show_hide_tree_item")
		$DataPopupPanel/DataPopupVBox.add_child(show_hide_item)

	# Add the Cancel item
	var cancel_item = Button.new()
	cancel_item.set_text("Cancel")
	cancel_item.connect("button_down", self, "_cancel_data_popup")
	$DataPopupPanel/DataPopupVBox.add_child(cancel_item)


"""
Start a new parameter item.
"""
func _new_param_tree_item():
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	# Collect any existing items from the parameters tree for safety checks
	var items = _collect_param_tree_pairs(tree)
	$AddParameterDialog.set_existing_parameters(items)

	$AddParameterDialog.popup_centered()

	# We do not need the popup menu anymore
	$DataPopupPanel.hide()


"""
Remove the selected parameter tree item.
"""
func _remove_param_tree_item():
	var pt = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	var selected = pt.get_selected()

	# Make sure there is an item to delete
	if selected == null:
		return

	# Make sure the user is not trying to delete something like the root node
	if selected.get_text(0) == "params":
		return

	# Remove the item from the parameters tree
	selected.free()

	# Workaround to force the tree to update
	pt.visible = false
	pt.visible = true

	# We do not need the popup menu anymore
	$DataPopupPanel.hide()

	# Render any changes to the component tree
	self._execute_and_render()


"""
Handles the right click menu for the parameters tree.
"""
func _on_ParametersTree_activate_data_popup():
	var pt = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree
	var global_pos = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree.get_global_mouse_position()
#	var pos = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree.get_local_mouse_position()

	var size = Vector2(50, 100)

	var popup_height = 100

	# Clear any previous items
	_clear_data_popup()

	# Toggle the visiblity of the popup
	if $DataPopupPanel.visible:
		$DataPopupPanel.hide()
	else:
		$DataPopupPanel.rect_position = Vector2(global_pos.x, global_pos.y)
		$DataPopupPanel.rect_size = Vector2(100, popup_height)
		$DataPopupPanel.show()

	# Add the New item
	var new_item = Button.new()
	new_item.set_text("New")
	new_item.connect("button_down", self, "_new_param_tree_item")
	$DataPopupPanel/DataPopupVBox.add_child(new_item)

	# Add the Edit item
	var edit_item = Button.new()
	edit_item.set_text("Edit")
	edit_item.connect("button_down", self, "_on_ParametersTree_item_activated")
	$DataPopupPanel/DataPopupVBox.add_child(edit_item)

	# Add the Remove item
	var remove_item = Button.new()
	remove_item.set_text("Remove")
	remove_item.connect("button_down", self, "_remove_param_tree_item")
	$DataPopupPanel/DataPopupVBox.add_child(remove_item)

	# Add the Cancel item
	var cancel_item = Button.new()
	cancel_item.set_text("Cancel")
	cancel_item.connect("button_down", self, "_cancel_data_popup")
	$DataPopupPanel/DataPopupVBox.add_child(cancel_item)


"""
Event that can be fired by nodes to request a new render.
"""
func _on_requesting_render():
	self._execute_and_render()
