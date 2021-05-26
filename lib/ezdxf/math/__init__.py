# Copyright (c) 2010-2020, Manfred Moitzi
# License: MIT License
from typing import Union, Sequence
# Import base types as C-extensions if available else as pure Python
# implementations:
from ._ctypes import (
    Vec3, Vec2, X_AXIS, Y_AXIS, Z_AXIS, NULLVEC, distance, lerp, Vector,
    Matrix44, Bezier4P, cubic_bezier_arc_parameters, cubic_bezier_from_arc,
    cubic_bezier_from_ellipse, has_clockwise_orientation,
    intersection_line_line_2d, intersection_ray_ray_3d, arc_angle_span_deg
)

from ._bezier3p import Bezier3P

from .construct2d import (
    is_close_points, closest_point, convex_hull_2d,
    distance_point_line_2d, is_point_on_line_2d, is_point_in_polygon_2d,
    is_point_left_of_line, point_to_line_relation, linspace, enclosing_angles,
    reflect_angle_x_deg, reflect_angle_y_deg, sign, area
)
from .construct3d import (
    is_planar_face, subdivide_face, subdivide_ngons, Plane, LocationState,
    normal_vector_3p, distance_point_line_3d,
)
from .linalg import (
    Matrix, LUDecomposition, gauss_jordan_inverse, gauss_jordan_solver,
    gauss_vector_solver, gauss_matrix_solver, freeze_matrix,
    tridiagonal_matrix_solver, tridiagonal_vector_solver, detect_banded_matrix,
    compact_banded_matrix, BandedMatrixLU, banded_matrix,
)
from .parametrize import estimate_tangents, estimate_end_tangent_magnitude
from .bspline import (
    fit_points_to_cad_cv, global_bspline_interpolation,
    rational_spline_from_arc, rational_spline_from_ellipse,
    uniform_knot_vector, open_uniform_knot_vector, required_knot_values,
    BSpline, BSplineU, BSplineClosed, local_cubic_bspline_interpolation,
    required_fit_points, required_control_points,
)
from .bezier import Bezier
from .bezier4p import (
    cubic_bezier_interpolation, tangents_cubic_bezier_interpolation
)
from .surfaces import BezierSurface
from .eulerspiral import EulerSpiral
from .ucs import OCS, UCS, PassTroughUCS
from .bulge import (
    bulge_to_arc, bulge_3_points, bulge_center, bulge_radius, arc_to_bulge,
)
from .arc import (
    ConstructionArc, arc_segment_count, arc_chord_length
)
from .line import ConstructionRay, ConstructionLine, ParallelRaysError
from .circle import ConstructionCircle
from .ellipse import (
    ConstructionEllipse, angle_to_param, param_to_angle, rytz_axis_construction,
    ellipse_param_span
)
from .box import ConstructionBox
from .shape import Shape2d
from .bbox import BoundingBox2d, BoundingBox
from .offset2d import offset_vertices_2d
from .transformtools import NonUniformScalingError, InsertTransformationError
from .curvetools import (
    quadratic_to_cubic_bezier, bezier_to_bspline,
    have_bezier_curves_g1_continuity, AnyBezier
)

Vertex = Union[Sequence[float], Vec3, Vec2]
VecXY = Union[Vec2, Vec3]  # Vector with x and y attributes


def xround(value: float, rounding: float = 0.) -> float:
    """
    Extended rounding function, argument `rounding` defines the rounding limit:

    ======= ======================================
    0       remove fraction
    0.1     round next to x.1, x.2, ... x.0
    0.25    round next to x.25, x.50, x.75 or x.00
    0.5     round next to x.5 or x.0
    1.0     round to a multiple of 1: remove fraction
    2.0     round to a multiple of 2: xxx2, xxx4, xxx6 ...
    5.0     round to a multiple of 5: xxx5 or xxx0
    10.0    round to a multiple of 10: xx10, xx20, ...
    ======= ======================================

    Args:
        value: float value to round
        rounding: rounding limit

    """
    if rounding == 0:
        return round(value)
    factor = 1. / rounding
    return round(value * factor) / factor
