# Copyright (c) 2018-2020 Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, Tuple, Iterable
import math

from ezdxf.math import Vec2
from .bbox import BoundingBox2d
from .construct2d import enclosing_angles, linspace
from .circle import ConstructionCircle
from .ucs import UCS

if TYPE_CHECKING:
    from ezdxf.eztypes import Vertex, BaseLayout, Arc

__all__ = ['ConstructionArc', 'arc_chord_length', 'arc_segment_count']

QUARTER_ANGLES = [0, math.pi * .5, math.pi, math.pi * 1.5]


class ConstructionArc:
    """ This is a helper class to create parameters for the DXF
    :class:`~ezdxf.entities.Arc` class.

    :class:`ConstructionArc` represents a 2D arc in the xy-plane, use an
    :class:`UCS` to place arc in 3D space, see method :meth:`add_to_layout`.

    Implements the 2D transformation tools: :meth:`translate`,
    :meth:`scale_uniform` and :meth:`rotate_z`

    Args:
        center: center point as :class:`Vec2` compatible object
        radius: radius
        start_angle: start angle in degrees
        end_angle: end angle in degrees
        is_counter_clockwise: swaps start- and end angle if ``False``

    """

    def __init__(self,
                 center: 'Vertex' = (0, 0),
                 radius: float = 1,
                 start_angle: float = 0,
                 end_angle: float = 360,
                 is_counter_clockwise: bool = True):

        self.center = Vec2(center)
        self.radius = radius
        if is_counter_clockwise:
            self.start_angle = start_angle
            self.end_angle = end_angle
        else:
            self.start_angle = end_angle
            self.end_angle = start_angle

    @property
    def start_point(self) -> 'Vec2':
        """ start point of arc as :class:`Vec2`. """
        return self.center + Vec2.from_deg_angle(self.start_angle, self.radius)

    @property
    def end_point(self) -> 'Vec2':
        """ end point of arc as :class:`Vec2`. """
        return self.center + Vec2.from_deg_angle(self.end_angle, self.radius)

    @property
    def bounding_box(self) -> 'BoundingBox2d':
        """ bounding box of arc as :class:`BoundingBox2d`. """
        bbox = BoundingBox2d((self.start_point, self.end_point))
        bbox.extend(self.main_axis_points())
        return bbox

    def angles(self, num: int) -> Iterable[float]:
        """ Returns `num` angles from start- to end angle in degrees in counter
        clockwise order.

        All angles are normalized in the range from [0, 360).

        """
        if num < 2:
            raise ValueError('num >= 2')
        start = self.start_angle % 360
        stop = self.end_angle % 360
        if stop <= start:
            stop += 360
        for angle in linspace(start, stop, num=num, endpoint=True):
            yield angle % 360

    @property
    def angle_span(self) -> float:
        """ Returns angle span of arc from start- to end param. """
        end = self.end_angle
        if end < self.start_angle:
            end += 360.0
        return end - self.start_angle

    def vertices(self, a: Iterable[float]) -> Iterable[Vec2]:
        """ Yields vertices on arc for angles in iterable `a` in WCS as location
        vectors.

        Args:
            a: angles in the range from 0 to 360 in degrees, arc goes
                counter clockwise around the z-axis, WCS x-axis = 0 deg.

        """
        center = self.center
        radius = self.radius

        for angle in a:
            yield center + Vec2.from_deg_angle(angle, radius)

    def flattening(self, sagitta: float) -> Iterable[Vec2]:
        """ Approximate the arc by vertices in WCS, argument `segment` is the
        max. distance from the center of an arc segment to the center of its
        chord.

        .. versionadded:: 0.15

        """
        radius = abs(self.radius)
        if radius > 0:
            start = self.start_angle
            stop = self.end_angle
            if math.isclose(start, stop):
                return
            start %= 360
            stop %= 360
            if stop <= start:
                stop += 360
            angle_span = math.radians(stop - start)
            count = arc_segment_count(radius, angle_span, sagitta)
            yield from self.vertices(linspace(start, stop, count + 1))

    def tangents(self, a: Iterable[float]) -> Iterable[Vec2]:
        """ Yields tangents on arc for angles in iterable `a` in WCS as
        direction vectors.

        Args:
            a: angles in the range from 0 to 360 in degrees, arc goes counter
                clockwise around the z-axis, WCS x-axis = 0 deg.

        """
        for angle in a:
            r = math.radians(angle)
            yield Vec2((-math.sin(r), math.cos(r)))

    def main_axis_points(self):
        center = self.center
        radius = self.radius
        start = math.radians(self.start_angle)
        end = math.radians(self.end_angle)
        for angle in QUARTER_ANGLES:
            if enclosing_angles(angle, start, end):
                yield center + Vec2.from_angle(angle, radius)

    def translate(self, dx: float, dy: float) -> 'ConstructionArc':
        """ Move arc about `dx` in x-axis and about `dy` in y-axis, returns
        `self` (floating interface).

        Args:
            dx: translation in x-axis
            dy: translation in y-axis

        """
        self.center += Vec2((dx, dy))
        return self

    def scale_uniform(self, s: float) -> 'ConstructionArc':
        """ Scale arc inplace uniform about `s` in x- and y-axis, returns
        `self` (floating interface).
        """
        self.radius *= float(s)
        return self

    def rotate_z(self, angle: float) -> 'ConstructionArc':
        """ Rotate arc inplace about z-axis, returns `self`
        (floating interface).

        Args:
            angle: rotation angle in degrees

        """
        self.start_angle += angle
        self.end_angle += angle
        return self

    @property
    def start_angle_rad(self) -> float:
        """ Returns the start angle in radians. """
        return math.radians(self.start_angle)

    @property
    def end_angle_rad(self) -> float:
        """ Returns the end angle in radians. """
        return math.radians(self.end_angle)

    @staticmethod
    def validate_start_and_end_point(start_point: 'Vertex',
                                     end_point: 'Vertex') -> Tuple[Vec2, Vec2]:
        start_point = Vec2(start_point)
        end_point = Vec2(end_point)
        if start_point == end_point:
            raise ValueError(
                "Start- and end point have to be different points.")
        return start_point, end_point

    @classmethod
    def from_2p_angle(cls, start_point: 'Vertex', end_point: 'Vertex',
                      angle: float,
                      ccw: bool = True) -> 'ConstructionArc':
        """ Create arc from two points and enclosing angle. Additional
        precondition: arc goes by default in counter clockwise orientation from
        `start_point` to `end_point`, can be changed by `ccw` = ``False``.

        Args:
            start_point: start point as :class:`Vec2` compatible object
            end_point: end point as :class:`Vec2` compatible object
            angle: enclosing angle in degrees
            ccw: counter clockwise direction if ``True``

        """
        start_point, end_point = cls.validate_start_and_end_point(start_point,
                                                                  end_point)
        angle = math.radians(angle)
        if angle == 0:
            raise ValueError("Angle can not be 0.")
        if ccw is False:
            start_point, end_point = end_point, start_point
        alpha2 = angle / 2.
        distance = end_point.distance(start_point)
        distance2 = distance / 2.
        radius = distance2 / math.sin(alpha2)
        height = distance2 / math.tan(alpha2)
        mid_point = end_point.lerp(start_point, factor=.5)

        distance_vector = end_point - start_point
        height_vector = distance_vector.orthogonal().normalize(height)
        center = mid_point + height_vector

        return ConstructionArc(
            center=center,
            radius=radius,
            start_angle=(start_point - center).angle_deg,
            end_angle=(end_point - center).angle_deg,
            is_counter_clockwise=True,
        )

    @classmethod
    def from_2p_radius(cls, start_point: 'Vertex', end_point: 'Vertex',
                       radius: float, ccw: bool = True,
                       center_is_left: bool = True) -> 'ConstructionArc':
        """ Create arc from two points and arc radius.
        Additional precondition: arc goes by default in counter clockwise
        orientation from `start_point` to `end_point` can be changed
        by `ccw` = ``False``.

        The parameter `center_is_left` defines if the center of the arc is
        left or right of the line from `start_point` to `end_point`.
        Parameter `ccw` = ``False`` swaps start- and end point, which also
        inverts the meaning of ``center_is_left``.

        Args:
            start_point: start point as :class:`Vec2` compatible object
            end_point: end point as :class:`Vec2` compatible object
            radius: arc radius
            ccw: counter clockwise direction if ``True``
            center_is_left: center point of arc is left of line from start- to
                end point if ``True``

        """
        start_point, end_point = cls.validate_start_and_end_point(
            start_point, end_point)
        radius = float(radius)
        if radius <= 0:
            raise ValueError("Radius has to be > 0.")
        if ccw is False:
            start_point, end_point = end_point, start_point

        mid_point = end_point.lerp(start_point, factor=.5)
        distance = end_point.distance(start_point)
        distance2 = distance / 2.
        height = math.sqrt(radius ** 2 - distance2 ** 2)
        center = mid_point + (end_point - start_point).orthogonal(
            ccw=center_is_left).normalize(height)

        return ConstructionArc(
            center=center,
            radius=radius,
            start_angle=(start_point - center).angle_deg,
            end_angle=(end_point - center).angle_deg,
            is_counter_clockwise=True,
        )

    @classmethod
    def from_3p(cls, start_point: 'Vertex', end_point: 'Vertex',
                def_point: 'Vertex',
                ccw: bool = True) -> 'ConstructionArc':
        """ Create arc from three points.
        Additional precondition: arc goes in counter clockwise
        orientation from `start_point` to `end_point`.

        Args:
            start_point: start point as :class:`Vec2` compatible object
            end_point: end point as :class:`Vec2` compatible object
            def_point: additional definition point as :class:`Vec2` compatible
                object
            ccw: counter clockwise direction if ``True``

        """
        start_point, end_point = cls.validate_start_and_end_point(
            start_point, end_point)
        def_point = Vec2(def_point)
        if def_point == start_point or def_point == end_point:
            raise ValueError(
                "def_point has to be different to start- and end point")

        circle = ConstructionCircle.from_3p(start_point, end_point, def_point)
        center = Vec2(circle.center)
        return ConstructionArc(
            center=center,
            radius=circle.radius,
            start_angle=(start_point - center).angle_deg,
            end_angle=(end_point - center).angle_deg,
            is_counter_clockwise=ccw,
        )

    def add_to_layout(self, layout: 'BaseLayout', ucs: UCS = None,
                      dxfattribs: dict = None) -> 'Arc':
        """ Add arc as DXF :class:`~ezdxf.entities.Arc` entity to a layout.

        Supports 3D arcs by using an :ref:`UCS`. An :class:`ConstructionArc` is
        always defined in the xy-plane, but by using an arbitrary UCS, the arc
        can be placed in 3D space, automatically OCS transformation included.

        Args:
            layout: destination layout as :class:`~ezdxf.layouts.BaseLayout`
                object
            ucs: place arc in 3D space by :class:`~ezdxf.math.UCS` object
            dxfattribs: additional DXF attributes for the DXF
                :class:`~ezdxf.entities.Arc` entity

        """
        arc = layout.add_arc(
            center=self.center,
            radius=self.radius,
            start_angle=self.start_angle,
            end_angle=self.end_angle,
            dxfattribs=dxfattribs,
        )
        return arc if ucs is None else arc.transform(ucs.matrix)


def arc_chord_length(radius: float, sagitta: float) -> float:
    """ Returns the chord length for an arc defined by `radius` and
    the `sagitta`_.

    Args:
        radius: arc radius
        sagitta: distance from the center of the arc to the center of its base

    .. versionadded:: 0.14

    """
    return 2.0 * math.sqrt(2.0 * radius * sagitta - sagitta * sagitta)


def arc_segment_count(radius: float, angle: float, sagitta: float) -> int:
    """ Returns the count of required segments for the approximation
    of an arc for a given maximum `sagitta`_.

    Args:
        radius: arc radius
        angle: angle span of the arc in radians
        sagitta: max. distance from the center of an arc segment to the
            center of its chord

    .. versionadded:: 0.14

    """
    chord_length = arc_chord_length(radius, sagitta)
    alpha = math.asin(chord_length / 2.0 / radius) * 2.0
    return math.ceil(angle / alpha)
