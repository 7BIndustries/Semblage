extends Control

var open_file_path
var component_text

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the default tab to let the user know where to start
	$GUI/VBoxContainer/WorkArea/DocumentTabs.set_tab_title(0, "Start *")

"""
Handler for when the Open Component button is clicked.
"""
func _on_OpenButton_button_down():
	$OpenDialog.popup_centered()

"""
Handles rendering the user-selected file to the 3DView.
"""
func _on_OpenDialog_file_selected(path):
	# Save the open file path for use later
	open_file_path = path
	
	# Read the contents of the file and render them
#	var file = File.new()
#	file.open(path, 1)
#	component_text = file.get_as_text()
#	print(component_text)
	
	# Temporary location and name of the file to convert
	var array = [path]
	var args = PoolStringArray(array)
	
	# Execute the render script 
	var stdout = []
	OS.execute("/home/jwright/Downloads/repos/semb/semb.py", args, true, stdout, true)
	
	var result_json = JSON.parse(stdout[0]).result

	for component in result_json["components"]:
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
	
		print(component)
