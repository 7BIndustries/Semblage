extends Reference

class_name Synthesis

"""
Finds whether or not two vectors are parallel.
"""
static func is_parallel(vector_1, vector_2):
	# If the cross product is a zero vector, the vectors are parallel
	if vector_1.cross(vector_2) == Vector3(0.0, 0.0, 0.0):
		return true


"""
Finds whether or not two vectors are orthogonal.
"""
static func is_orthogonal(vector_1, vector_2):
	# if the dot product is zero, the vectors are orthogonal
	if vector_1.dot(vector_2) == 0:
		return true

	return false


"""
Check if a vector is parallel to the Z axis.
"""
static func is_parallel_to_z(vector):
	var z_vec = Vector3(0, 0, 1)

	return is_parallel(z_vec, vector)


"""
Check if a vector is parallel to the Y axis.
"""
static func is_parallel_to_y(vector):
	var y_vec = Vector3(0, 1, 0)

	return is_parallel(y_vec, vector)


"""
Check if a vector is parallel to the X axis.
"""
static func is_parallel_to_x(vector):
	var x_vec = Vector3(1, 0, 0)

	return is_parallel(x_vec, vector)


"""
Attempts to synthesize a selector string based on the information given.
"""
static func synthesize(faces):
	var selector_str = null

	# We handle a single selected face a certain way
	if faces["selected_faces"].size() == 1:
		selector_str = synthesize_max_min_face(faces)

	return selector_str


"""
Attempts to synthesize a maximum/minimum selelector string.
"""
static func synthesize_max_min_face(faces):
	var selector_str = null

	var selected_origin = faces["selected_origins"][0]
	var selected_normal = faces["selected_normals"][0]

	# Determine if the face's normal is aligned with any axis
	if is_parallel_to_x(selected_normal):
		# See if the given face is the maximum in the X direction
		if is_maximum_in_axis(faces, selected_origin, selected_normal, 0):
			selector_str = '.faces(">X")'
		elif is_minimum_in_axis(faces, selected_origin, selected_normal, 0):
			selector_str = '.faces("<X")'
	elif is_parallel_to_y(selected_normal):
		# See if the given face is the maximum in the X direction
		if is_maximum_in_axis(faces, selected_origin, selected_normal, 1):
			selector_str = '.faces(">Y")'
		elif is_minimum_in_axis(faces, selected_origin, selected_normal, 1):
			selector_str = '.faces("<Y")'
	elif is_parallel_to_z(selected_normal):
		# See if the given face is the maximum in the X direction
		if is_maximum_in_axis(faces, selected_origin, selected_normal, 2):
			selector_str = '.faces(">Z")'
		elif is_minimum_in_axis(faces, selected_origin, selected_normal, 2):
			selector_str = '.faces("<Z")'

	return selector_str


"""
Searches a list of faces to see if the given face is the maximum in a given
axis. axis_index 0 = X, 1 = Y, 2 = Z
"""
static func is_maximum_in_axis(faces, selected_origin, selected_normal, axis_index):
	var is_max = null

	var i = 0
	for face in faces["other_faces"]:
		# Check if the face normals are aligned
		if is_parallel(selected_normal, faces["other_normals"][i]):
			if selected_origin[axis_index] > faces["other_origins"][i][axis_index]:
				# Keep from overriding other faces that were already more maximal
				if is_max == null:
					is_max = true
			else:
				is_max = false

		i += 1

	# If this is still null, then the face is not maximum
	if is_max == null:
		is_max = false

	return is_max


"""
Searches a list of faces to see if the given face is the minimum in a given
axis. axis_index 0 = X, 1 = Y, 2 = Z
"""
static func is_minimum_in_axis(faces, selected_origin, selected_normal, axis_index):
	var is_min = null

	var i = 0
	for face in faces["other_faces"]:
		# Check if the face normals are aligned
		if is_parallel(selected_normal, faces["other_normals"][i]):
			if selected_origin[axis_index] < faces["other_origins"][i][axis_index]:
				# Keep from overriding other faces that were already more minimal
				if is_min == null:
					is_min = true
			else:
				is_min = false

		i += 1

	# If this is still null, then the face is not minimum
	if is_min == null:
		is_min = false

	return is_min
