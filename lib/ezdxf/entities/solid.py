# Copyright (c) 2019-2020 Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, List
from ezdxf.lldxf import validator
from ezdxf.lldxf.attributes import (
    DXFAttr, DXFAttributes, DefSubclass, XType, RETURN_DEFAULT,
    group_code_mapping,
)
from ezdxf.lldxf.const import DXF12, SUBCLASS_MARKER, VERTEXNAMES
from ezdxf.math import Matrix44, Z_AXIS, NULLVEC, Vec3
from ezdxf.math.transformtools import OCSTransform
from .dxfentity import base_class, SubclassProcessor
from .dxfgfx import DXFGraphic, acdb_entity, elevation_to_z_axis
from .factory import register_entity

if TYPE_CHECKING:
    from ezdxf.eztypes import TagWriter, DXFNamespace

__all__ = ['Solid', 'Trace', 'Face3d']

acdb_trace = DefSubclass('AcDbTrace', {
    # 1. corner Solid WCS; Trace OCS
    'vtx0': DXFAttr(10, xtype=XType.point3d, default=NULLVEC),

    # 2. corner Solid WCS; Trace OCS
    'vtx1': DXFAttr(11, xtype=XType.point3d, default=NULLVEC),

    # 3. corner Solid WCS; Trace OCS
    'vtx2': DXFAttr(12, xtype=XType.point3d, default=NULLVEC),

    # 4. corner Solid WCS; Trace OCS:
    # If only three corners are entered to define the SOLID, then the fourth
    # corner coordinate is the same as the third.
    'vtx3': DXFAttr(13, xtype=XType.point3d, default=NULLVEC),

    # Elevation is a legacy feature from R11 and prior, do not use this
    # attribute, store the entity elevation in the z-axis of the vertices.
    # ezdxf does not export the elevation attribute!
    'elevation': DXFAttr(38, default=0, optional=True),

    # Thickness could be negative:
    'thickness': DXFAttr(39, default=0, optional=True),
    'extrusion': DXFAttr(
        210, xtype=XType.point3d, default=Z_AXIS, optional=True,
        validator=validator.is_not_null_vector,
        fixer=RETURN_DEFAULT,
    ),
})
acdb_trace_group_codes = group_code_mapping(acdb_trace)


class _Base(DXFGraphic):
    def __getitem__(self, num):
        return self.dxf.get(VERTEXNAMES[num])

    def __setitem__(self, num, value):
        return self.dxf.set(VERTEXNAMES[num], value)


@register_entity
class Solid(_Base):
    """ DXF SHAPE entity """
    DXFTYPE = 'SOLID'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_trace)

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        """ Loading interface. (internal API) """
        dxf = super().load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_trace_group_codes, subclass=2, recover=True)
            if processor.r12:
                # Transform elevation attribute from R11 to z-axis values:
                elevation_to_z_axis(dxf, VERTEXNAMES)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export entity specific data as DXF tags. (internal API) """
        super().export_entity(tagwriter)
        if tagwriter.dxfversion > DXF12:
            tagwriter.write_tag2(SUBCLASS_MARKER, acdb_trace.name)
        if not self.dxf.hasattr('vtx3'):
            self.dxf.vtx3 = self.dxf.vtx2
        self.dxf.export_dxf_attribs(tagwriter, [
            'vtx0', 'vtx1', 'vtx2', 'vtx3', 'thickness',
            'extrusion',
        ])

    def transform(self, m: Matrix44) -> 'Solid':
        """ Transform SOLID/TRACE  entity by transformation matrix `m` inplace.

        .. versionadded:: 0.13

        """
        # SOLID/TRACE is 2d entity, placed by an OCS in 3d space
        dxf = self.dxf
        ocs = OCSTransform(self.dxf.extrusion, m)
        for name in VERTEXNAMES:
            if dxf.hasattr(name):
                dxf.set(name, ocs.transform_vertex(dxf.get(name)))
        if dxf.hasattr('thickness'):
            dxf.thickness = ocs.transform_length(
                (0, 0, dxf.thickness), reflection=dxf.thickness)
        dxf.extrusion = ocs.new_extrusion
        return self

    def wcs_vertices(self, close: bool = False) -> List[Vec3]:
        """ Returns WCS vertices in correct order,
        if argument `close` is ``True``, last vertex == first vertex.
        Does **not** return duplicated last vertex if represents a triangle.

        .. versionadded:: 0.15

        """
        ocs = self.ocs()
        return list(ocs.points_to_wcs(self.vertices(close)))

    def vertices(self, close: bool = False) -> List[Vec3]:
        """ Returns OCS vertices in correct order,
        if argument `close` is ``True``, last vertex == first vertex.
        Does **not** return duplicated last vertex if represents a triangle.

        .. versionadded:: 0.15

        """
        dxf = self.dxf
        vertices = [dxf.vtx0, dxf.vtx1, dxf.vtx2]
        if dxf.vtx3 != dxf.vtx2:  # when the face is a triangle, vtx2 == vtx3
            vertices.append(dxf.vtx3)

        # adjust weird vertex order of SOLID and TRACE:
        # 0, 1, 2, 3 -> 0, 1, 3, 2
        if len(vertices) > 3:
            vertices[2], vertices[3] = vertices[3], vertices[2]

        if close and not vertices[0].isclose(vertices[-1]):
            vertices.append(vertices[0])
        return vertices


@register_entity
class Trace(Solid):
    """ DXF TRACE entity """
    DXFTYPE = 'TRACE'


acdb_face = DefSubclass('AcDbFace', {
    # 1. corner WCS:
    'vtx0': DXFAttr(10, xtype=XType.point3d, default=NULLVEC),

    # 2. corner WCS:
    'vtx1': DXFAttr(11, xtype=XType.point3d, default=NULLVEC),

    # 3. corner WCS:
    'vtx2': DXFAttr(12, xtype=XType.point3d, default=NULLVEC),

    # 4. corner WCS:
    # If only three corners are entered to define the SOLID, then the fourth
    # corner coordinate is the same as the third.
    'vtx3': DXFAttr(13, xtype=XType.point3d, default=NULLVEC),

    # invisible:
    # 1 = First edge is invisible
    # 2 = Second edge is invisible
    # 4 = Third edge is invisible
    # 8 = Fourth edge is invisible
    'invisible': DXFAttr(70, default=0, optional=True),
})
acdb_face_group_codes = group_code_mapping(acdb_face)


@register_entity
class Face3d(_Base):
    """ DXF 3DFACE entity """
    DXFTYPE = '3DFACE'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_face)

    def is_invisible_edge(self, num) -> bool:
        """ Returns True if edge `num` is an invisible edge. """
        return bool(self.dxf.invisible & (1 << num))

    def set_edge_visibility(self, num, status=False):
        """ Set visibility of edge `num`, status `True` for visible, status
        `False` for invisible.
        """
        if not status:
            self.dxf.invisible = self.dxf.invisible | (1 << num)
        else:
            self.dxf.invisible = self.dxf.invisible & ~(1 << num)

    def load_dxf_attribs(self,
                         processor: SubclassProcessor = None) -> 'DXFNamespace':
        dxf = super().load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_face_group_codes, subclass=2, recover=True)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        super().export_entity(tagwriter)
        if tagwriter.dxfversion > DXF12:
            tagwriter.write_tag2(SUBCLASS_MARKER, acdb_face.name)
        if not self.dxf.hasattr('vtx3'):
            self.dxf.vtx3 = self.dxf.vtx2
        self.dxf.export_dxf_attribs(tagwriter, [
            'vtx0', 'vtx1', 'vtx2', 'vtx3', 'invisible'
        ])

    def transform(self, m: Matrix44) -> 'Face3d':
        """ Transform 3DFACE  entity by transformation matrix `m` inplace.

        .. versionadded:: 0.13

        """
        dxf = self.dxf
        # 3DFACE is a real 3d entity
        dxf.vtx0, dxf.vtx1, dxf.vtx2, dxf.vtx3 = m.transform_vertices(
            (dxf.vtx0, dxf.vtx1, dxf.vtx2, dxf.vtx3))
        return self

    def wcs_vertices(self, close: bool = False) -> List[Vec3]:
        """ Returns WCS vertices, if argument `close` is
        ``True``, last vertex == first vertex.
        Does **not** return duplicated last vertex if represents a triangle.

        Compatibility interface to SOLID and TRACE, 3DFACE vertices are
        already WCS vertices.

        .. versionadded:: 0.15

        """
        dxf = self.dxf
        vertices = [dxf.vtx0, dxf.vtx1, dxf.vtx2]
        if dxf.vtx3 != dxf.vtx2:  # when the face is a triangle, vtx2 == vtx3
            vertices.append(dxf.vtx3)

        if close and not vertices[0].isclose(vertices[-1]):
            vertices.append(vertices[0])
        return vertices
