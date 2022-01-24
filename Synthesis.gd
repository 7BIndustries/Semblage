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
	var selected_origin = faces["selected_origins"][0]
	var selected_normal = faces["selected_normals"][0]

	var selector_str = '.faces("{modifier}{axis}{index}")'
	var axis_index = -1
	var axis_str = ""
	var modifier_str = ""
	var index_str = ""

	# Determine if the face's normal is aligned with any axis
	if is_parallel_to_x(selected_normal):
		axis_str = "X"
		axis_index = 0
	elif is_parallel_to_y(selected_normal):
		axis_str = "Y"
		axis_index = 1
	elif is_parallel_to_z(selected_normal):
		axis_str = "Z"
		axis_index = 2

	# Check to see if the selected face is aligned with an axis
	if axis_index > -1:
		# See if the face is either the minimum or maximum in this axis
		var min_max = find_min_max_in_axis(faces, selected_origin, selected_normal, axis_index)
		# Format the min/max filter
		if min_max[0] == true:
			modifier_str = "<"
		elif min_max[1] == true:
			modifier_str = ">"

		# Find out if we have an indexed max or min
		if min_max[2] != -1:
			index_str = "[" + str(min_max[2]) + "]"

		# If we did not find the axis and modifier, the selector string should be null
		if axis_str != "" and modifier_str != "":
			selector_str = selector_str.format({"axis": axis_str, "modifier": modifier_str, "index": index_str})
		else:
			selector_str = null
	else:
		# Let the user know a match was not found
		selector_str = null

	return selector_str


"""
Determines whether or not a face is the minimum or maximum along an axis, and
what the index is, if any.
"""
static func find_min_max_in_axis(faces, selected_origin, selected_normal, axis_index):
	var is_max = null
	var is_min = null
	var distances = []
	var dist_face_map = {}

	# Save the distance for the selected face
	distances.append(selected_origin[axis_index])

	var i = 0
	for face in faces["other_faces"]:
		# Check if the face normals are aligned
		if is_parallel(selected_normal, faces["other_normals"][i]):
			# Save the distance for the current face away from the origin
			distances.append(faces["other_origins"][i][axis_index])

			# Check to see if the face is the maximum along the axis
			if selected_origin[axis_index] > faces["other_origins"][i][axis_index]:
				# Keep from overriding other faces that were already more maximal
				if is_max == null:
					is_max = true
			else:
				is_max = false

			# Check to see if the face is the minimum along the axis
			if selected_origin[axis_index] < faces["other_origins"][i][axis_index]:
				# Keep from overriding other faces that were already more minimal
				if is_min == null:
					is_min = true
			else:
				is_min = false

		i += 1

	# If this is still null, then the face is not maximum
	if is_max == null:
		is_max = false
	# If this is still null, then the face is not minimum
	if is_min == null:
		is_min = false

	# Make sure tha the distances are sorted in order
	distances.sort()

	# Determine if the face is indexed min or max here
	var index = -1
	var idx = 0
	for dist in distances:
		# Skip the maximum and minimum faces since we do not need to add an index to them
		if idx == 0 or idx == distances.size() - 1:
			idx += 1
			continue

		# We have a matching index in the context of the other faces
		if selected_origin[axis_index] == dist:
			index = idx
			is_max = true

		idx += 1

	return [is_min, is_max, index]


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
