extends Control

signal error

var VERSIONNUM = "0.4.0-alpha"

var open_file_path # The component/CQ file that the user opened
var confirm_component_text = null
var safe_distance = 0 # The distance away the camera should be placed to be able to view the components
var combined = {}
var insert_mode = false # The user wants to insert an operation in the components tree
var edit_mode = false # The user wants to edit an entry in the components tree
var face_select_mode = false # Tracks whether the user wants to select a face
var render_tree = null # Keeps track of all the data tree returned by the last execution
var quit_after_save = false # Lets the component be closed after saving

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
	get_tree().set_auto_accept_quit(false)

	# Set the tooltips of the main controls
	var open_button = $GUI/VBoxContainer/PanelContainer/Toolbar/OpenButton
	var save_button = $GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton
	var make_button = $GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton
	var reload_button = $GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton
	var close_button = $GUI/VBoxContainer/PanelContainer/Toolbar/CloseButton
	var home_button = $GUI/VBoxContainer/PanelContainer/Toolbar/HomeViewButton
	var about_button = $GUI/VBoxContainer/PanelContainer/Toolbar/AboutButton
	open_button.hint_tooltip = tr("OPEN_BUTTON_HINT_TOOLTIP")
	save_button.hint_tooltip = tr("SAVE_BUTTON_HINT_TOOLTIP")
	make_button.hint_tooltip = tr("MAKE_BUTTON_HINT_TOOLTIP")
	reload_button.hint_tooltip = tr("RELOAD_BUTTON_HINT_TOOLTIP")
	close_button.hint_tooltip = tr("CLOSE_BUTTON_HINT_TOOLTIP")
	home_button.hint_tooltip = tr("HOME_VIEW_BUTTON_HINT_TOOLTIP")
	about_button.hint_tooltip = tr("ABOUT_BUTTON_HINT_TOOLTIP")

	# Connect the error signal to the handler method for errors
	var _ret = connect("error", self, "_on_error")

	# Let the user know the app is ready to use
	var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status_lbl.set_text(" Ready")


"""
Handles shortcut keys.
"""
func _input(event):
	var ray_length = 1000

	var vp = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")

	if event.is_action_pressed("SaveComponent"):
		_save_component()

	# Check if the face selection key has been pressed
	if event.is_action_pressed("mouse_select"):
		face_select_mode = true

		# The user wants to use mouse selection and so we need to set up the collision objects
		for child in vp.get_children():
			if child.get_class() == "MeshInstance":
				child.create_trimesh_collision()

		# Keep the app from crashing if there was an error and we try to save
		if render_tree == null or typeof(render_tree) == 4:
			return
	elif event.is_action_released("mouse_select"):
		face_select_mode = false

		# Step through every mesh, set their materials back to their default and remove the StaticBody colliders
		for child in vp.get_children():
			# Make sure we are working with a mesh
			if child.get_class() == "MeshInstance":
				# Remove the vertex meshes
				if child.get_meta("parent_perm_id") and child.get_meta("parent_perm_id").begins_with("face"):
					_deselect_mesh(child)

				for mesh_child in child.get_children():
					if mesh_child.get_class() == "StaticBody":
						child.remove_child(mesh_child)
	elif event.is_action_pressed("vertex_select"):
		face_select_mode = true

		# The user wants to use mouse selection, so we need to add vertex meshes and collision objects
		# Add the vertex representations
		if render_tree and render_tree["components"]:
			for comp_tree in render_tree["components"]:
				for vertex in comp_tree["vertices"]:
					var vert = Meshes.gen_vertex_mesh(0.05 * comp_tree["smallest_dimension"], vertex, vertex["perm_id"])
					vert.create_trimesh_collision()
					vp.add_child(vert)
	elif event.is_action_released("vertex_select"):
		face_select_mode = false

		# Deselect all meshes that the user might have clicked on
		_remove_vertices()

	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if face_select_mode == true:
			var camera = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera")

			# Mouse position to construct ray
			var mouse_pos = vp.get_mouse_position()
			var ray_from = camera.project_ray_origin(mouse_pos)
			var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * ray_length

			# Cast the ray and see what it intersects with
			var space_state = vp.get_world().direct_space_state
			var selection = space_state.intersect_ray(ray_from, ray_to)

			# If a surface was clicked on highlight it, otherwise unhighlight it
			if selection.size() > 0:
				# Get the mesh that this is attached to
				var mesh = selection.collider.get_parent()

				# Check to see if this surface is already selected
				if mesh.get_surface_material(0) != null and mesh.get_surface_material(0).albedo_color == Color(0.5, 0.5, 0.05, 1.0):
					_deselect_mesh(mesh)
				else:
					_select_mesh(mesh)
			else:
				# Step through every mesh, set their materials back to their default and remove the StaticBody colliders
				for child in vp.get_children():
					# Make sure we are working with a mesh
					if child.get_class() == "MeshInstance":
						for mesh_child in child.get_children():
							if mesh_child.get_class() == "StaticBody":
								_deselect_mesh(child)


"""
Removes all of the vertex meshes that were added for the user to select them
with the mouse pointer.
"""
func _remove_vertices():
	var vp = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")

	# Step through every mesh, set their materials back to their default and remove the StaticBody colliders
	for child in vp.get_children():
		# Make sure we are working with a mesh
		if child.get_class() == "MeshInstance":
			# Remove the vertex meshes
			if child.get_meta("parent_perm_id") and child.get_meta("parent_perm_id").begins_with("vertex"):
				vp.remove_child(child)

			for mesh_child in child.get_children():
				if mesh_child.get_class() == "StaticBody":
					child.remove_child(mesh_child)

"""
Highlights a mesh so that it is obvious that it is selected.
"""
func _select_mesh(mesh):
	# Set this surface's material so that it stands out from the rest of the surfaces
	var new_color = [0.5, 0.5, 0.05, 1.0]
	var material = SpatialMaterial.new()
	material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])

	# We are dealing with an edge or vertex
	if mesh.mesh.get_class() == "CubeMesh":
		# We will use the viewport to search all edge or vertex meshes
		var vp = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")

		# Find out what the ID of the parent of this segment is, so that we can also select any siblings
		var parent_id = mesh.get_meta("parent_perm_id")

		# Step through all the meshses in the 3D viewport
		for child in vp.get_children():
			# Make sure that we have an edge or vertex mesh
			if child.get_class() == "MeshInstance" and child.mesh.get_class() == "CubeMesh":
				# See if the parent matches this other edge segment and highlight it too if it does
				if mesh != child and child.get_meta("parent_perm_id") != null and child.get_meta("parent_perm_id") == parent_id:
					child.set_surface_material(0, material)

	mesh.set_surface_material(0, material)


"""
Removes the highlight from a mesh so that it no longer looks selected.
"""
func _deselect_mesh(mesh):
	# The default material color
	var default_color = [1.0, 0.36, 0.05, 1.0]

	# If we have an edge mesh or a vertex, set it back to white
	if mesh.mesh.get_class() == "CubeMesh":
		default_color = [1.0, 1.0, 1.0, 1.0]

	# Create a material with the currect default color
	var material = SpatialMaterial.new()
	material.albedo_color = Color(default_color[0], default_color[1], default_color[2], default_color[3])

	# Find out what the ID of the parent of this segment is, so that we can also select any siblings
	var parent_id = mesh.get_meta("parent_perm_id")

	# Make sure that we have an edge or vertex mesh
	if mesh.mesh.get_class() == "CubeMesh":
		# We will use the viewport to search all edge or vertex meshes
		var vp = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")

		# Step through all the meshses in the 3D viewport
		for child in vp.get_children():
			# Make sure that we have an edge or vertex mesh
			if child.get_class() == "MeshInstance" and child.mesh.get_class() == "CubeMesh":
				# See if the parent matches this other edge segment and highlight it too if it does
				if mesh != child and child.get_meta("parent_perm_id") != null and child.get_meta("parent_perm_id") == parent_id:
					child.set_surface_material(0, material)

	# Swap the material color back to the original
	mesh.set_surface_material(0, material)


"""
Handler for when the Open Component button is clicked.
"""
func _on_OpenButton_button_down():
	var open_dlg = $OpenDialog
	open_dlg.popup_centered()

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
		var confirm_dlg = $ConfirmationDialog
		confirm_dlg.dialog_text = txt
		confirm_dlg.popup_centered()
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
		var reload_btn = $GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton
		reload_btn.hide()

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

			# Get the parameter assignment parts and the metadata
			var param_parts = param.split("=")
			var param_meta = param_parts[1].split("#")

			# Add the parameter with the meta data to the parameter tree
			var new_param_item = params_tree.create_item(params_tree_root)
			new_param_item.set_text(0, param_parts[0].replace(" ", ""))
			new_param_item.set_text(1, param_parts[1].split("#")[0].replace(" ", ""))

			# Make sure there is parameter metadata
			if param_meta.size() > 1:
				var new_json = JSON.parse(param_meta[1].replace("\n", ""))
				new_param_item.set_metadata(0, new_json.result)
			else:
				# Automatically update any older Semblage files
				var meta = {"data_type": "string", "comment": ""}
				new_param_item.set_metadata(0, meta)

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
				var meta = JSON.parse(meta_str)
				meta = meta.result

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
	if component_tree_root.get_children():
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
			component_text += "def build_" + cur_comp.get_text(0) + "():\n"
			# Start the component off
			component_text += "    " + cur_comp.get_text(0) + "=cq  # " + JSON.print(cur_comp.get_metadata(0)) + "\n"

			# See if we are supposed to skip rendering this component
			if cur_comp.get_metadata(0) != null and cur_comp.get_metadata(0)["visible"]:
				#show_text += cur_comp.get_text(0) + "=build_" + cur_comp.get_text(0) + "()\n"
				show_text += "show_object(" + cur_comp.get_text(0) + ")\n"

			# Walk through any operations attached to this component
			var cur_op = cur_comp.get_children()
			while true:
				if cur_op == null:
					break
				else:
					# Assemble the operation step for a non-binary operation
					if cur_op.get_text(0).begins_with("."):
						component_text += "    " + cur_comp.get_text(0)  + "=" + cur_comp.get_text(0) + cur_op.get_text(0) + "\n"
					else:
						component_text += "    " + cur_comp.get_text(0)  + "=" + cur_op.get_text(0) + "\n"

				# Move to the next child operation, if there is one
				cur_op = cur_op.get_next()

			component_text += "    return " + cur_comp.get_text(0) + "\n"

			# Make sure that this component is available for other components to use
			component_text += cur_comp.get_text(0) + "=build_" + cur_comp.get_text(0) + "()\n\n"

			# Move to the next component, if there is one
			cur_comp = cur_comp.get_next()

	# See if the user has requested that the show text be included
	if include_show:
		component_text += show_text

	return component_text


"""
Allows the caller to get the parameter key/value pairs.
"""
func _get_parameter_items():
	var params = {}

	# Attempt to get the parameter tree and its root item
	var params_tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree
	var params_tree_root = _get_params_tree_root(params_tree)

	# Loop through any parameters that are present and append them to the params section text
	var cur_param_item = params_tree_root.get_children()
	while true:
		if cur_param_item == null:
			break
		else:
			params[cur_param_item.get_text(0)] = cur_param_item.get_text(1)

			cur_param_item = cur_param_item.get_next()

	return params


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
			param_text += cur_param_item.get_text(0) + "=" + cur_param_item.get_text(1) + " # " + JSON.print(cur_param_item.get_metadata(0)) + "\n"

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
		var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
		status_lbl.set_text("Rendering component...")

	# Clear the 3D viewport
	self._clear_viewport()

	# Method that post-processes the results of the script to pull out renderables
	render_tree = cqgipy
	if cqgipy.has_method('get_render_tree'):
		render_tree = render_tree.get_render_tree(component_text)
	else:
		emit_signal("error", "The current component has invalid geometry. Please undo the last operation and try a different method.")

	# See if we got an error
	if typeof(render_tree) == 4:
		# Let the user know there was an error
		var err = render_tree.split("~")[1]
		# Let the user know that an error occurred
		emit_signal("error", err)
		var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
		status_lbl.set_text("Rendering error")

		return

	# Render any workplanes that need to be rendered
	for comp_tree in render_tree["components"]:
		# If there are workplanes, add them as their own meshes
		if comp_tree["workplanes"].size() > 0:
			for cur_wp in comp_tree["workplanes"]:
				# Do the work of creating the workplane meshes
				var meshes = Meshes.gen_workplane_meshes(cur_wp["origin"], cur_wp["normal"], cur_wp["size"])
				for mesh in meshes:
					$GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport.add_child(mesh)

		# Make all of the component meshes visible
		render_component_tree(comp_tree)

	var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status_lbl.set_text("Rendering component...done")


"""
Adds meshes for each of the component entities in the render tree.
"""
func render_component_tree(component):
	var vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport
	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera

	var new_safe_dist = 0

	# If we've found a larger dimension, save the safe distance, which is the maximum dimension of any component
	var max_dim = component["largest_dimension"]
	var min_dim = component["smallest_dimension"]

	# Make sure there is a max dimension or things like zooming will become weird
	if max_dim <= 0:
		max_dim = 5.0

	# Make sure the line width will be appropriate, even if this is a 2D object
	if min_dim <= 0:
		min_dim = max_dim

	# Make sure the zoom speed works with the size of the model
	cam.ZOOMSPEED = 0.075 * max_dim

	# Get the new safe/sane camera distance
	new_safe_dist = get_safe_camera_distance(max_dim)
	var meshes = Meshes.gen_component_meshes(component)
	for mesh in meshes:
		vp.add_child(mesh)

	# Add the edge representations
	for edge in component["edges"]:
		for seg in component["edges"][edge]["segments"]:
			var line = Meshes.gen_line_mesh(0.010 * min_dim, seg, edge)
			vp.add_child(line)

	# Only reset the view if the same distance changed
	if new_safe_dist != safe_distance:
		# Find the safe distance for the camera based on the maximum distance of any vertex from the origin
		safe_distance = new_safe_dist # get_safe_camera_distance(max_dist)

		_home_view()

	var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status_lbl.set_text("Redering component...done.")


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
	if safe_distance == 0:
		return

	var cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/MainOrbitCamera
	var origin_cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/OriginViewportContainer/OriginViewport/OriginOrbitCamera
	var light = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/OmniLight

	# Adjust the safe distance so that the component fits well within the viewport
	var sd = safe_distance * 0.75

	# Set the main camera, the axis indicator camera, and the light to the default locations
	cam.look_at_from_position(Vector3(sd, sd, sd), Vector3(0, 0, 0), Vector3(0, 0, 1))
	origin_cam.look_at_from_position(Vector3(3, 3, 3), Vector3(0, 0, 0), Vector3(0, 0, 1))
	light.look_at_from_position(Vector3(safe_distance, safe_distance, safe_distance), Vector3(0, 0, 0), Vector3(0, 0, 1))

	# If we are working with the perspective camera, we need to set the size as well
	cam.size = sd
"""
Handler that is called when the user clicks the button to close the current component/view.
"""
func _on_CloseButton_button_down():
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs

	# See if there is a need to save the current component first
	if tabs.get_tab_title(0).find("*") > 0:
		var cd = get_node("SaveBeforeCloseDialog")
		cd.popup_centered()

		return

	# Reset the tranform for the camera back to the default
	_home_view()

	# Set the default tab name
	tabs.set_tab_title(0, "Start")
	
	self._clear_viewport()
	
	# Get the tree views set up for the next component
	self._reset_trees()

	# Prevent the user from reloading the script manually
	var reload_btn = $GUI/VBoxContainer/PanelContainer/Toolbar/ReloadButton
	reload_btn.hide()

	# Make sure the user cannot save a blank component over the previously opened one
	open_file_path = null

	# Let the user know the UI is ready to procede
	var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status_lbl.set_text("Ready")


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
func _on_ActionPopupPanel_ok_signal(new_template, combine_map):
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
		edit_mode = false

		# If the old component name does not match the new one, we want to update it
		var prev_template = ""

		# Get the selected item
		var sel = component_tree.get_selected()
		if sel:
			prev_template = sel.get_text(0)

		# Update the item text in the component tree
		sel.set_text(0, new_template)

		# Update the component parent treeitem text
		if new_component:
			Common.update_component_tree_item(component_tree, old_component, new_component)

			# Make sure that the parent that was edited is selected for future operations
			Common.select_tree_item_by_text(component_tree, new_component)
	elif insert_mode:
		insert_mode = false

		# Get the selected tree item so that we can insert before it
		var sel = component_tree.get_selected()

		# Get the parent of the selected item since that is where we should add the new operation
		var par = sel.get_parent()

		# Create a tree item holding the operation that was selected
		var tree_item = component_tree.create_item(par)
		tree_item.set_text(0, new_template)

		# Insert the new item before selected one
		Common.move_before(tree_item, sel)
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

	# Let the user know the name of the file they are trying to open
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	if tabs.get_tab_title(0).find("*") <= 0:
		tabs.set_tab_title(0, tabs.get_tab_title(0) + " *")


"""
Called when the user decides they do not want to use the Operations dialog.
"""
func _on_ActionPopupPanel_cancel():
	edit_mode = false
	insert_mode = false


"""
Fired when the Action popup needs to be displayed.
"""
func _on_DocumentTabs_activate_action_popup():
	var component_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# If an operation is selected, we need to select its parent component
	if component_tree.get_selected() != null and component_tree.get_selected().get_text(0).begins_with("."):
		component_tree.get_selected().get_parent().select(0)

	var selector_str = null

	# See if the user is wanting to trigger selector synthesis
	if Input.is_action_pressed("mouse_select"):
		selector_str = _synthesize_selector()

	# Get the info that the operations dialog uses to set up the next operation
	var op_text = Common.get_last_op(component_tree)
	var comps = Common.get_all_components(component_tree)
	var params = _get_parameter_items()

	var op_panel = $ActionPopupPanel
	op_panel.activate_popup(op_text, false, comps, params, selector_str)


"""
Using what is selected in the 3D view, determines a valid selector string that
will produce the selection.
"""
func _synthesize_selector():
	var vp = get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")

	var selector_str = null

	# The selected geometry color
	var selected_color = [0.5, 0.5, 0.05, 1.0]

	# Keep track of how many faces have been selected
	var num_selected = 0

	# Tracked information about the selected faces
	var selected_origins = []
	var selected_normals = []
	var selected_faces = []

	# Tracked information about the other faces
	var other_origins = []
	var other_normals = []
	var other_faces = []

	# Step through all the meshes and see which one is selected
	for child in vp.get_children():
		# Make sure we are working with a mesh
		if child.get_class() == "MeshInstance":
			var norm = child.get_meta("normal")
			var orig = child.get_meta("origin")

			var material = child.get_surface_material(0)
			if material:
				var ac = material.albedo_color

				# See if the mesh is selected (highlighted color)
				if LinAlg.compare_floats(ac.r, selected_color[0]) and\
				   LinAlg.compare_floats(ac.g, selected_color[1]) and\
				   LinAlg.compare_floats(ac.b, selected_color[2]):
					# Keep track of the number of selected faces
					num_selected += 1

					# Save the information for this selected face
					selected_origins.append(orig)
					selected_normals.append(norm)
					selected_faces.append(child.get_meta("parent_perm_id"))
				else:
					# Save the information for this non-selected face
					if orig != null:
						other_origins.append(orig)
						other_normals.append(norm)
						other_faces.append(child.get_meta("parent_perm_id"))
			else:
				# Save the information for this non-selected face
				if orig != null:
					other_origins.append(orig)
					other_normals.append(norm)
					other_faces.append(child.get_meta("parent_perm_id"))

	# Bundle all the information about the selected and non-selected faces
	var faces = Dictionary()
	faces["selected_origins"] = selected_origins
	faces["selected_normals"] = selected_normals
	faces["selected_faces"] = selected_faces
	faces["other_origins"] = other_origins
	faces["other_normals"] = other_normals
	faces["other_faces"] = other_faces

	# Attempt to synthesize a selector based on what is selected and what is not
	selector_str = synth.synthesize(selected_origins, selected_normals, other_origins, other_normals)

	return selector_str


"""
Called when the user clicks the Make button.
"""
func _on_MakeButton_button_down():
	var make_btn = $GUI/VBoxContainer/PanelContainer/Toolbar/MakeButton
	var pos = make_btn.rect_position
	var size = make_btn.rect_size

	# Clear any previous items
	_clear_toolbar_popup()

	# Toggle the visiblity of the popup
	var tb_popup = $ToolbarPopupPanel
	if tb_popup.visible:
		tb_popup.hide()
	else:
		tb_popup.rect_position = Vector2(pos.x, pos.y + size.y)
		tb_popup.rect_size = Vector2(100, 100)
		tb_popup.show()

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
	var save_btn = $GUI/VBoxContainer/PanelContainer/Toolbar/SaveButton
	var pos = save_btn.rect_position
	var size = save_btn.rect_size

	# Clear any previous items
	_clear_toolbar_popup()

	# Toggle the visiblity of the popup
	var tb_popup = $ToolbarPopupPanel
	if tb_popup.visible:
		tb_popup.hide()
	else:
		tb_popup.rect_position = Vector2(pos.x, pos.y + size.y)
		tb_popup.rect_size = Vector2(100, 50)
		tb_popup.show()

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
	var about_dlg = $AboutDialog
	about_dlg.semblage_version = VERSIONNUM
	about_dlg.popup_centered()


"""
Called when the Save component button is clicked.
"""
func _save_component():
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	if open_file_path == null:
		_save_component_as()
	else:
		# Save the current component's text to the specified file
		_save_component_text()

	# Remove the asterisk marking that the component is not dirty
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	tabs.set_tab_title(0, tabs.get_tab_title(0).replace(" *", ""))


"""
Called when the Save As component button is clicked.
"""
func _save_component_as():
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	var save_dlg = $SaveDialog
	save_dlg.current_file = "component.py"
	save_dlg.clear_filters()
	save_dlg.add_filter('*.py')
	save_dlg.popup_centered()


"""
Called when a user selects the component's save location.
"""
func _on_SaveDialog_file_selected(path):
	if path != null:
		# Keep track of where the currently open file is
		open_file_path = path

		# Save the current component's text to the specified file
		_save_component_text()


"""
Handles the heavy lifting of saving the component text to file.
"""
func _save_component_text():
	var status_lbl = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status_lbl.set_text("")

	# Attempt to open the file for writing
	var file = File.new()
	var err = file.open(open_file_path, File.WRITE)

	# Let the user know if they do not have write access
	if err != OK:
		emit_signal("error", "The file cannot be written. Please make sure that\nyou have write permissions to the directory.")
		status_lbl.set_text("Component save error")
		return

	# It is ok to write the contents to the file
	file.store_string(_convert_component_tree_to_script(true))
	file.close()

	status_lbl.set_text("Component saved")


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
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	var export_dlg = $ExportDialog
	export_dlg.current_file = "component.stl"
	export_dlg.popup_centered()


"""
Sets up the export dialog for STEP.
"""
func _show_export_step():
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	var export_dlg = $ExportDialog
	export_dlg.current_file = "component.step"
	export_dlg.popup_centered()


"""
Sets up and shows the export dialog for SVG.
"""
func _show_export_svg():
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	var export_dlg = $ExportSVGDialog
	export_dlg.popup_centered()


"""
Sets up and shows the export dialog for DXF.
"""
func _show_export_dxf():
	var tb_popup = $ToolbarPopupPanel
	tb_popup.hide()

	var export_dlg = $ExportDXFDialog
	export_dlg.popup_centered()

"""
Called when the user selects an export file location.
"""
func _on_ExportDialog_file_selected(path):
	var extension = path.split(".")[-1]

	# Make sure the user gave a valid extension
	if extension != "stl" and extension != "step":
		var status_lbl = get_node("GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel") #$AddParameterDialog/VBoxContainer/StatusLabel
		status_lbl.text = "Export Error"
		emit_signal("error", "Export only supports the 'stl' and 'step'\nfile extensions. Please try again.")
		return

	var export_text = _convert_component_tree_to_script(true)

	# Export the file to the user data directory temporarily
	var ret = cqgipy
	if cqgipy.has_method('export'):
		ret = ret.export(export_text, extension, OS.get_user_data_dir())
	else:
		emit_signal("error", "The current component has invalid geometry. Please undo the last operation and try a different method.")

	# If the export succeeded, move the contents of the export to the final location
	if ret.begins_with("error~"):
		# Let the user know there was an error
		var err = ret.split("~")[1]
		emit_signal("error", err)
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
func _on_AddParameterDialog_add_parameter(new_param, data_type, comment):
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	Common.add_columns_to_tree(new_param, tree, tree.get_root())

	# Assemble the metadata JSON string
	var meta = {"data_type": data_type, "comment": comment}

	# Get the last entry that was added to the tree
	var last_item = Common.get_last_component(tree)
	last_item.set_metadata(0, meta)

	self._execute_and_render()


"""
Called when a parameter entry is selected for editing.
"""
func _on_ParametersTree_item_activated():
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	# Make sure that something was visible/selected in the tree
	if tree.get_selected() == null:
		return

	var name_text = tree.get_selected().get_text(0)
	var value_text = tree.get_selected().get_text(1)

	# Get the meta data from the selected item
	var meta = tree.get_selected().get_metadata(0)

	var param_dlg = $AddParameterDialog
	param_dlg.activate_edit_mode(name_text, value_text, meta["data_type"], meta["comment"])

	# We do not need the popup menu anymore
	var data_popup = $DataPopupPanel
	data_popup.hide()


"""
Called when the user is completed editing a parameter.
"""
func _on_AddParameterDialog_edit_parameter(new_param, data_type, comment):
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	self._update_param_tree_items(tree, new_param[0], new_param[1])

	# Assemble the metadata JSON string
	var meta = {"data_type": data_type, "comment": comment}

	# Attach the metadata to the selected component
	var selected_item = tree.get_selected()
	selected_item.set_metadata(0, meta)

	# Render the component tree unless the user is just pre-loading parameters
	self._execute_and_render()


"""
Called when the user requests a new tuple list parameter.
"""
func _on_new_tuple():
	var param_dlg = $AddParameterDialog

	var param_name = param_dlg.get_node("MarginContainer/VBoxContainer/ParamNameTextEdit")
	param_name.set_text("point_list")
	param_dlg._on_TupleListCheckBox_button_down()

	param_dlg.popup_centered()


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
	var dlg = get_node("ErrorDialog")

	# Intercept the generic BRep_API error
	if error_text.begins_with("BRep_API: command not done"):
		error_text = "You have received a general error from the CAD kernel.\nPlease undo your last change and try another operation\nor parameter setting."

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
	var data_popup = $DataPopupPanel
	data_popup.hide()

"""
Allows the user to add a component or operation to the components tree.
"""
func _add_tree_item():
	# Act as if the user right-clicked on the 3D view
	_on_DocumentTabs_activate_action_popup()

	# We do not need the popup menu anymore
	var data_popup = $DataPopupPanel
	data_popup.hide()


"""
The user clicks the Insert Above button within the data popup.
"""
func _insert_tree_item():
	var ct = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# Get the selected item and make sure it is valid
	var sel = ct.get_selected()

	if sel:
		sel = sel.get_text(0)
	else:
		return

	# We do not need the popup menu anymore
	var data_popup = get_node("DataPopupPanel")
	data_popup.hide()

	# Make sure that we are dealing with an operation
	if sel.begins_with("."):
		var op_panel = get_node("ActionPopupPanel")

		# Get the component names that are in the component tree
		var comp_names = Common.get_all_components(ct)
		var params = _get_parameter_items()

		var component_text = _convert_component_tree_to_script(false)

		# Keep track of the fact that we want to insert an operation, and not edit or append
		insert_mode = true
		op_panel.activate_popup(component_text, null, comp_names, params, null)


"""
The user wants to remove a tree item, like an operation or component.
Make sure the user really wants to do it.
"""
func _remove_tree_item():
	# Dynamically create the user confirmation dialog
	var confirm_dlg = ConfirmationDialog.new()
	confirm_dlg.name = "remove_confirm_dialog"
	confirm_dlg.window_title = "Are You Sure?"
	confirm_dlg.dialog_text = "Really remove this item?"
	var ok_btn = confirm_dlg.get_ok()
	ok_btn.text = "Yes"
	var cancel_btn = confirm_dlg.get_cancel()
	cancel_btn.text = "No"
	confirm_dlg.connect("confirmed", self, "_remove_confirmed")
	add_child(confirm_dlg)
	confirm_dlg.show()
	confirm_dlg.popup_centered()

	# We do not need the popup menu anymore
	var data_popup = $DataPopupPanel
	data_popup.hide()


"""
Called when the user has confirmed that they really do want to remove an
item from one of the trees.
"""
func _remove_confirmed():
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

	# Render any changes to the component tree
	self._execute_and_render()


"""
The user clicked the Edit tree menu item.
"""
func _edit_tree_item():
	# Get the selected item
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var sel = ct.get_selected()
	var sel_text = ""
	if sel:
		sel_text = sel.get_text(0)
	else:
		return

	# We do not need the popup menu anymore
	var data_popup = $DataPopupPanel
	data_popup.hide()

	# Get the text that will tell the Operations dialog what might come next
	var prev_text = Common.get_last_op(ct)
	if not prev_text:
		prev_text = _convert_component_tree_to_script(false)

	# Get the component names that are in the component tree
	var comp_names = Common.get_all_components(ct)
	var params = _get_parameter_items()

	var op_panel = $ActionPopupPanel

	# If the selected item starts with a period, it is an operation item
	if sel_text.begins_with("."):
		edit_mode = true

		op_panel.activate_edit_mode(prev_text, sel_text, comp_names, params)
	else:
		var edit_child = ct.get_selected().get_children()

		# Check to see if this is a binary operation
		if edit_child == null:
			edit_child = ct.get_selected()

		edit_mode = true
		edit_child.select(0)
		op_panel.activate_edit_mode(prev_text, edit_child.get_text(0), comp_names, params)


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
	var data_popup = $DataPopupPanel
	data_popup.hide()

	# Render any changes to the component tree
	self._execute_and_render()


"""
Called when the user right clicks on the Component tree.
"""
func _on_ComponentTree_activate_data_popup():
	var ct = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree
	var pos = ct.get_local_mouse_position()
	var size = Vector2(50, 100)

	var popup_height = 125

	# If there is nothing in the tree, do not display the menu
	if not ct.get_selected():
		return

	# Lets us know whether or not a component is selected
	var is_component = not ct.get_selected().get_text(0).begins_with(".")

	# If we are selecting a Component, there are some different options
	if is_component:
		popup_height = 150

	# Clear any previous items
	_clear_data_popup()

	# Toggle the visiblity of the popup
	var data_popup = $DataPopupPanel
	if data_popup.visible:
		data_popup.hide()
	else:
		data_popup.rect_position = Vector2(pos.x, pos.y + size.y)
		data_popup.rect_size = Vector2(100, popup_height)
		data_popup.show()

	# Add the Add component/operation item
	var add_item = Button.new()
	add_item.set_text("Add")
	add_item.connect("button_down", self, "_add_tree_item")
	$DataPopupPanel/DataPopupVBox.add_child(add_item)

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

		# Add the Color/Alpha button
		var color_alpha_item = Button.new()
		color_alpha_item.set_text("Color/Alpha")
		color_alpha_item.connect("button_down", self, "_set_component_color_alpha")
		$DataPopupPanel/DataPopupVBox.add_child(color_alpha_item)
	else:
		# Add the Insert Above item to insert an operation entry before the selected one
		var insert_item = Button.new()
		insert_item.set_text("Insert Above")
		insert_item.connect("button_down", self, "_insert_tree_item")
		$DataPopupPanel/DataPopupVBox.add_child(insert_item)

	# Add the Cancel item
	var cancel_item = Button.new()
	cancel_item.set_text("Cancel")
	cancel_item.connect("button_down", self, "_cancel_data_popup")
	$DataPopupPanel/DataPopupVBox.add_child(cancel_item)


"""
Displays a color/alpha picker for a component.
"""
func _set_component_color_alpha():
	# Show the color picker dialog
	var cp = get_node("ColorPickerDialog")
	var ct = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# Get the selected item and make sure it is valid
	var sel = ct.get_selected()
	if not sel:
		return

	# Get the metadata from the selected component
	var meta = sel.get_metadata(0)

	# If the color metadata exists, set it for the component
	if meta and meta.has("color_r"):
		cp.set_color_rgba(meta["color_r"], meta["color_g"], meta["color_b"], meta["color_a"])
	else:
		cp.set_color_rgba(1.0, 0.36, 0.05, 1.0)

	cp.popup_centered()

	# There is no need to display the data popup panel right now
	var data_popup = $DataPopupPanel
	data_popup.hide()


"""
Start a new parameter item.
"""
func _new_param_tree_item():
	var tree = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree

	# Collect any existing items from the parameters tree for safety checks
	var items = _collect_param_tree_pairs(tree)
	var param_dlg = $AddParameterDialog
	param_dlg.set_existing_parameters(items)

	param_dlg.popup_centered()

	# We do not need the popup menu anymore
	var data_popup = $DataPopupPanel
	data_popup.hide()


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
	var data_popup = $DataPopupPanel
	data_popup.hide()

	# Render any changes to the component tree
	self._execute_and_render()


"""
Handles the right click menu for the parameters tree.
"""
func _on_ParametersTree_activate_data_popup():
	var pt = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ParametersTree
	var global_pos = pt.get_global_mouse_position()

	var popup_height = 100

	# Clear any previous items
	_clear_data_popup()

	# Toggle the visiblity of the popup
	var data_popup = $DataPopupPanel
	if data_popup.visible:
		data_popup.hide()
	else:
		data_popup.rect_position = Vector2(global_pos.x, global_pos.y)
		data_popup.rect_size = Vector2(100, popup_height)
		data_popup.show()

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


"""
Signal fired when the user has chosen a color from the color
picker dialog and clicked OK.
"""
func _on_ColorPickerDialog_ok_pressed(picked_color):
	var ct = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Data/ComponentTree")

	# Get the selected item and make sure it is valid
	var sel = ct.get_selected()
	if not sel:
		return

	# Get the metadata from the selected component
	var meta = sel.get_metadata(0)
	var meta_dict = Dictionary()

	# Use the dictionary that is already there, if it exists
	if meta:
		meta_dict = meta

	# Save the picked color components
	meta_dict["color_r"] = picked_color.r
	meta_dict["color_g"] = picked_color.g
	meta_dict["color_b"] = picked_color.b
	meta_dict["color_a"] = picked_color.a

	# Reset the metadata for the component
	sel.set_metadata(0, meta_dict)

	self._execute_and_render()


"""
Called when a user says they do not want to save the changes to the current
component.
"""
func _on_SaveBeforeCloseDialog_no_save_before_close():
	var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs

	# Remove the asterisk marking that the component is not dirty
	tabs.set_tab_title(0, tabs.get_tab_title(0).replace(" *", ""))

	# Re-call the close code
	_on_CloseButton_button_down()

	# See if we should exit the entire app
	if quit_after_save:
		get_tree().quit()


"""
Called when the user says they want to save the changes to the current component.
"""
func _on_SaveBeforeCloseDialog_yes_save_before_close():
	# Go ahead and save the component
	_save_component()

	# Re-call the close code
	_on_CloseButton_button_down()


"""
Handle application quit requests to make sure dirty components get saved.
"""
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		var tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs

		# See if there is a need to save the current component first
		if tabs.get_tab_title(0).find("*") > 0:
			var cd = get_node("SaveBeforeCloseDialog")
			cd.popup_centered()

			quit_after_save = true

			return
		else:
			get_tree().quit() # default behavior
