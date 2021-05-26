# Purpose: sierpinski pyramid
# Created: 07.12.2016
# Copyright (c) 2016-2020 Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, Iterable, List, Sequence, Tuple
import math
from ezdxf.math import Vec3
from ezdxf.render.mesh import MeshVertexMerger, MeshTransformer

if TYPE_CHECKING:
    from ezdxf.eztypes import Vertex, GenericLayoutType, Matrix44, UCS

HEIGHT4 = 1. / math.sqrt(2.)  # pyramid4 height (* length)
HEIGHT3 = math.sqrt(6.) / 3.  # pyramid3 height (* length)

DY1_FACTOR = math.tan(math.pi / 6.) / 2.  # inner circle radius
DY2_FACTOR = 0.5 / math.cos(math.pi / 6.)  # outer circle radius


class SierpinskyPyramid:
    """
    Args:
        location: location of base center as (x, y, z) tuple
        length: side length
        level: subdivide level
        sides: sides of base geometry

    """
    def __init__(self, location: 'Vertex' = (0., 0., 0.), length: float = 1., level: int = 1, sides: int = 4):
        self.sides = sides
        self.pyramid_definitions = sierpinsky_pyramid(location=location, length=length, level=level, sides=sides)

    def vertices(self) -> Iterable['Vertex']:
        """ Yields the pyramid vertices as list of (x, y, z) tuples. """
        for location, length in self.pyramid_definitions:
            yield self._calc_vertices(location, length)

    __iter__ = vertices

    def _calc_vertices(self, location: 'Vertex', length: float) -> List['Vertex']:
        """
        Calculates the pyramid vertices.

        Args:
            location: location of the pyramid as center point of the base
            length: pyramid side length

        Returns: list of (x, y, z) tuples

        """
        len2 = length / 2.
        x, y, z = location
        if self.sides == 4:
            return [
                Vec3(x - len2, y - len2, z),
                Vec3(x + len2, y - len2, z),
                Vec3(x + len2, y + len2, z),
                Vec3(x - len2, y + len2, z),
                Vec3(x, y, z + length * HEIGHT4)
            ]
        elif self.sides == 3:
            dy1 = length * DY1_FACTOR
            dy2 = length * DY2_FACTOR
            return [
                Vec3(x - len2, y - dy1, z),
                Vec3(x + len2, y - dy1, z),
                Vec3(x, y + dy2, z),
                Vec3(x, y, z + length * HEIGHT3)
            ]
        else:
            raise ValueError("sides has to be 3 or 4.")

    def faces(self) -> List[Sequence[int]]:
        """
        Returns list of pyramid faces. All pyramid vertices have the same order, so one faces list fits them all.

        """
        if self.sides == 4:
            return [
                (3, 2, 1, 0),
                (0, 1, 4),
                (1, 2, 4),
                (2, 3, 4),
                (3, 0, 4)
            ]
        elif self.sides == 3:
            return [
                (2, 1, 0),
                (0, 1, 3),
                (1, 2, 3),
                (2, 0, 3)
            ]
        else:
            raise ValueError("sides has to be 3 or 4.")

    def render(self, layout: 'GenericLayoutType', merge: bool = False, dxfattribs: dict = None,
               matrix: 'Matrix44' = None, ucs: 'UCS' = None) -> None:
        """
        Renders the sierpinsky pyramid into layout, set `merge` to ``True`` for rendering the whole sierpinsky pyramid
        into one MESH entity, set `merge` to ``False`` for individual pyramids as MESH entities.

        Args:
            layout: DXF target layout
            merge: ``True`` for one MESH entity, ``False`` for individual MESH entities per pyramid
            dxfattribs: DXF attributes for the MESH entities
            matrix: apply transformation matrix at rendering
            ucs: apply UCS at rendering

        """
        if merge:
            mesh = self.mesh()
            mesh.render(layout, dxfattribs=dxfattribs, matrix=matrix, ucs=ucs)
        else:
            for pyramid in self.pyramids():
                pyramid.render(layout, dxfattribs, matrix=matrix, ucs=ucs)

    def pyramids(self) -> Iterable[MeshTransformer]:
        """ Yields all pyramids of the sierpinsky pyramid as individual :class:`MeshTransformer` objects.
        """
        faces = self.faces()
        for vertices in self:
            mesh = MeshTransformer()
            mesh.add_mesh(vertices=vertices, faces=faces)
            yield mesh

    def mesh(self) -> MeshTransformer:
        """ Returns geometry as one :class:`MeshTransformer` object.
        """
        faces = self.faces()
        mesh = MeshVertexMerger()
        for vertices in self:
            mesh.add_mesh(vertices=vertices, faces=faces)
        return MeshTransformer.from_builder(mesh)


def sierpinsky_pyramid(location: (0., 0., 0.),
                       length: float = 1.,
                       level: int = 1,
                       sides: int = 4) -> List[Tuple[Vec3, float]]:
    """ Build a Sierpinski pyramid.

    Args:
        location: base center point of the pyramid
        length: base length of the pyramid
        level: recursive building levels, has to 1 or bigger
        sides: 3 or 4 sided pyramids supported

    Returns: list of pyramid vertices

    """
    location = Vec3(location)
    level = int(level)
    if level < 1:
        raise ValueError("level has to be 1 or bigger.")
    pyramids = _sierpinsky_pyramid(location, length, sides)
    for _ in range(level - 1):
        next_level_pyramids = []
        for location, length in pyramids:
            next_level_pyramids.extend(_sierpinsky_pyramid(location, length, sides))
        pyramids = next_level_pyramids
    return pyramids


def _sierpinsky_pyramid(location: Vec3,
                        length: float = 1.,
                        sides: int = 4) -> List[Tuple[Vec3, float]]:
    if sides == 3:
        return sierpinsky_pyramid_3(location, length)
    elif sides == 4:
        return sierpinsky_pyramid_4(location, length)
    else:
        raise ValueError("sides has to be 3 or 4.")


def sierpinsky_pyramid_4(location: Vec3, length: float = 1.) -> List[Tuple[Vec3, float]]:
    """ Build a 4-sided Sierpinski pyramid. Pyramid height = length of the base square!

    Args:
        location: base center point of the pyramid
        length: base length of the pyramid

    Returns: list of (location, length) tuples, representing the sierpinski pyramid

    """
    len2 = length / 2
    len4 = length / 4
    x, y, z = location
    return [
        (Vec3(x - len4, y - len4, z), len2),
        (Vec3(x + len4, y - len4, z), len2),
        (Vec3(x - len4, y + len4, z), len2),
        (Vec3(x + len4, y + len4, z), len2),
        (Vec3(x, y, z + len2 * HEIGHT4), len2)
    ]


def sierpinsky_pyramid_3(location: Vec3, length: float = 1.) -> List[Tuple[Vec3, float]]:
    """ Build a 3-sided Sierpinski pyramid (tetraeder).

    Args:
        location: base center point of the pyramid
        length: base length of the pyramid

    Returns: list of (location, length) tuples, representing the sierpinski pyramid

    """
    dy1 = length * DY1_FACTOR * 0.5
    dy2 = length * DY2_FACTOR * 0.5
    len2 = length / 2
    len4 = length / 4
    x, y, z = location
    return [
        (Vec3(x - len4, y - dy1, z), len2),
        (Vec3(x + len4, y - dy1, z), len2),
        (Vec3(x, y + dy2, z), len2),
        (Vec3(x, y, z + len2 * HEIGHT3), len2)
    ]
