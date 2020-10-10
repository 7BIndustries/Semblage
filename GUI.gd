extends Control

var open_file_path
var component_text
var cam
var max_dim = 0 # Largest dimension of any component that is loaded
var max_dist = 0 # Maximum distance away from the origin any vertex is
var safe_distance = max_dim * 1.5 # The distance away the camera should be placed to be able to view the components
var status # The status bar that keeps the user appraised of what is going on
var cur_temp_file # The path to the current temp file
var cur_error_file # The path to the current error file, if needed
var executing = false # Whether or not a script is currently executing
var home_transform # Allows us to move the camera back to the starting location/rotation/etc
var vp # The 3D viewport
var tabs # The tab container for component documents

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = $"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport/CADLikeOrbit_Camera"
	vp = $"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport"
	tabs = $"GUI/VBoxContainer/WorkArea/DocumentTabs"

	# Set the default tab to let the user know where to start
	tabs.set_tab_title(0, "Start")

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
			
			if error_string.ends_with("semb_process_finished"):
				error_string = error_string.replace("semb_process_finished", "")

				$ErrorDialog.dialog_text = error_string
				$ErrorDialog.popup_centered()
	
				# Prevent us from entering this code block again
				cur_temp_file = null
				cur_error_file = null
	
				executing = false
				
				status.text = " Generation Error"

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
Handler for when the Open Component button is clicked.
"""
func _on_OpenButton_button_down():
	$OpenDialog.popup_centered()

"""
Handles rendering the user-selected file to the 3DView.
"""
func _on_OpenDialog_file_selected(path):
	# Clear the viewport for the next component that is loaded
	clear_viewport()

	# Save the open file path for use later
	open_file_path = path
	
	# Let the user know the name of the file they are trying to open
	tabs.set_tab_title(0, open_file_path)

	generate_component(open_file_path)

"""
Generates a component using the semb CLI, which returns JSON.
"""
func generate_component(path):
	# Create a random ID
#	var rand_id = str(rng.randi()) + "-" + str(rng.randi()) + "-" + str(rng.randi()) + "-" + str(rng.randi())
	# Get the date and time and use it to construct the unique file id
	var date_time = OS.get_datetime()
	var file_id = str(date_time["year"]) + "_" +  str(date_time["month"]) + "_" + str(date_time["day"]) + "_" + str(date_time["hour"]) + "_" + str(date_time["minute"]) + "_" + str(date_time["second"])

	# Construct the directory where the temporary JSON file can be written
	cur_temp_file = OS.get_user_data_dir() + "/temp_" + file_id + ".json"
	cur_error_file = OS.get_user_data_dir() + "/error_" + file_id + ".txt"
	
	# Temporary location and name of the file to convert
	var array = [path, cur_temp_file, cur_error_file]
	var args = PoolStringArray(array)
	
	# Execute the render script
	OS.execute("/home/jwright/Downloads/repos/semb/semb.py", args, false)
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
		$"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport".add_child(mesh_inst)
	
	# Find the safe distance for the camera based on the maximum distance of any vertex from the origin
	safe_distance = max_dist * 2.0 # get_safe_camera_distance(max_dist)
	
	# Set the camera to the safe distance and have it look at the origin
	cam.look_at_from_position(Vector3(0, 0, safe_distance), Vector3(0, 0, 0), Vector3(0, 1, 0))
	
	# Save this transform as the home transform
	home_transform = cam.get_transform()

	status.text = "Redering component...done."

"""
Handler that is called when the user clicks the button for the home view.
"""
func _on_HomeViewButton_button_down():
	# Reset the tranform for the camera back to the one we saved when the scene loaded
	if home_transform != null: cam.transform = home_transform

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

	clear_viewport()

"""
Handles the event of the user pressing the Reload button to reload a component 
from file.
"""
func _on_ReloadButton_button_down():
	clear_viewport()
	
	generate_component(open_file_path)

"""
Removes all MeshInstances from a viewport to prepare for something new to be loaded.
"""
func clear_viewport():
	# Grab the viewport and its children
	var vp = $"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport"
	var children = vp.get_children()

	# Remove any child that is not the camera, assuming everything else is a MeshInstance
	for child in children:
		if child.get_name() != "CADLikeOrbit_Camera":
			vp.remove_child(child)
