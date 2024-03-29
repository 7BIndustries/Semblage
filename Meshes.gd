extends Reference

class_name Meshes


"""
Creates the placeholder workplane mesh to show the user what the workplane
and its normal looks like.
"""
static func gen_workplane_meshes(origin, normal, size):
	var meshes = []

	# Get the new material color
	var new_color = Color(0.6, 0.6, 0.6, 0.1)
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
	var norm_color = Color(0.6, 0.7, 0.8, 0.1)
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

	# Scale the workplane normal mesh correctly
	var norm_len = size / 2.5
	var norm_base = size * 0.05
	
	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, norm_len))
	st.add_vertex(Vector3(-norm_base, norm_base, 0.0))
	st.add_vertex(Vector3(norm_base, norm_base, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, norm_len))
	st.add_vertex(Vector3(norm_base, norm_base, 0.0))
	st.add_vertex(Vector3(norm_base, -norm_base, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, norm_len))
	st.add_vertex(Vector3(norm_base, -norm_base, 0.0))
	st.add_vertex(Vector3(-norm_base, -norm_base, 0.0))

	# Add norm triangle
	st.add_vertex(Vector3(0.0, 0.0, norm_len))
	st.add_vertex(Vector3(-norm_base, -norm_base, 0.0))
	st.add_vertex(Vector3(-norm_base, norm_base, 0.0))

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
Generates each face of an object as a separate mesh so that they can be selected
separately.
"""
static func gen_component_meshes(component):
	var meshes = []

	var new_color = [1.0, 0.36, 0.05, 1.0]

	# Get the new material color
	if component.has("rgba"):
		new_color = component["rgba"]

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

	for face in component["faces"]:
		# Set the SurfaceTool up to build a new mesh
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_material(material)

		# Step through the triangles and add them to the mesh
		for tri in component["faces"][face]["triangles"]:
			# Wind the triangles in the opposite direction so that they are visible
			st.add_vertex(Vector3(tri["vertex_3"][0], tri["vertex_3"][1], tri["vertex_3"][2]))
			st.add_vertex(Vector3(tri["vertex_2"][0], tri["vertex_2"][1], tri["vertex_2"][2]))
			st.add_vertex(Vector3(tri["vertex_1"][0], tri["vertex_1"][1], tri["vertex_1"][2]))

		# Finish the mesh and attach it to a MeshInstance
		st.generate_normals()
		var mesh = st.commit()
		var mesh_inst = MeshInstance.new()
		mesh_inst.set_meta("parent_perm_id", face)
		mesh_inst.set_meta("is_planar", component["faces"][face]["is_planar"])
		var norm = component["faces"][face]["normal"]
		var orig = component["faces"][face]["origin"]
		mesh_inst.set_meta("normal", Vector3(norm[0], norm[1], norm[2]))
		mesh_inst.set_meta("origin", Vector3(orig[0], orig[1], orig[2]))
		mesh_inst.mesh = mesh

		meshes.append(mesh_inst)

	return meshes


"""
Generates a cube mesh that represents a line/edge in the 3D view.
"""
static func gen_line_mesh(thickness, segment, edge_perm_id, edge_type, start_vertex, end_vertex, normal):
	var new_color = [1.0, 1.0, 1.0, 1.0]

	var material = SpatialMaterial.new()
	material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])

	# Enable/disable transparency based on the alpha set by the user
	if new_color[3] == 1.0:
		material.flags_transparent = false
	else:
		material.flags_transparent = true

	# Extract the start and endpoint vectors from the segment
	var v1 = segment["vertex_1"]
	var v2 = segment["vertex_2"]

	# Calculate the length of the segment
	var dist = LinAlg.dist_between_vecs(v1, v2)

	# The endpoints compensating for the fact the that center is in the middle of the bar, not the end
	var v_mid = Vector3((v1[0] + v2[0]) / 2.0, (v1[1] + v2[1]) / 2.0, (v1[2] + v2[2]) / 2.0)

	# Generate the mesh instance representing the line
	var mesh_inst = MeshInstance.new()
	mesh_inst.set_meta("parent_perm_id", edge_perm_id)
	mesh_inst.set_meta("edge_type", edge_type)
	mesh_inst.set_meta("start_vertex", start_vertex)
	mesh_inst.set_meta("end_vertex", end_vertex)
	if edge_type != "LINE":
		mesh_inst.set_meta("normal", Vector3(normal[0], normal[1], normal[2]))
		mesh_inst.set_meta("origin", Vector3(start_vertex[0], start_vertex[1], start_vertex[2]))

	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(thickness, thickness, dist)
	mesh_inst.mesh = raw_cube_mesh
	mesh_inst.set_surface_material(0, material)
	mesh_inst.transform.origin = v_mid

	# For edges centered at the origin in two axes, the cross product will be
	# (0, 0, 0), so we need to correct for that or an edge will be oriented wrong.
	var v_cross = v1.cross(v2)
	if v_cross == Vector3(0, 0, 0):
		v_cross = Vector3(0, 0, 1)

	mesh_inst.transform = mesh_inst.transform.looking_at(v2, v_cross)

	return mesh_inst


"""
Generates meshes that represent vertices.
"""
static func gen_vertex_mesh(size, vertex, vertex_perm_id):
	var new_color = [1.0, 1.0, 1.0, 1.0]

	var material = SpatialMaterial.new()
	material.albedo_color = Color(new_color[0], new_color[1], new_color[2], new_color[3])

	# Enable/disable transparency based on the alpha set by the user
	if new_color[3] == 1.0:
		material.flags_transparent = false
	else:
		material.flags_transparent = true

	# Generate the mesh instance representing the line
	var mesh_inst = MeshInstance.new()
	mesh_inst.set_meta("parent_perm_id", vertex_perm_id)
	var raw_cube_mesh = CubeMesh.new()
	raw_cube_mesh.size = Vector3(size, size, size)
	mesh_inst.mesh = raw_cube_mesh
	mesh_inst.set_surface_material(0, material)
	mesh_inst.transform.origin = Vector3(vertex["X"], vertex["Y"], vertex["Z"])

	return mesh_inst
