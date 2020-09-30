extends Control

var open_file_path
var component_text
var cam
var largest_dim = 0 # Largest dimension of any component that is loaded
var safe_distance = largest_dim * 1.5 # The distance away the camera should be placed to be able to view the components

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the default tab to let the user know where to start
	$GUI/VBoxContainer/WorkArea/DocumentTabs.set_tab_title(0, "Start *")

	cam = $"GUI/VBoxContainer/WorkArea/DocumentTabs/3DViewContainer/3DViewport/CADLikeOrbit_Camera"

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
	
	# Temporary location and name of the file to convert
	var array = [path]
	var args = PoolStringArray(array)
	
	# Execute the render script 
	var stdout = []
	OS.execute("/home/jwright/Downloads/repos/semb/semb.py", args, true, stdout, true)
	
	var result_json = JSON.parse(stdout[0]).result

	for component in result_json["components"]:
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
