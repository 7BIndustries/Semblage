extends Node

class_name Meshes


"""
Creates the placeholder workplane mesh to show the user what the workplane
and its normal looks like.
"""
static func gen_workplane_meshes(origin, normal):
	var meshes = []

	# Get the new material color
	var new_color = Color(0.6, 0.6, 0.6, 0.01)
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
	wp_mesh.transform.basis = LinAlg.find_basis(normal)

	# Save the mesh to return
	meshes.append(wp_mesh)

	# Add the mesh instance to the viewport
#	vp.add_child(wp_mesh)

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
Generates a manual mesh for a given component model.
"""
static func gen_component_mesh(component):
#	var max_dist = 0

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
#		if verts1[0] > max_dist: max_dist = verts1[0]
#		if verts1[1] > max_dist: max_dist = verts1[1]
#		if verts1[2] > max_dist: max_dist = verts1[2]
#		if verts2[0] > max_dist: max_dist = verts2[0]
#		if verts2[1] > max_dist: max_dist = verts2[1]
#		if verts2[2] > max_dist: max_dist = verts2[2]
#		if verts3[0] > max_dist: max_dist = verts3[0]
#		if verts3[1] > max_dist: max_dist = verts3[1]
#		if verts3[2] > max_dist: max_dist = verts3[2]

	# Finish the mesh and attach it to a MeshInstance
	st.generate_normals()
	var mesh = st.commit()
	var mesh_inst = MeshInstance.new()
	mesh_inst.mesh = mesh

	# Return the finished mesh instance to the caller
	return mesh_inst

	# Add the mesh instance to the viewport
#	vp.add_child(mesh_inst)

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


static func gen_line_mesh(thickness, edge):
	var material = SpatialMaterial.new()
	material.albedo_color = Color(255, 255, 255, 255)

	# Extract the start and endpoint vectors from the edge
	var v1 = Vector3(edge[0], edge[1], edge[2])
	var v2 = Vector3(edge[3], edge[4], edge[5])

	# Calculate the length of the edge
	var dist = LinAlg.dist_between_vecs(v1, v2)

	# The endpoints compensating for the fact the that center is in the middle of the bar, not the end
	var v_mid = Vector3((edge[0] + edge[3]) / 2.0, (edge[1] + edge[4]) / 2.0, (edge[2] + edge[5]) / 2.0)

	# Generate the mesh instance representing the line
	var wp_mesh = MeshInstance.new()
	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(thickness, thickness, dist)
	wp_mesh.material_override = material
	wp_mesh.mesh = raw_cube_mesh
	wp_mesh.transform.origin = v_mid

	# Compensate for a cross product glitch with a zero vector if edge starts from origin
	var v1_offset = v1
	if v1.x == 0.0 and v1.y == 0.0 and v1.z == 0.0:
		v1_offset = Vector3(0.000000001, 0.000000001, 0.000000001)

	wp_mesh.transform = wp_mesh.transform.looking_at(v2, v1_offset.cross(v2))

	return wp_mesh
