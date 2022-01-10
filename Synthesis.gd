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
