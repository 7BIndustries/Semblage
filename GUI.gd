extends Control

var open_file_path
var component_text
var cam
var largest_dim = 0 # Largest dimension of any component that is loaded
var safe_distance = largest_dim * 1.5 # The distance away the camera should be placed to be able to view the components
var status # The status bar that keeps the user appraised of what is going on
var cur_temp_file # The path to the current temp file
var cur_error_file # The path to the current error file, if needed
var executing = false # Whether or not a script is currently executing

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the default tab to let the user know where to start
	$GUI/VBoxContainer/WorkArea/DocumentTabs.set_tab_title(0, "Start *")

	cam = $"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport/CADLikeOrbit_Camera"

	# Let the user know the app is ready to use
	status = $GUI/VBoxContainer/StatusBar/Panel/HBoxContainer/StatusLabel
	status.text = " Ready"

"""
Used to do things like check if a semb process is generating a component.
"""
func _process(delta):
	# Error file handling
	if cur_error_file != null:
		var cur_file = File.new()

		# If we are executing and there is an error file, display the error
		if executing && cur_file.file_exists(cur_error_file):
			cur_file.open(cur_error_file, File.READ)
			executing = false

			# Load the JSON from the file
			var error_string = cur_file.get_as_text()

			$ErrorDialog.dialog_text = error_string
			$ErrorDialog.show_modal()

			# Remove the current temp file since we no longer need it
			var array = [cur_temp_file, cur_error_file]
			var args = PoolStringArray(array)
			OS.execute("rm", args, false)
			cur_temp_file = null
			cur_error_file = false

			status.text = " Generation Error"

	# JSON file handling
	if cur_temp_file != null:
		var cur_file = File.new()

		# If we are executing and the file exists, process it
		if executing && cur_file.file_exists(cur_temp_file):
			cur_file.open(cur_temp_file, File.READ)
			executing = false

			# Load the JSON from the file
			var json_string = cur_file.get_as_text()
			load_component_json(json_string)

			# Remove the current temp file since we no longer need it
			var array = [cur_temp_file]
			var args = PoolStringArray(array)
			OS.execute("rm", args, false)
			cur_temp_file = null

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

	# Construct the directory where the temporary JSON file can be written
	cur_temp_file = OS.get_user_data_dir() + "/temp_1.json"
	cur_error_file = OS.get_user_data_dir() + "/error_1.txt"
	
	# Temporary location and name of the file to convert
	var array = [path, cur_temp_file, cur_error_file]
	var args = PoolStringArray(array)
	
	# Execute the render script
	OS.execute("/home/jwright/Downloads/repos/semb/semb.py", args, false)
	executing = true

	status.text = "Generating component..."

"""
Loads a generated component into a mesh.
"""
func load_component_json(json_string):
	status.text = "Redering component"

	var component_json = JSON.parse(json_string).result

	for component in component_json["components"]:
		# If we've found a larger dimension, save the safe distance, which is the largest dimension of any component
		var dim = component["largestDim"]
		if dim > largest_dim:
			largest_dim = dim
			safe_distance = largest_dim * 1.5

		# Set the material color
		var material = SpatialMaterial.new()
		material.albedo_color = Color(0.3, 0.3, 0.0)

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
		
		# Finish the mesh and attach it to a MeshInstance
		st.generate_normals()
		var mesh = st.commit()
		var mesh_inst = MeshInstance.new()
		mesh_inst.mesh = mesh

		# Add the mesh instance to the viewport
		$"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport".add_child(mesh_inst)

		# Set the camera to the safe distance and have it look at the origin
		cam.look_at_from_position(Vector3(safe_distance, safe_distance, safe_distance), Vector3(0, 0, 0), Vector3(0, 1, 0))
	
		print(component)

		status.text = "Redering component...done."

"""
Handler that is called when the user clicks the button for the home view.
"""
func _on_HomeViewButton_button_down():
	# Set the camera to the safe distance and have it look at the origin
		cam.look_at_from_position(Vector3(safe_distance, safe_distance, safe_distance), Vector3(0, 0, 0), Vector3(0, 1, 0))

"""
Handler that is called when the user clicks the button to close the current component/view.
"""
func _on_CloseButton_button_down():
	clear_viewport()

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
