# Copyright (c) 2019-2020 Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, Iterable, Sequence, cast
import array
import copy
from itertools import chain
from ezdxf.audit import AuditError
from ezdxf.lldxf import validator
from ezdxf.lldxf.attributes import (
    DXFAttr, DXFAttributes, DefSubclass, XType, RETURN_DEFAULT,
    group_code_mapping,
)
from ezdxf.lldxf.const import SUBCLASS_MARKER, DXF2000, DXFValueError
from ezdxf.lldxf.packedtags import VertexArray, Tags
from ezdxf.math import (
    Vec3, Matrix44, ConstructionEllipse, Z_AXIS, NULLVEC,
    uniform_knot_vector, open_uniform_knot_vector, BSpline,
    required_knot_values, required_fit_points, required_control_points,
)
from .dxfentity import base_class, SubclassProcessor
from .dxfgfx import DXFGraphic, acdb_entity
from .factory import register_entity

if TYPE_CHECKING:
    from ezdxf.eztypes import TagWriter, DXFNamespace, Vertex, Auditor

__all__ = ['Spline']

acdb_spline = DefSubclass('AcDbSpline', {
    # Spline flags:
    # 1 = Closed spline
    # 2 = Periodic spline
    # 4 = Rational spline
    # 8 = Planar
    # 16 = Linear (planar bit is also set)
    'flags': DXFAttr(70, default=0),
    'degree': DXFAttr(71, default=3, validator=validator.is_positive),
    'n_knots': DXFAttr(
        72, xtype=XType.callback, getter='knot_count'),
    'n_control_points': DXFAttr(
        73, xtype=XType.callback, getter='control_point_count'),
    'n_fit_points': DXFAttr(
        74, xtype=XType.callback, getter='fit_point_count'),
    'knot_tolerance': DXFAttr(42, default=1e-10, optional=True),
    'control_point_tolerance': DXFAttr(43, default=1e-10, optional=True),
    'fit_tolerance': DXFAttr(44, default=1e-10, optional=True),
    # Start- and end tangents should be normalized, but CAD applications do not
    # crash if they are not normalized.
    'start_tangent': DXFAttr(
        12, xtype=XType.point3d, optional=True,
        validator=validator.is_not_null_vector,
    ),
    'end_tangent': DXFAttr(
        13, xtype=XType.point3d, optional=True,
        validator=validator.is_not_null_vector,
    ),
    # Extrusion is the normal vector (omitted if the spline is non-planar)
    'extrusion': DXFAttr(
        210, xtype=XType.point3d, default=Z_AXIS, optional=True,
        validator=validator.is_not_null_vector,
        fixer=RETURN_DEFAULT,
    ),
    # 10: Control points (in WCS); one entry per control point
    # 11: Fit points (in WCS); one entry per fit point
    # 40: Knot value (one entry per knot)
    # 41: Weight (if not 1); with multiple group pairs, they are present if all
    #     are not 1
})
acdb_spline_group_codes = group_code_mapping(acdb_spline)


class SplineData:
    def __init__(self, spline: 'Spline'):
        self.fit_points = spline.fit_points
        self.control_points = spline.control_points
        self.knots = spline.knots
        self.weights = spline.weights


REMOVE_CODES = {10, 11, 40, 41, 72, 73, 74}


@register_entity
class Spline(DXFGraphic):
    """ DXF SPLINE entity """
    DXFTYPE = 'SPLINE'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_spline)
    MIN_DXF_VERSION_FOR_EXPORT = DXF2000
    CLOSED = 1  # closed b-spline
    PERIODIC = 2  # uniform b-spline
    RATIONAL = 4  # rational b-spline
    PLANAR = 8  # all spline points in a plane, don't read or set this bit, just ignore like AutoCAD
    LINEAR = 16  # always set with PLANAR, don't read or set this bit, just ignore like AutoCAD

    def __init__(self):
        super().__init__()
        self.fit_points = VertexArray()  # data stored as array.array('d')
        self.control_points = VertexArray()  # data stored as array.array('d')
        self.knots = []  # data stored as array.array('d')
        self.weights = []  # data stored as array.array('d')

    def _copy_data(self, entity: 'Spline') -> None:
        """ Copy data: control_points, fit_points, weights, knot_values. """
        entity._control_points = copy.deepcopy(self._control_points)
        entity._fit_points = copy.deepcopy(self._fit_points)
        entity._knots = copy.deepcopy(self._knots)
        entity._weights = copy.deepcopy(self._weights)

    def load_dxf_attribs(self,
                         processor: SubclassProcessor = None) -> 'DXFNamespace':
        dxf = super().load_dxf_attribs(processor)
        if processor:
            tags = Tags(self.load_spline_data(processor.subclass_by_index(2)))
            processor.fast_load_dxfattribs(
                dxf, acdb_spline_group_codes, subclass=tags, recover=True)
        return dxf

    def load_spline_data(self, tags) -> Iterable:
        """ Load and set spline data (fit points, control points, weights,
        knots) and remove invalid start- and end tangents.
        Yields the remaining unprocessed tags.
        """
        control_points = []
        fit_points = []
        knots = []
        weights = []
        for tag in tags:
            code, value = tag
            if code == 10:
                control_points.append(value)
            elif code == 11:
                fit_points.append(value)
            elif code == 40:
                knots.append(value)
            elif code == 41:
                weights.append(value)
            elif code in (12, 13) and NULLVEC.isclose(value):
                # Tangent values equal to (0, 0, 0) are invalid and ignored at
                # the loading stage!
                pass
            else:
                yield tag
        self.control_points = control_points
        self.fit_points = fit_points
        self.knots = knots
        self.weights = weights

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export entity specific data as DXF tags. """
        super().export_entity(tagwriter)
        tagwriter.write_tag2(SUBCLASS_MARKER, acdb_spline.name)
        self.dxf.export_dxf_attribs(tagwriter, ['extrusion', 'flags', 'degree'])
        tagwriter.write_tag2(72, self.knot_count())
        tagwriter.write_tag2(73, self.control_point_count())
        tagwriter.write_tag2(74, self.fit_point_count())
        self.dxf.export_dxf_attribs(tagwriter, [
            'knot_tolerance', 'control_point_tolerance', 'fit_tolerance',
            'start_tangent', 'end_tangent',
        ])

        self.export_spline_data(tagwriter)

    def export_spline_data(self, tagwriter: 'TagWriter'):
        for value in self._knots:
            tagwriter.write_tag2(40, value)

        if len(self._weights):
            for value in self._weights:
                tagwriter.write_tag2(41, value)

        self._control_points.export_dxf(tagwriter, code=10)
        self._fit_points.export_dxf(tagwriter, code=11)

    @property
    def closed(self) -> bool:
        """ ``True`` if spline is closed. A closed spline has a connection from
        the last control point to the first control point. (read/write)
        """
        return self.get_flag_state(self.CLOSED, name='flags')

    @closed.setter
    def closed(self, status: bool) -> None:
        self.set_flag_state(self.CLOSED, state=status, name='flags')

    @property
    def knots(self) -> 'array.array':
        """ Knot values as :code:`array.array('d')`. """
        return self._knots

    @knots.setter
    def knots(self, values: Iterable[float]) -> None:
        self._knots = array.array('d', values)

    # DXF callback attribute Spline.dxf.n_knots
    def knot_count(self) -> int:
        """ Count of knot values. """
        return len(self._knots)

    @property
    def weights(self) -> 'array.array':
        """ Control point weights as :code:`array.array('d')`. """
        return self._weights

    @weights.setter
    def weights(self, values: Iterable[float]) -> None:
        self._weights = array.array('d', values)

    @property
    def control_points(self) -> VertexArray:
        """ :class:`~ezdxf.lldxf.packedtags.VertexArray` of control points in
        :ref:`WCS`.
        """
        return self._control_points

    @control_points.setter
    def control_points(self, points: Iterable['Vertex']) -> None:
        self._control_points = VertexArray(
            chain.from_iterable(Vec3.generate(points)))

    # DXF callback attribute Spline.dxf.n_control_points
    def control_point_count(self) -> int:
        """ Count of control points. """
        return len(self.control_points)

    @property
    def fit_points(self) -> VertexArray:
        """ :class:`~ezdxf.lldxf.packedtags.VertexArray` of fit points in
        :ref:`WCS`.
        """
        return self._fit_points

    @fit_points.setter
    def fit_points(self, points: Iterable['Vertex']) -> None:
        self._fit_points = VertexArray(
            chain.from_iterable(Vec3.generate(points)))

    # DXF callback attribute Spline.dxf.n_fit_points
    def fit_point_count(self) -> int:
        """ Count of fit points. """
        return len(self.fit_points)

    def construction_tool(self) -> BSpline:
        """ Returns construction tool :class:`ezdxf.math.BSpline`.

        .. versionadded:: 0.13

        """
        if self.control_point_count():
            weights = self.weights if len(self.weights) else None
            knots = self.knots if len(self.knots) else None
            return BSpline(control_points=self.control_points,
                           order=self.dxf.degree + 1, knots=knots,
                           weights=weights)
        elif self.fit_point_count():
            return BSpline.from_fit_points(self.fit_points,
                                           degree=self.dxf.degree)
        else:
            raise ValueError(
                'Construction tool requires control- or fit points.')

    def apply_construction_tool(self, s) -> 'Spline':
        """ Set SPLINE data from construction tool :class:`ezdxf.math.BSpline`
        or from a :class:`geomdl.BSpline.Curve` object.

        .. versionadded:: 0.13

        """
        try:
            self.control_points = s.control_points
        except AttributeError:  # maybe a geomdl.BSpline.Curve class
            s = BSpline.from_nurbs_python_curve(s)
            self.control_points = s.control_points

        self.dxf.degree = s.degree
        self.fit_points = []  # remove fit points
        self.knots = s.knots()
        self.weights = s.weights()
        self.set_flag_state(Spline.RATIONAL, state=bool(len(self.weights)))
        return self  # floating interface

    def flattening(self, distance: float,
                   segments: int = 4) -> Iterable[Vec3]:
        """ Adaptive recursive flattening. The argument `segments` is the
        minimum count of approximation segments between two knots, if the
        distance from the center of the approximation segment to the curve is
        bigger than `distance` the segment will be subdivided.

        Args:
            distance: maximum distance from the projected curve point onto the
                segment chord.
            segments: minimum segment count between two knots

        .. versionadded:: 0.15

        """
        return self.construction_tool().flattening(distance, segments)

    @classmethod
    def from_arc(cls, entity: 'DXFGraphic') -> 'Spline':
        """ Create a new SPLINE entity from CIRCLE, ARC or ELLIPSE entity.

        The new SPLINE entity has no owner, no handle, is not stored in
        the entity database nor assigned to any layout!

        .. versionadded:: 0.13

        """
        dxftype = entity.dxftype()
        if dxftype == 'ELLIPSE':
            ellipse = cast('Ellipse', entity).construction_tool()
        elif dxftype == 'CIRCLE':
            ellipse = ConstructionEllipse.from_arc(
                center=entity.dxf.get('center', NULLVEC),
                radius=abs(entity.dxf.get('radius', 1.0)),
                extrusion=entity.dxf.get('extrusion', Z_AXIS),
            )
        elif dxftype == 'ARC':
            ellipse = ConstructionEllipse.from_arc(
                center=entity.dxf.get('center', NULLVEC),
                radius=abs(entity.dxf.get('radius', 1.0)),
                extrusion=entity.dxf.get('extrusion', Z_AXIS),
                start_angle=entity.dxf.get('start_angle', 0),
                end_angle=entity.dxf.get('end_angle', 360)
            )
        else:
            raise TypeError('CIRCLE, ARC or ELLIPSE entity required.')

        spline = Spline.new(dxfattribs=entity.graphic_properties(),
                            doc=entity.doc)
        s = BSpline.from_ellipse(ellipse)
        spline.dxf.degree = s.degree
        spline.dxf.flags = Spline.RATIONAL
        spline.control_points = s.control_points
        spline.knots = s.knots()
        spline.weights = s.weights()
        return spline

    def set_open_uniform(self, control_points: Sequence['Vertex'],
                         degree: int = 3) -> None:
        """ Open B-spline with uniform knot vector, start and end at your first
        and last control points.

        """
        self.dxf.flags = 0
        self.dxf.degree = degree
        self.control_points = control_points
        self.knots = open_uniform_knot_vector(len(control_points), degree + 1)

    def set_uniform(self, control_points: Sequence['Vertex'],
                    degree: int = 3) -> None:
        """ B-spline with uniform knot vector, does NOT start and end at your
        first and last control points.

        """
        self.dxf.flags = 0
        self.dxf.degree = degree
        self.control_points = control_points
        self.knots = uniform_knot_vector(len(control_points), degree + 1)

    def set_closed(self, control_points: Sequence['Vertex'], degree=3) -> None:
        """
        Closed B-spline with uniform knot vector, start and end at your first control point.

        """
        self.dxf.flags = self.PERIODIC | self.CLOSED
        self.dxf.degree = degree
        self.control_points = control_points
        self.control_points.extend(control_points[:degree])
        # AutoDesk Developer Docs:
        # If the spline is periodic, the length of knot vector will be greater
        # than length of the control array by 1, but this does not work with
        # BricsCAD.
        self.knots = uniform_knot_vector(len(self.control_points), degree + 1)

    def set_open_rational(self, control_points: Sequence['Vertex'],
                          weights: Sequence[float], degree: int = 3) -> None:
        """ Open rational B-spline with uniform knot vector, start and end at
        your first and last control points, and has additional control
        possibilities by weighting each control point.

        """
        self.set_open_uniform(control_points, degree=degree)
        self.dxf.flags = self.dxf.flags | self.RATIONAL
        if len(weights) != len(self.control_points):
            raise DXFValueError(
                'Control point count must be equal to weights count.')
        self.weights = weights

    def set_uniform_rational(self, control_points: Sequence['Vertex'],
                             weights: Sequence[float],
                             degree: int = 3) -> None:
        """ Rational B-spline with uniform knot vector, does NOT start and end
        at your first and last control points, and has additional control
        possibilities by weighting each control point.

        """
        self.set_uniform(control_points, degree=degree)
        self.dxf.flags = self.dxf.flags | self.RATIONAL
        if len(weights) != len(self.control_points):
            raise DXFValueError(
                'Control point count must be equal to weights count.')
        self.weights = weights

    def set_closed_rational(self, control_points: Sequence['Vertex'],
                            weights: Sequence[float],
                            degree: int = 3) -> None:
        """ Closed rational B-spline with uniform knot vector, start and end at
        your first control point, and has additional control possibilities by
        weighting each control point.

        """
        self.set_closed(control_points, degree=degree)
        self.dxf.flags = self.dxf.flags | self.RATIONAL
        weights = list(weights)
        weights.extend(weights[:degree])
        if len(weights) != len(self.control_points):
            raise DXFValueError(
                'Control point count must be equal to weights count.')
        self.weights = weights

    def transform(self, m: 'Matrix44') -> 'Spline':
        """ Transform SPLINE entity by transformation matrix `m` inplace.

        .. versionadded:: 0.13

        """
        self._control_points.transform(m)
        self._fit_points.transform(m)
        # Transform optional attributes if they exist
        dxf = self.dxf
        for name in ('start_tangent', 'end_tangent', 'extrusion'):
            if dxf.hasattr(name):
                dxf.set(name, m.transform_direction(dxf.get(name)))

        return self

    def audit(self, auditor: 'Auditor') -> None:
        """ Audit the SPLINE entity.

        .. versionadded:: 0.15.1

        """
        super().audit(auditor)
        degree = self.dxf.degree
        name = str(self)

        if degree < 1:
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_DEFINITION,
                message=f"Removed {name} with invalid degree: {degree} < 1."
            )
            auditor.trash(self)
            return

        n_control_points = len(self.control_points)
        n_fit_points = len(self.fit_points)

        if n_control_points == 0 and n_fit_points == 0:
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_DEFINITION,
                message=f"Removed {name} without any points (no geometry)."
            )
            auditor.trash(self)
            return

        if n_control_points > 0:
            self._audit_control_points(auditor)
        # Ignore fit points if defined by control points
        elif n_fit_points > 0:
            self._audit_fit_points(auditor)

    def _audit_control_points(self, auditor: 'Auditor'):
        name = str(self)
        order = self.dxf.degree + 1
        n_control_points = len(self.control_points)

        # Splines with to few control points can't be processed:
        n_control_points_required = required_control_points(order)
        if n_control_points < n_control_points_required:
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_CONTROL_POINT_COUNT,
                message=f"Removed {name} with invalid control point count: "
                        f"{n_control_points} < {n_control_points_required}"
            )
            auditor.trash(self)
            return

        n_weights = len(self.weights)
        n_knots = len(self.knots)
        n_knots_required = required_knot_values(
            n_control_points, order)

        if n_knots < n_knots_required:
            # Can not fix entity: because the knot values are basic
            # values which define the geometry of SPLINE.
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_KNOT_VALUE_COUNT,
                message=f"Removed {name} with invalid knot value count: "
                        f"{n_knots} < {n_knots_required}"
            )
            auditor.trash(self)
            return

        if n_weights and n_weights != n_control_points:
            # Can not fix entity: because the weights are basic
            # values which define the geometry of SPLINE.
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_WEIGHT_COUNT,
                message=f"Removed {name} with invalid weight count: "
                        f"{n_weights} != {n_control_points}"
            )
            auditor.trash(self)
            return

    def _audit_fit_points(self, auditor: 'Auditor'):
        name = str(self)
        order = self.dxf.degree + 1
        # Assuming end tangents will be estimated if not present,
        # like by ezdxf:
        n_fit_points_required = required_fit_points(order, tangents=True)

        # Splines with to few fit points can't be processed:
        n_fit_points = len(self.fit_points)
        if n_fit_points < n_fit_points_required:
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_FIT_POINT_COUNT,
                message=f"Removed {name} with invalid fit point count: "
                        f"{n_fit_points} < {n_fit_points_required}"
            )
            auditor.trash(self)
            return

        # Knot values have no meaning for splines defined by fit points:
        if len(self.knots):
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_KNOT_VALUE_COUNT,
                message=f"Removed unused knot values for {name} "
                        f"defined by fit points."
            )
            self.knots = []

        # Weights have no meaning for splines defined by fit points:
        if len(self.weights):
            auditor.fixed_error(
                code=AuditError.INVALID_SPLINE_WEIGHT_COUNT,
                message=f"Removed unused weights for {name} "
                        f"defined by fit points."
            )
            self.weights = []
