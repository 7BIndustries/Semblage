# Copyright (c) 2019-2020, Manfred Moitzi
# License: MIT License
from typing import List, Sequence, TYPE_CHECKING, Iterable, Tuple
import math
from ezdxf.math import Vec2
from .bbox import BoundingBox2d
from .line import ConstructionLine
from .construct2d import point_to_line_relation

if TYPE_CHECKING:
    from ezdxf.eztypes import Vertex


class ConstructionBox:
    """
    Helper class to create rectangles.

    Args:
        center: center of rectangle
        width: width of rectangle
        height: height of rectangle
        angle: angle of rectangle in degrees

    """
    def __init__(self, center: 'Vertex' = (0, 0), width: float = 1, height: float = 1, angle: float = 0):
        self._center = Vec2(center)
        self._width = abs(width)  # type: float
        self._height = abs(height)  # type: float
        self._angle = angle  # type: float  # in degrees
        self._corners = None  # type: Tuple[Vec2, Vec2, Vec2, Vec2]
        self._tainted = True

    @classmethod
    def from_points(cls, p1: 'Vertex', p2: 'Vertex') -> 'ConstructionBox':
        """ Creates a box from two opposite corners, box sides are parallel to x- and y-axis.

        Args:
            p1: first corner as :class:`Vec2` compatible object
            p2: second corner as :class:`Vec2` compatible object

        """
        p1 = Vec2(p1)
        p2 = Vec2(p2)
        width = abs(p2.x - p1.x)
        height = abs(p2.y - p1.y)
        center = p1.lerp(p2)
        return cls(center=center, width=width, height=height)

    def update(self) -> None:
        if not self._tainted:
            return
        center = self.center
        w2 = Vec2.from_deg_angle(self._angle, self._width / 2.)
        h2 = Vec2.from_deg_angle(self._angle + 90, self._height / 2.)
        self._corners = (
            center - w2 - h2,  # lower left
            center + w2 - h2,  # lower right
            center + w2 + h2,  # upper right
            center - w2 + h2,  # upper left
        )
        self._tainted = False

    @property
    def bounding_box(self) -> BoundingBox2d:
        """ :class:`BoundingBox2d` """
        return BoundingBox2d(self.corners)

    @property
    def center(self) -> Vec2:
        """ box center """
        return self._center

    @center.setter
    def center(self, c: 'Vertex') -> None:
        self._center = Vec2(c)
        self._tainted = True

    @property
    def width(self) -> float:
        """ box width """
        return self._width

    @width.setter
    def width(self, w: float) -> None:
        self._width = abs(w)
        self._tainted = True

    @property
    def height(self) -> float:
        """ box height """
        return self._height

    @height.setter
    def height(self, h: float) -> None:
        self._height = abs(h)
        self._tainted = True

    @property
    def incircle_radius(self) -> float:
        """ incircle radius """
        return min(self._width, self._height) * .5

    @property
    def circumcircle_radius(self) -> float:
        """ circum circle radius"""
        return math.hypot(self._width, self._height) * .5

    @property
    def angle(self) -> float:
        """ rotation angle in degrees """
        return self._angle

    @angle.setter
    def angle(self, a: float) -> None:
        self._angle = a
        self._tainted = True

    @property
    def corners(self) -> Sequence[Vec2]:
        """ box corners as sequence of :class:`Vec2` objects. """
        self.update()
        return self._corners

    def __iter__(self) -> Iterable[Vec2]:
        """ Iterable of box corners as :class:`Vec2` objects. """
        return iter(self.corners)

    def __getitem__(self, corner) -> Vec2:
        """ Get corner by index `corner`, ``list`` like slicing is supported."""
        return self.corners[corner]

    def __repr__(self) -> str:
        """ Returns string representation of box as ``ConstructionBox(center, width, height, angle)`` """
        return "ConstructionBox({0.center}, {0.width}, {0.height}, {0.angle})".format(self)

    def translate(self, dx: float, dy: float) -> None:
        """
        Move box about `dx` in x-axis and about `dy` in y-axis.

        Args:
            dx: translation in x-axis
            dy: translation in y-axis

        """
        self.center += Vec2((dx, dy))

    def expand(self, dw: float, dh: float) -> None:
        """ Expand box: `dw` expand width, `dh` expand height. """
        self.width += dw
        self.height += dh

    def scale(self, sw: float, sh: float) -> None:
        """ Scale box: `sw` scales width, `sh` scales height. """
        self.width *= sw
        self.height *= sh

    def rotate(self, angle: float) -> None:
        """ Rotate box by `angle` in degrees. """
        self.angle += angle

    def is_inside(self, point: 'Vertex') -> bool:
        """ Returns ``True`` if `point` is inside of box. """
        point = Vec2(point)
        delta = self.center - point
        if math.isclose(self.angle, 0.):  # fast path for horizontal rectangles
            return abs(delta.x) <= (self._width / 2.) and abs(delta.y) <= (self._height / 2.)
        else:
            distance = delta.magnitude
            if distance > self.circumcircle_radius:
                return False
            elif distance <= self.incircle_radius:
                return True
            else:
                # inside if point is "left of line" of all border lines.
                p1, p2, p3, p4 = self.corners
                return all(
                    (point_to_line_relation(point, a, b) < 1 for a, b in [(p1, p2), (p2, p3), (p3, p4), (p4, p1)])
                )

    def is_any_corner_inside(self, other: 'ConstructionBox') -> bool:
        """ Returns ``True`` if any corner of `other` box is inside this box. """
        return any(self.is_inside(p) for p in other.corners)

    def is_overlapping(self, other: 'ConstructionBox') -> bool:
        """ Returns ``True`` if this box and `other` box do overlap. """
        distance = (self.center - other.center).magnitude
        max_distance = self.circumcircle_radius + other.circumcircle_radius
        if distance > max_distance:
            return False
        min_distance = self.incircle_radius + other.incircle_radius
        if distance <= min_distance:
            return True

        if self.is_any_corner_inside(other):
            return True
        if other.is_any_corner_inside(self):
            return True
        # no corner inside of any box, maybe crossing boxes?
        # check intersection of diagonals
        c1, c2, c3, c4 = self.corners
        diag1 = ConstructionLine(c1, c3)
        diag2 = ConstructionLine(c2, c4)

        t1, t2, t3, t4 = other.corners
        test_diag = ConstructionLine(t1, t3)
        if test_diag.has_intersection(diag1) or test_diag.has_intersection(diag2):
            return True
        test_diag = ConstructionLine(t2, t4)
        if test_diag.has_intersection(diag1) or test_diag.has_intersection(diag2):
            return True

        return False

    def border_lines(self) -> Sequence[ConstructionLine]:
        """ Returns border lines of box as sequence of :class:`ConstructionLine`. """
        p1, p2, p3, p4 = self.corners
        return (
            ConstructionLine(p1, p2),
            ConstructionLine(p2, p3),
            ConstructionLine(p3, p4),
            ConstructionLine(p4, p1),
        )

    def intersect(self, line: ConstructionLine) -> List[Vec2]:
        """
        Returns 0, 1 or 2 intersection points between `line` and box border lines.

        Args:
            line: line to intersect with border lines

        Returns:
            list of intersection points

            =========== ==================================
            list size   Description
            =========== ==================================
            0           no intersection
            1           line touches box at one corner
            2           line intersects with box
            =========== ==================================

        """
        result = set()
        for border_line in self.border_lines():
            p = line.intersect(border_line)
            if p is not None:
                result.add(p)
        return sorted(result)
