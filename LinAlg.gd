extends Reference

class_name LinAlg

const FLOAT_EPSILON = 0.00001

"""
Compares two floats, compensating for floating point error.
"""
static func compare_floats(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon

"""
Finds the distance between two vectors.
"""
static func dist_between_vecs(v1, v2):
	var dx = pow((v2.x - v1.x), 2)
	var dy = pow((v2.y - v1.y), 2)
	var dz = pow((v2.z - v1.z), 2)

	var dist = sqrt(dx + dy + dz)

	return dist

"""
Find the basis for a 3D node based on a normal.
"""
static func find_basis(normal):
	var imin = 0
	for i in range(0, 3):
		if abs(normal[i]) < abs(normal[imin]):
			imin = i

	var v2 = Vector3(0, 0, 0)
	var dt = normal[imin]

	v2[imin] = 1
	for i in range(0, 3):
		v2[i] -= dt * normal[i];

	var v3 = normal.cross(v2)

	var basis = Basis()
	basis[0] = v3.normalized()
	basis[1] = v2.normalized()
	basis[2] = normal.normalized()

	return basis
