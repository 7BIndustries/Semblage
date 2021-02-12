extends Node

class_name LinAlg


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
