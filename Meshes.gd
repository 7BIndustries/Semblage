extends Reference

class_name Meshes


"""
Creates the placeholder workplane mesh to show the user what the workplane
and its normal looks like.
"""
static func gen_workplane_meshes(origin, normal, size):
	var meshes = []

	# Get the new material color
	var new_color = Color(0.6, 0.6, 0.6, 0.01)
	var material = SpatialMaterial.new()
	material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])
	material.flags_transparent = true

	# Set up the workplane mesh
	var wp_mesh = MeshInstance.new()
	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(size, size, 0.01)
	wp_mesh.material_override = material
	wp_mesh.mesh = raw_cube_mesh
	wp_mesh.transform.origin = origin
	wp_mesh.transform.basis = LinAlg.find_basis(normal)

	# Get the new material color
	var norm_color = Color(1.0, 1.0, 1.0, 0.01)
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
	norm_mesh.transform.basis = LinAlg.find_basis(normal)

	# Save the normal mesh instance to return
	meshes.append(wp_mesh)
	meshes.append(norm_mesh)

	return meshes


"""
Newer method of component mesh generation.
"""
static func gen_component_mesh(component):
	# Get the new material color
	var new_color = [1.0, 0.36, 0.05, 1.0] # component["color"]
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
	for n in range(0, component["num_of_triangles"] * 3, 3):
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

	# Return the finished mesh instance to the caller
	return mesh_inst


"""
Generates a cube mesh that represents a line/edge/wire in the 3D view.
"""
static func gen_line_mesh(thickness, edge):
	var material = SpatialMaterial.new()
	material.albedo_color = Color(255, 255, 255, 255)

	# Extract the start and endpoint vectors from the edge
	var v1 = edge[0] # Vector3(edge[0], edge[1], edge[2])
	var v2 = edge[1] # Vector3(edge[3], edge[4], edge[5])

	# Calculate the length of the edge
	var dist = LinAlg.dist_between_vecs(v1, v2)

	# The endpoints compensating for the fact the that center is in the middle of the bar, not the end
	var v_mid = Vector3((v1[0] + v2[0]) / 2.0, (v1[1] + v2[1]) / 2.0, (v1[2] + v2[2]) / 2.0)

	# Generate the mesh instance representing the line
	var wp_mesh = MeshInstance.new()
	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(thickness, thickness, dist)
	wp_mesh.material_override = material
	wp_mesh.mesh = raw_cube_mesh
	wp_mesh.transform.origin = v_mid

	# For edges centered at the origin in two axes, the cross product will be
	# (0, 0, 0), so we need to correct for that or an edge will be oriented wrong.
	var v_cross = v1.cross(v2)
	if v_cross == Vector3(0, 0, 0):
		v_cross = Vector3(0, 0, 1)

	wp_mesh.transform = wp_mesh.transform.looking_at(v2, v_cross)

	return wp_mesh
