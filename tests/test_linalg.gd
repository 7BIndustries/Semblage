extends "res://addons/gut/test.gd"

var linalg = load("res://LinAlg.gd")

"""
Tests the capability of finding the distance between two given vertices (edge length).
"""
func test_dist_between_vecs():
    var dist = linalg.dist_between_vecs(Vector3(0, 0, 0), Vector3(0, 0, 1))

    assert_eq(dist, 1.0)

"""
Tests the capability of finding the distance between two given vertices (edge length)
with non-even vectors`.
"""
func test_dist_between_vecs_uneven():
    var dist = linalg.dist_between_vecs(Vector3(0.2, 0.3, 0.4), Vector3(1.0, 2.22, 3.33))

    assert_almost_eq(dist, 3.59, 0.1)

"""
Tests the capability of finding a basis based on a normal.
"""
func test_find_basis():
    var basis = linalg.find_basis(Vector3(0, 0, 1))

    assert_eq(basis.x, Vector3(1, 1, 0))
    assert_eq(basis.y, Vector3(1, 0, 0))
    assert_eq(basis.z, Vector3(0, 0, 1))
