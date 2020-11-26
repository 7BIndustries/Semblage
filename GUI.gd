extends Control

var ContextHandler = load("res://ContextHandler.gd")

var open_file_path # The component/CQ file that the user opened
var component_text # The text of the current component's script
var max_dim = 0 # Largest dimension of any component that is loaded
var max_dist = 0 # Maximum distance away from the origin any vertex is
var safe_distance = max_dim * 1.5 # The distance away the camera should be placed to be able to view the components
var status # The status bar that keeps the user appraised of what is going on
var cur_temp_file # The path to the current temp file
var cur_error_file # The path to the current error file, if needed
var executing = false # Whether or not a script is currently executing
var home_transform # Allows us to move the camera back to the starting location/rotation/etc
var origin_transform # Allows us to move the orgin camera view back to a starting transform
var cam # The main camera for the 3D view
var origin_cam # The camera showing the orientation of the component(s) via an origin indicator
var vp # The 3D viewport
var tabs # The tab container for component documents
var context_handler # Handles the situation where the context Action menu needs to be populated
var object_tree_root = null
var history_tree_root = null

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/OriginViewportContainer/OriginViewport/OriginCamera
	cam = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport/CADLikeOrbit_Camera
	vp = $GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport
	tabs = $GUI/VBoxContainer/WorkArea/DocumentTabs
	
	origin_cam.zoom_enabled = false
	origin_cam.pan_enabled = false
	origin_cam.rotate_enabled = true

	# Set the default tab to let the user know where to start
	tabs.set_tab_title(0, "Start")

	# Start off with the base script text
	component_text = "import cadquery as cq\nresult=cq"

	# Instantiate the context handler which tells us what type of Action we are dealing with
	context_handler = ContextHandler.new()

	# Get the object and history trees ready to use
	_init_history_tree()
	_init_object_tree()

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

			# Prevent us from entering this code block again
			cur_temp_file = null
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
	if executing && cur_temp_file != null:
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

				cur_temp_file = null

				executing = false

			# Remove the current temp file since we no longer need it
#			var array = [cur_temp_file]
#			var args = PoolStringArray(array)
#			OS.execute("rm", args, false)

		cur_file.close()

"""
Handles user input, specifically the non-camera inputs like right-clicking for the 
action menu.
"""
func _input(event):
	match event.get_class():
		"InputEventMouseButton":
			# See if the user requested the action menu
			if Input.is_action_just_pressed("Action"):
				# Set the menu at the mouse cursor position
				var mouse_pos = get_viewport().get_mouse_position()

				$GUI/ActionPopupPanel.activate_popup(mouse_pos, component_text)


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
	component_text = load_component_file(open_file_path)

	generate_component(open_file_path)

"""
Loads the text of a file into a string to be manipulated by the GUI.
"""
func load_component_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	return text


"""
Mainly used to write the contents of the actions popup dialog to a temporary file
so that the result can be displayed.
"""
func _save_temp_component_file(path, component_text):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(component_text)
	file.close()


"""
Generates a component using the semb CLI, which returns JSON.
"""
func generate_component(path, component_text=null):
	# If component text has been passed, it have probably been modified from any file contents
	if component_text != null:
		# We want to write the component text to a temporary file and render the result of executing that
		var temp_component_path = OS.get_user_data_dir() + "/temp_component_path.py"
		
		# We append the show_object here so that it is not part of the context going forward
		_save_temp_component_file(temp_component_path, component_text + "\nshow_object(result)")
		
		# Switch path to pass that to cq-cli
		path = temp_component_path

	# Create a random ID
#	var rand_id = str(rng.randi()) + "-" + str(rng.randi()) + "-" + str(rng.randi()) + "-" + str(rng.randi())
	# Get the date and time and use it to construct the unique file id
	var date_time = OS.get_datetime()
	var file_id = str(date_time["year"]) + "_" +  str(date_time["month"]) + "_" + str(date_time["day"]) + "_" + str(date_time["hour"]) + "_" + str(date_time["minute"]) + "_" + str(date_time["second"])

	# Construct the directory where the temporary JSON file can be written
	cur_temp_file = OS.get_user_data_dir() + "/temp_" + file_id + ".json"
	cur_error_file = OS.get_user_data_dir() + "/error_" + file_id + ".txt"
	
	# Temporary location and name of the file to convert
	var array = ["--codec", "semb", "--infile", path, "--outfile", cur_temp_file, "--errfile", cur_error_file]
	var args = PoolStringArray(array)

	# Execute the render script
	OS.execute("/home/jwright/Downloads/repos/jmwright/cq-cli/cq-cli.py", args, false)
#	OS.execute("/home/jwright/Downloads/cq-cli-Linux/cq-cli/cq-cli", args, false)
	executing = true

	status.text = "Generating component..."

"""
Calculates the proper Y position to set the camera to fit a component or
assembly in the viewport.
"""
#func get_safe_camera_distance(max_dim):
#	var x = vp.get_visible_rect().size.x
#	var y = vp.get_visible_rect().size.y
#
#	var dist = max_dim / sin(PI / 180.0 * cam.fov * 0.5)
#
#	return dist

"""
Loads a generated component into a mesh.
"""
func load_component_json(json_string):
	status.text = "Redering component..."
	
	# Reset the maximum dimension so we do not save a larger one from a previous load
	max_dim = 0
	max_dist = 0

	var component_json = JSON.parse(json_string).result

	for component in component_json["components"]:
		# If we've found a larger dimension, save the safe distance, which is the maximum dimension of any component
		var dim = component["largestDim"]
		if dim > max_dim:
			max_dim = dim

			# Make sure the zoom speed works with the size of the model
			cam.ZOOMSPEED = 0.075 * max_dim

		# Get the new material color
		var new_color = component["color"]
		var material = SpatialMaterial.new()

		# The alpha is passed here, but alpha/transparency has to be enabled on the material too.
		# However, there are other things that need to be done to make sure transparency does
		# not cause artifacts
		material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])

		# Enable/disable transparency based on the alpha set by the user
		if new_color[3] == 1.0:
			material.flags_transparent = false
		else:
			material.flags_transparent = true

		# Set the SurfaceTool up to build a new mesh
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_material(material)

		# Loop through the triangles and add them all to the mesh
		for n in range(0, component["triangleCount"] * 3, 3):
			# Extract the triangle index values
			var t1 = component["triangles"][n]
			var t2 = component["triangles"][n + 1]
			var t3 = component["triangles"][n + 2]

			# Extract the verices in order from the vert collection
			var verts = component["vertices"]
			var verts1 = [verts[t1 * 3], verts[t1 * 3 + 1], verts[t1 * 3 + 2]]
			var verts2 = [verts[t2 * 3], verts[t2 * 3 + 1], verts[t2 * 3 + 2]]
			var verts3 = [verts[t3 * 3], verts[t3 * 3 + 1], verts[t3 * 3 + 2]]

			# Wind the triangles in the opposite direction so that they are visible
			st.add_vertex(Vector3(verts3[0], verts3[1], verts3[2]))
			st.add_vertex(Vector3(verts2[0], verts2[1], verts2[2]))
			st.add_vertex(Vector3(verts1[0], verts1[1], verts1[2]))
			
			# Grab any vertex that is the furthest away from the origin to help set the safe camera distance
			if verts1[0] > max_dist: max_dist = verts1[0]
			if verts1[1] > max_dist: max_dist = verts1[1]
			if verts1[2] > max_dist: max_dist = verts1[2]
			if verts2[0] > max_dist: max_dist = verts2[0]
			if verts2[1] > max_dist: max_dist = verts2[1]
			if verts2[2] > max_dist: max_dist = verts2[2]
			if verts3[0] > max_dist: max_dist = verts3[0]
			if verts3[1] > max_dist: max_dist = verts3[1]
			if verts3[2] > max_dist: max_dist = verts3[2]

		# Finish the mesh and attach it to a MeshInstance
		st.generate_normals()
		var mesh = st.commit()
		var mesh_inst = MeshInstance.new()
		mesh_inst.mesh = mesh

		# Add the mesh instance to the viewport
		vp.add_child(mesh_inst)

		# Handle the vertices
#		for v in component["cqVertices"]:
#			var newVert = CSGMesh.new()
#			newVert.name = "VertexCapsule"
#			newVert.mesh = SphereMesh.new()
#			# newVert.mesh.radius = 0.1
#			newVert.scale = Vector3(0.05, 0.05, 0.05)
#			newVert.mesh.material = SpatialMaterial.new()
#			newVert.mesh.material.albedo_color = Color(0.8, 0.8, 0.8)
#			newVert.set_translation(Vector3(v[0], v[1], v[2]))
#			vp.add_child(newVert)

	# Only reset the view if the same distance changed
	if (max_dist * 2.0) != safe_distance:
		# Find the safe distance for the camera based on the maximum distance of any vertex from the origin
		safe_distance = max_dist * 2.0 # get_safe_camera_distance(max_dist)

		# Set the camera to the safe distance and have it look at the origin
		cam.look_at_from_position(Vector3(0, safe_distance, 0), Vector3(0, 0, 0), Vector3(0, 0, 1))
		origin_cam.look_at_from_position(Vector3(0, 3, 0), Vector3(0, 0, 0), Vector3(0, 0, 1))

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

	# Make sure the new maximum dim takes effect next time
	max_dim = 0

	# Set the default tab name
	tabs.set_tab_title(0, "Start")
	
	open_file_path = null
	component_text = "import cadquery as cq\nresult=cq"

	self._clear_viewport()
	self._clear_history_tree()
	self._init_history_tree()


"""
Initializes the object tree so that it can be added to as the component changes.
"""
func _init_object_tree():
	var object_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/ObjectTree")

	# Create the root of the object tree
	self.object_tree_root = object_tree.create_item()
	self.object_tree_root.set_text(0, "Workspace")


"""
Initializes the history tree so that it can be added to as the component changes.
"""
func _init_history_tree():
	var history_tree = get_node("GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/HistoryTree")
	
	# Create the root of the history tree
	self.history_tree_root = history_tree.create_item()
	self.history_tree_root.set_text(0, "cq")


"""
Handles the event of the user pressing the Reload button to reload a component 
from file.
"""
func _on_ReloadButton_button_down():
	self._clear_viewport()
	self._clear_history_tree()

	generate_component(open_file_path)

"""
Removes all MeshInstances from a viewport to prepare for something new to be loaded.
"""
func _clear_viewport():
	# Grab the viewport and its children
	var children = vp.get_children()

	# Remove any child that is not the camera, assuming everything else is a MeshInstance
	for child in children:
		if child.get_name() != "CADLikeOrbit_Camera":
			vp.remove_child(child)


"""
Resets the history tree to prepare for the creation of a new CQ object.
"""
func _clear_history_tree():
	$GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/HistoryTree.clear()


"""
Retrieves the information on what is returned by the Actions panel and acts on them.
"""
func _on_ActionPopupPanel_preview_signal():
	self._clear_viewport()

	var untesses = context_handler.get_untessellateds($GUI/ActionPopupPanel.get_new_context())

	# If we have untessellated objects (i.e. workplanes), display placeholders for them
	if len(untesses) > 0:
		for untess in untesses:
			_make_wp_mesh(untess["origin"], untess["normal"])

	print($GUI/ActionPopupPanel.get_new_context())


"""
Retries the updated context and makes it the current one.
"""
func _on_ActionPopupPanel_ok_signal():
	self._clear_viewport()

	# If we have untessellated objects (i.e. workplanes), display placeholders for them
	var untesses = context_handler.get_untessellateds($GUI/ActionPopupPanel.get_new_context())
	if len(untesses) > 0:
		for untess in untesses:
			_make_wp_mesh(untess["origin"], untess["normal"])

	component_text = $GUI/ActionPopupPanel.get_new_context()

	var new_hist_item = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/HistoryTree.create_item(self.history_tree_root)
	new_hist_item.set_text(0, $GUI/ActionPopupPanel.get_latest_context_addition())

	generate_component(open_file_path, component_text)

	# Find any object name (if present) that needs to be displayed in the list
	var new_object = $GUI/ActionPopupPanel.get_latest_object_addition()
	if new_object:
		var ot = $GUI/VBoxContainer/WorkArea/TreeViewTabs/Structure/ObjectTree
		var new_obj_item = ot.create_item(self.object_tree_root)
		new_obj_item.set_text(0, new_object)


"""
Creates the placeholder workplane mesh to show the user what the workplane
and its normal looks like.
"""
func _make_wp_mesh(origin, normal):
	# Get the new material color
	var new_color = Color(0.6, 0.6, 0.6, 0.3)
	var material = SpatialMaterial.new()
	material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])
	material.flags_transparent = true

	# Set up the workplane mesh
	var wp_mesh = MeshInstance.new()
	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(5, 5, 0.01)
	wp_mesh.material_override = material
	wp_mesh.mesh = raw_cube_mesh
	wp_mesh.transform.origin = origin
	wp_mesh.transform.basis = _find_basis(normal)

	# Add the mesh instance to the viewport
	vp.add_child(wp_mesh)

	# Get the new material color
	var norm_color = Color(1.0, 1.0, 1.0, 0.5)
	var norm_mat = SpatialMaterial.new()
	norm_mat.albedo_color = Color(norm_color[0], norm_color[1], norm_color[2], norm_color[3])
	norm_mat.flags_transparent = true

	# Set up the normal mesh
	var norm_mesh = MeshInstance.new()
	norm_mesh.material_override = norm_mat

	# Set the SurfaceTool up to build a new mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(norm_mat)
	
	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, 1.0))
	st.add_vertex(Vector3(-0.1, 0.1, 0.0))
	st.add_vertex(Vector3(0.1, 0.1, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, 1.0))
	st.add_vertex(Vector3(0.1, 0.1, 0.0))
	st.add_vertex(Vector3(0.1, -0.1, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, 1.0))
	st.add_vertex(Vector3(0.1, -0.1, 0.0))
	st.add_vertex(Vector3(-0.1, -0.1, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, 1.0))
	st.add_vertex(Vector3(-0.1, -0.1, 0.0))
	st.add_vertex(Vector3(-0.1, 0.1, 0.0))

	# Finish the mesh and attach it to a MeshInstance
	st.generate_normals()
	var mesh = st.commit()
	norm_mesh.mesh = mesh

	norm_mesh.transform.origin = Vector3(origin[0], origin[1], origin[2])
	norm_mesh.transform.basis = _find_basis(normal)

	# Add the normal mesh instance to the viewport
	vp.add_child(norm_mesh)

"""
Find the basis for a 3D node based on a normal.
"""
func _find_basis(normal):
	var imin = 0
	for i in range(0, 3):
		if abs(normal[i]) < abs(normal[imin]):
			imin = i
	
	var v2 = Vector3(0, 0, 0)
	var dt = normal[imin]
	
	v2[imin] = 1
	for i in range(0, 3):
		v2[i] -= dt * normal[i];

	var v3 = normal.cross(v2)
	
	var basis = Basis()
	basis[0] = v3.normalized()
	basis[1] = v2.normalized()
	basis[2] = normal.normalized()
	
	return basis
