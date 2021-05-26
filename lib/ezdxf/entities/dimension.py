# Copyright (c) 2019-2020 Manfred Moitzi
# License: MIT License
import math
from typing import TYPE_CHECKING, Optional, Union, Iterable
import logging
from ezdxf.lldxf import validator
from ezdxf.lldxf.attributes import (
    DXFAttr, DXFAttributes, DefSubclass, XType, RETURN_DEFAULT,
    group_code_mapping,
)
from ezdxf.lldxf.const import (
    DXF12, SUBCLASS_MARKER, DXF2010, DXF2000, DXF2007, DXF2004,
    DXFValueError, DXFTableEntryError, DXFTypeError,
)
from ezdxf.lldxf.types import get_xcode_for
from ezdxf.math import Vec3, Matrix44, NULLVEC, Z_AXIS
from ezdxf.math.transformtools import OCSTransform
from ezdxf.tools import take2
from ezdxf.render.arrows import ARROWS
from ezdxf.explode import explode_entity
from .dxfentity import base_class, SubclassProcessor
from .dxfgfx import DXFGraphic, acdb_entity
from .factory import register_entity
from .dimstyleoverride import DimStyleOverride

if TYPE_CHECKING:
    from ezdxf.eztypes import (
        TagWriter, DimStyle, DXFNamespace, BlockLayout, OCS, BaseLayout,
        EntityQuery,
    )

logger = logging.getLogger('ezdxf')
ADSK_CONSTRAINTS = "*ADSK_CONSTRAINTS"

__all__ = [
    'Dimension', 'ArcDimension', 'RadialDimensionLarge',
    'OverrideMixin'
]

acdb_dimension = DefSubclass('AcDbDimension', {
    # Version number: 0 = 2010
    'version': DXFAttr(280, default=0, dxfversion=DXF2010),

    # Name of the block that contains the entities that make up the dimension
    # picture
    # Important: DIMENSION constraints do no have this group code 2:
    'geometry': DXFAttr(2, validator=validator.is_valid_block_name),

    # Dimension style name:
    'dimstyle': DXFAttr(
        3, default='Standard',
        validator=validator.is_valid_table_name,
        # Do not fix automatically, but audit fixes value as 'Standard'
    ),

    # definition point for all dimension types in WCS:
    'defpoint': DXFAttr(10, xtype=XType.point3d, default=NULLVEC),

    # Midpoint of dimension text in OCS:
    'text_midpoint': DXFAttr(11, xtype=XType.point3d),

    # Insertion point for clones of a  dimension—Baseline and Continue (in OCS)
    # located in AcDbDimension? Another error in the DXF reference?
    'insert': DXFAttr(12, xtype=XType.point3d, default=NULLVEC, optional=True),

    # Dimension type:
    # Important: Dimensional constraints do not have group code 70
    # Values 0–6 are integer values that represent the dimension type.
    # Values 32, 64, and 128 are bit values, which are added to the integer
    # values (value 32 is always set in R13 and later releases)
    # 0 = Rotated, horizontal, or vertical;
    # 1 = Aligned
    # 2 = Angular;
    # 3 = Diameter;
    # 4 = Radius
    # 5 = Angular 3 point;
    # 6 = Ordinate
    # 8 = Arc Dimension -> ARC_DIMENSION
    # 32 = Indicates that the block reference (group code 2) is referenced by
    # this dimension only
    # 64 = Ordinate type. This is a bit value (bit 7) used only with integer
    #   value 6. If set, ordinate is X-type; if not set, ordinate is Y-type
    # 128 = This is a bit value (bit 8) added to the other group 70 values if
    #   the dimension text has been positioned at a user-defined location
    #   rather than at the default location.
    'dimtype': DXFAttr(70, default=0),

    # Attachment point:
    # 1 = Top left
    # 2 = Top center
    # 3 = Top right
    # 4 = Middle left
    # 5 = Middle center
    # 6 = Middle right
    # 7 = Bottom left
    # 8 = Bottom center
    # 9 = Bottom right
    'attachment_point': DXFAttr(
        71, default=5, dxfversion=DXF2000,
        validator=validator.is_in_integer_range(0, 10),
        fixer=RETURN_DEFAULT,
    ),

    # Dimension text line-spacing style
    # 1 (or missing) = At least (taller characters will override)
    # 2 = Exact (taller characters will not override)
    'line_spacing_style': DXFAttr(
        72, default=1, dxfversion=DXF2000, optional=True,
        validator=validator.is_in_integer_range(1, 3),
        fixer=RETURN_DEFAULT,
    ),

    # Dimension text-line spacing factor:
    # Percentage of default (3-on-5) line spacing to be applied. Valid values
    # range from 0.25 to 4.00
    'line_spacing_factor': DXFAttr(
        41, dxfversion=DXF2000, optional=True,
        validator=validator.is_in_float_range(0.25, 4.00),
        fixer=validator.fit_into_float_range(0.25, 4.00),
    ),

    # Actual measurement (optional; read-only value)
    'actual_measurement': DXFAttr(42, dxfversion=DXF2000, optional=True),

    'unknown1': DXFAttr(73, dxfversion=DXF2000, optional=True),
    'flip_arrow_1': DXFAttr(
        74, dxfversion=DXF2000, optional=True,
        validator=validator.is_integer_bool,
        fixer=validator.fix_integer_bool,
    ),
    'flip_arrow_2': DXFAttr(
        75, dxfversion=DXF2000, optional=True,
        validator=validator.is_integer_bool,
        fixer=validator.fix_integer_bool,
    ),

    # Dimension text explicitly entered by the user
    # default is the measurement.
    # If null or “<>”, the dimension measurement is drawn as the text,
    # if “ “ (one blank space), the text is suppressed.
    # Anything else is drawn as the text.
    'text': DXFAttr(1, default='', optional=True),

    # Linear dimension types with an oblique angle have an optional group
    # code 52. When added to the rotation angle of the linear dimension (group
    # code 50), it gives the angle of the extension lines
    # DXF reference error: wrong subclass AcDbAlignedDimension
    'oblique_angle': DXFAttr(52, default=0, optional=True),

    # The optional group code 53 is the rotation angle of the dimension
    # text away from its default orientation (the direction of the dimension
    # line)
    'text_rotation': DXFAttr(53, default=0, optional=True),

    # All dimension types have an optional 51 group code, which
    # indicates the horizontal direction for the dimension entity.
    # The dimension entity determines the orientation of dimension text and
    # lines for horizontal, vertical, and rotated linear dimensions.
    # This group value is the negative of the angle between the OCS X axis and
    # the UCS X axis. It is always in the XY plane of the OCS
    'horizontal_direction': DXFAttr(51, default=0, optional=True),

    'extrusion': DXFAttr(
        210, xtype=XType.point3d, default=Z_AXIS, optional=True,
        validator=validator.is_not_null_vector,
        fixer=RETURN_DEFAULT,
    ),
})
acdb_dimension_group_codes = group_code_mapping(acdb_dimension)

acdb_dimension_dummy = DefSubclass('AcDbDimensionDummy', {
    # Definition point for linear and angular dimensions (in WCS)
    # 'defpoint' (10,20,30) specifies the dimension line location.
    # 'text_midpoint' (11,21,31) specifies the midpoint of the dimension text.

    # (13,23,33) specifies the start point of the first extension line:
    'defpoint2': DXFAttr(13, xtype=XType.point3d, default=NULLVEC),

    # (14,24,34) specifies the start point of the second extension line:
    'defpoint3': DXFAttr(14, xtype=XType.point3d, default=NULLVEC),

    # Angle of rotated, horizontal, or vertical dimensions:
    'angle': DXFAttr(50, default=0),

    # Definition point for diameter, radius, and angular dimensions (in WCS)
    'defpoint4': DXFAttr(15, xtype=XType.point3d, default=NULLVEC),

    # Leader length for radius and diameter dimensions
    'leader_length': DXFAttr(40),

    # Point defining dimension arc for angular dimensions (in OCS)
    # 'defpoint2' (13,23,33) and 'defpoint3' (14,24,34) specify the endpoints
    # of the line used to determine the first extension line.
    # 'defpoint' (10,20,30) and 'defpoint4' (15,25,35) specify the endpoints of
    # the line used to determine the second extension line.
    # 'defpoint5' (16,26,36) specifies the location of the dimension line arc.
    # 'text_midpoint' (11,21,31) specifies the midpoint of the dimension text.
    'defpoint5': DXFAttr(16, xtype=XType.point3d, default=NULLVEC),
})
acdb_dimension_dummy_group_codes = group_code_mapping(acdb_dimension_dummy)


# noinspection PyUnresolvedReferences
class OverrideMixin:
    def get_dim_style(self) -> 'DimStyle':
        """ Returns the associated :class:`DimStyle` entity. """
        assert self.doc, 'Dimension.doc attribute not initialized.'

        dim_style_name = self.dxf.dimstyle
        # raises ValueError if not exist, but all dim styles in use should
        # exist!
        return self.doc.dimstyles.get(dim_style_name)

    def dim_style_attributes(self) -> 'DXFAttributes':
        """ Returns all valid DXF attributes (internal API). """
        return self.get_dim_style().DXFATTRIBS

    def dim_style_attr_names_to_handles(self, data: dict,
                                        dxfversion: str) -> dict:
        """ `ezdxf` uses internally only resource names for arrows, line types
        and text styles, but DXF 2000 and later requires handles for these
        resources, this method translates resource names into related handles.
        (e.g. 'dimtxsty': 'FancyStyle' -> 'dimtxsty_handle', <handle of FancyStyle>)

        Args:
            data: dictionary of overridden DimStyle attributes as names (ezdxf)
            dxfversion: target DXF version

        Returns: dictionary with resource names replaced by handles

        Raises:
            DXFTableEntry: text style or line type does not exist
            DXFKeyError: referenced block does not exist

        (internal API)

        """
        data = dict(data)
        blocks = self.doc.blocks

        def set_arrow_handle(attrib_name, block_name):
            attrib_name += '_handle'
            if block_name in ARROWS:
                # Create all arrows on demand
                block_name = ARROWS.create_block(blocks, block_name)
            if block_name == '_CLOSEDFILLED':  # special arrow
                handle = '0'  # set special #0 handle for closed filled arrow
            else:
                block = blocks[block_name]
                handle = block.block_record_handle
            data[attrib_name] = handle

        def set_linetype_handle(attrib_name, linetype_name):
            try:
                ltype = self.doc.linetypes.get(linetype_name)
            except DXFTableEntryError:
                logger.warning(
                    f'Required line type "{linetype_name}" does not exist.')
            else:
                data[attrib_name + '_handle'] = ltype.dxf.handle

        if dxfversion > DXF12:
            # transform block names into block record handles
            for attrib_name in ('dimblk', 'dimblk1', 'dimblk2', 'dimldrblk'):
                try:
                    block_name = data.pop(attrib_name)
                except KeyError:
                    pass
                else:
                    set_arrow_handle(attrib_name, block_name)

            # replace 'dimtxsty' attribute by 'dimtxsty_handle'
            try:
                dimtxsty = data.pop('dimtxsty')
            except KeyError:
                pass
            else:
                txtstyle = self.doc.styles.get(dimtxsty)
                data['dimtxsty_handle'] = txtstyle.dxf.handle

        if dxfversion >= DXF2007:
            # transform linetype names into LTYPE entry handles
            for attrib_name in ('dimltype', 'dimltex1', 'dimltex2'):
                try:
                    linetype_name = data.pop(attrib_name)
                except KeyError:
                    pass
                else:
                    set_linetype_handle(attrib_name, linetype_name)
        return data

    def set_acad_dstyle(self, data: dict) -> None:
        """ Set XDATA section ACAD:DSTYLE, to override DIMSTYLE attributes for
        this DIMENSION entity.

        Args:
            data: ``dict`` with DIMSTYLE attribute names as keys.

        (internal API)

        """
        assert self.doc, 'Dimension.doc attribute not initialized.'
        # ezdxf uses internally only resource names for arrows, line types and
        # text styles, but DXF 2000 and later requires handles for these
        # resources:
        actual_dxfversion = self.doc.dxfversion
        data = self.dim_style_attr_names_to_handles(data, actual_dxfversion)
        tags = []
        dim_style_attributes = self.dim_style_attributes()
        for key, value in data.items():
            if key not in dim_style_attributes:
                logging.warning(f'Ignore unknown DIMSTYLE attribute: "{key}"')
                continue
            dxf_attr = dim_style_attributes.get(key)
            # Skip internal and virtual tags:
            if dxf_attr and dxf_attr.code > 0:
                if dxf_attr.dxfversion > actual_dxfversion:
                    logging.warning(
                        f'Unsupported DIMSTYLE attribute "{key}" for '
                        f'DXF version {self.doc.acad_release}'
                    )
                    continue
                code = dxf_attr.code
                tags.append((1070, code))
                if code == 5:
                    # DimStyle 'dimblk' has group code 5 but is not a handle
                    tags.append((1000, value))
                else:
                    tags.append((get_xcode_for(code), value))

        if len(tags):
            self.set_xdata_list('ACAD', 'DSTYLE', tags)

    def dim_style_attr_handles_to_names(self, data: dict) -> dict:
        """ `ezdxf` uses internally only resource names for arrows, line types
        and text styles, but DXF 2000 and later requires handles for these
        resources, this method translates resource handles into related names.
        (e.g. 'dimtxsty_handle', <handle of FancyStyle> -> 'dimtxsty': 'FancyStyle')

        Args:
            data: dictionary of overridden DimStyle attributes as handles,
                requires DXF R2000+

        Returns: dictionary with resource as handles replaced by names

        Raises:
            DXFTableEntry: text style or line type does not exist
            DXFKeyError: referenced block does not exist

        (internal API)

        """
        data = dict(data)
        db = self.doc.entitydb

        def set_arrow_name(attrib_name: str, handle: str):
            # Special handle for default arrow CLOSEDFILLED:
            if handle == '0':
                # Special name for default arrow CLOSEDFILLED:
                data[attrib_name] = ''
                return
            try:
                block_record = db[handle]
            except KeyError:
                logger.warning(
                    f'Required arrow block #{handle} does not exist, '
                    f'ignoring {attrib_name.upper()} override.'
                )
                return
            name = block_record.dxf.name
            # Translate block name into ACAD standard name _OPEN30 -> OPEN30
            if name.startswith('_'):
                acad_arrow_name = name[1:]
                if ARROWS.is_acad_arrow(acad_arrow_name):
                    name = acad_arrow_name
            data[attrib_name] = name

        def set_ltype_name(attrib_name: str, handle: str):
            try:
                ltype = db[handle]
            except KeyError:
                logger.warning(
                    f'Required line type #{handle} does not exist, '
                    f'ignoring {attrib_name.upper()} override.'
                )
            else:
                data[attrib_name] = ltype.dxf.name

        # transform block record handles into block names
        for attrib_name in ('dimblk', 'dimblk1', 'dimblk2', 'dimldrblk'):
            blkrec_handle = data.pop(attrib_name + '_handle', None)
            if blkrec_handle:
                set_arrow_name(attrib_name, blkrec_handle)

        # replace 'dimtxsty_handle' attribute by 'dimtxsty'
        dimtxsty_handle = data.pop('dimtxsty_handle', None)
        if dimtxsty_handle:
            try:
                txtstyle = db[dimtxsty_handle]
            except KeyError:
                logger.warning(
                    f'Required text style #{dimtxsty_handle} does not exist, '
                    f'ignoring DIMTXSTY override.'
                )
            else:
                data['dimtxsty'] = txtstyle.dxf.name

        # transform linetype handles into LTYPE entry names
        for attrib_name in ('dimltype', 'dimltex1', 'dimltex2'):
            handle = data.pop(attrib_name + '_handle', None)
            if handle:
                set_ltype_name(attrib_name, handle)
        return data

    def get_acad_dstyle(self, dim_style: 'DimStyle') -> dict:
        """ Get XDATA section ACAD:DSTYLE, to override DIMSTYLE attributes for
        this DIMENSION entity. Returns a ``dict`` with DIMSTYLE attribute names
        as keys.

        (internal API)
        """
        try:
            data = self.get_xdata_list('ACAD', 'DSTYLE')
        except DXFValueError:
            return {}
        attribs = {}
        codes = dim_style.CODE_TO_DXF_ATTRIB
        for code_tag, value_tag in take2(data):
            group_code = code_tag.value
            value = value_tag.value
            if group_code in codes:
                attribs[codes[group_code]] = value
        return self.dim_style_attr_handles_to_names(attribs)


@register_entity
class Dimension(DXFGraphic, OverrideMixin):
    """ DXF DIMENSION entity """
    DXFTYPE = 'DIMENSION'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_dimension,
                               acdb_dimension_dummy)
    LINEAR = 0
    ALIGNED = 1
    ANGULAR = 2
    DIAMETER = 3
    RADIUS = 4
    ANGULAR_3P = 5
    ORDINATE = 6
    ARC = 8
    ORDINATE_TYPE = 64
    USER_LOCATION_OVERRIDE = 128

    # WARNING for destroy() method:
    # Do not destroy associated anonymous block, if DIMENSION is used in a
    # block, the anonymous block may be used by several block references.

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        dxf = super().load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_dimension_group_codes, 2, recover=True)
            processor.fast_load_dxfattribs(
                dxf, acdb_dimension_dummy_group_codes, 3, log=False)
            # Ignore possible 5. subclass AcDbRotatedDimension, which has no
            # content.
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export entity specific data as DXF tags. """
        super().export_entity(tagwriter)
        if tagwriter.dxfversion == DXF12:
            self.dxf.export_dxf_attribs(tagwriter, [
                'geometry', 'dimstyle', 'defpoint', 'text_midpoint', 'insert',
                'dimtype', 'text', 'defpoint2', 'defpoint3', 'defpoint4',
                'defpoint5', 'leader_length', 'angle', 'horizontal_direction',
                'oblique_angle', 'text_rotation'
            ])
            return

        # else DXF2000+
        tagwriter.write_tag2(SUBCLASS_MARKER, acdb_dimension.name)
        dim_type = self.dimtype
        self.dxf.export_dxf_attribs(tagwriter, [
            'version', 'geometry', 'dimstyle', 'defpoint', 'text_midpoint',
            'insert', 'dimtype', 'attachment_point', 'line_spacing_style',
            'line_spacing_factor', 'actual_measurement', 'unknown1',
            'flip_arrow_1', 'flip_arrow_2', 'text', 'oblique_angle',
            'text_rotation', 'horizontal_direction', 'extrusion',
        ])

        if dim_type == 0:  # linear
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbAlignedDimension')
            self.dxf.export_dxf_attribs(tagwriter,
                                        ['defpoint2', 'defpoint3', 'angle'])
            # empty but required subclass
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbRotatedDimension')
        elif dim_type == 1:  # aligned
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbAlignedDimension')
            self.dxf.export_dxf_attribs(tagwriter, [
                'defpoint2', 'defpoint3', 'angle'])
        elif dim_type == 2:  # angular & angular3p
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDb2LineAngularDimension')
            self.dxf.export_dxf_attribs(tagwriter, [
                'defpoint2', 'defpoint3', 'defpoint4', 'defpoint5'])
        elif dim_type == 3:  # diameter
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbDiametricDimension')
            self.dxf.export_dxf_attribs(tagwriter, [
                'defpoint4', 'leader_length'])
        elif dim_type == 4:  # radius
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbRadialDimension')
            self.dxf.export_dxf_attribs(tagwriter, [
                'defpoint4', 'leader_length'])
        elif dim_type == 5:  # angular & angular3p
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDb3PointAngularDimension')
            self.dxf.export_dxf_attribs(tagwriter, [
                'defpoint2', 'defpoint3', 'defpoint4', 'defpoint5'])
        elif dim_type == 6:  # ordinate
            tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbOrdinateDimension')
            self.dxf.export_dxf_attribs(tagwriter, ['defpoint2', 'defpoint3'])

    @property
    def dimtype(self) -> int:
        """ :attr:`dxf.dimtype` without binary flags (32, 62, 128). """
        # undocumented ARC_DIMENSION = 8
        return self.dxf.dimtype & 15

    # Special DIMENSION - Dimensional constraints
    # No information in the DXF reference:
    # layer name is "*ADSK_CONSTRAINTS"
    # missing group code 2 - geometry block name
    # missing group code 70 - dimension type
    # has reactor to ACDBASSOCDEPENDENCY object
    # Autodesk example: architectural_example-imperial.dxf
    @property
    def is_dimensional_constraint(self) -> bool:
        """ Returns ``True`` if the DIMENSION entity is a dimensional
        constrains object.
        """
        dxf = self.dxf
        return not dxf.hasattr('dimtype') and \
               dxf.layer == ADSK_CONSTRAINTS

    def get_geometry_block(self) -> Optional['BlockLayout']:
        """ Returns :class:`~ezdxf.layouts.BlockLayout` of associated anonymous
        dimension block, which contains the entities that make up the dimension
        picture. Returns ``None`` if block name is not set or the BLOCK itself
        does not exist

        """
        block_name = self.get_dxf_attrib('geometry', '*')
        return self.doc.blocks.get(block_name)

    def get_measurement(self) -> Union[float, Vec3]:
        """ Returns the actual dimension measurement in :ref:`WCS` units, no
        scaling applied for linear dimensions. Returns angle in degrees for
        angular dimension from 2 lines and angular dimension from 3 points.
        Returns vector from origin to feature location for ordinate dimensions.

        """

        def angle_between(v1: Vec3, v2: Vec3) -> float:
            angle = v2.angle_deg - v1.angle_deg
            return angle + 360 if angle < 0 else angle

        if self.dimtype in (0, 1):  # linear, aligned
            return linear_measurement(
                self.dxf.defpoint2,
                self.dxf.defpoint3,
                math.radians(self.dxf.get('angle', 0)),
                self.ocs(),
            )
        elif self.dimtype in (3, 4):  # diameter, radius
            p1 = Vec3(self.dxf.defpoint)
            p2 = Vec3(self.dxf.defpoint4)
            return (p2 - p1).magnitude
        elif self.dimtype == 2:  # angular from 2 lines
            p1 = Vec3(self.dxf.defpoint2)  # 1. point of 1. extension line
            p2 = Vec3(self.dxf.defpoint3)  # 2. point of 1. extension line
            p3 = Vec3(self.dxf.defpoint4)  # 1. point of 2. extension line
            p4 = Vec3(self.dxf.defpoint)  # 2. point of 2. extension line
            dir1 = p2 - p1  # direction of 1. extension line
            dir2 = p4 - p3  # direction of 2. extension line
            return angle_between(dir1, dir2)
        elif self.dimtype == 5:  # angular from 2 lines
            p1 = Vec3(self.dxf.defpoint4)  # center
            p2 = Vec3(self.dxf.defpoint2)  # 1. extension line
            p3 = Vec3(self.dxf.defpoint3)  # 2. extension line
            dir1 = p2 - p1  # direction of 1. extension line
            dir2 = p3 - p1  # direction of 2. extension line
            return angle_between(dir1, dir2)
        elif self.dimtype == 6:  # ordinate
            origin = Vec3(self.dxf.defpoint)
            feature_location = Vec3(self.dxf.defpoint2)
            return feature_location - origin
        else:
            # todo: add ARC_DIMENSION dimtype=8 support
            raise TypeError(f"Unknown DIMENSION type {self.dimtype}.")

    def override(self) -> 'DimStyleOverride':
        """ Returns the :class:`~ezdxf.entities.DimStyleOverride` object. """
        return DimStyleOverride(self)

    def render(self) -> None:
        """ Render graphical representation as anonymous block. """
        # todo: delete existing anonymous block?
        self.override().render()

    def transform(self, m: 'Matrix44') -> 'Dimension':
        """ Transform DIMENSION entity by transformation matrix `m` inplace.

        Raises ``NonUniformScalingError()`` for non uniform scaling.

        .. versionadded:: 0.13

        """

        def transform_if_exist(name: str, func):
            if dxf.hasattr(name):
                dxf.set(name, func(dxf.get(name)))

        dxf = self.dxf
        ocs = OCSTransform(self.dxf.extrusion, m)

        for vertex_name in ('text_midpoint', 'defpoint5', 'insert'):
            transform_if_exist(vertex_name, ocs.transform_vertex)

        for angle_name in ('text_rotation', 'horizontal_direction', 'angle'):
            transform_if_exist(angle_name, ocs.transform_deg_angle)

        for vertex_name in ('defpoint', 'defpoint2', 'defpoint3', 'defpoint4'):
            transform_if_exist(vertex_name, m.transform)

        dxf.extrusion = ocs.new_extrusion
        return self

    def virtual_entities(self) -> Iterable['DXFGraphic']:
        """
        Yields 'virtual' parts of DIMENSION as basic DXF entities like LINE, ARC
        or TEXT.

        This entities are located at the original positions, but are not stored
        in the entity database, have no handle and are not assigned to any
        layout.

        """
        block = self.get_geometry_block()
        if block is not None:
            for entity in block:
                try:
                    yield entity.copy()
                except DXFTypeError:
                    pass

    def explode(self, target_layout: 'BaseLayout' = None) -> 'EntityQuery':
        """
        Explode parts of DIMENSION as basic DXF entities like LINE, ARC or TEXT
        into target layout, if target layout is ``None``, the target layout is
        the layout of the DIMENSION.

        Returns an :class:`~ezdxf.query.EntityQuery` container with all DXF
        primitives.

        Args:
            target_layout: target layout for DXF parts, ``None`` for same layout
                as source entity.

        """
        return explode_entity(self, target_layout)


acdb_arc_dimension = DefSubclass('AcDbArcDimension', {
    'ext_line1_point': DXFAttr(13, xtype=XType.point3d, default=NULLVEC),
    'ext_line2_point': DXFAttr(14, xtype=XType.point3d, default=NULLVEC),
    'arc_center': DXFAttr(15, xtype=XType.point3d, default=NULLVEC),
    'start_angle': DXFAttr(40),  # radians?
    'end_angle': DXFAttr(41),  # radians?
    'is_partial': DXFAttr(70, validator=validator.is_integer_bool),
    'has_leader': DXFAttr(71, validator=validator.is_integer_bool),
    'leader_point1': DXFAttr(16, xtype=XType.point3d, default=NULLVEC),
    'leader_point2': DXFAttr(17, xtype=XType.point3d, default=NULLVEC),
})
acdb_arc_dimension_group_codes = group_code_mapping(acdb_arc_dimension)


@register_entity
class ArcDimension(Dimension):
    """ DXF ARC_DIMENSION entity """
    DXFTYPE = 'ARC_DIMENSION'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_dimension,
                               acdb_arc_dimension)
    MIN_DXF_VERSION_FOR_EXPORT = DXF2000

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        # Skip Dimension loader:
        dxf = super(Dimension, self).load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_dimension_group_codes, 2, recover=True)
            processor.fast_load_dxfattribs(
                dxf, acdb_arc_dimension_group_codes, 3, recover=True)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export entity specific data as DXF tags. """
        super().export_entity(tagwriter)
        tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbArcDimension')
        self.dxf.export_dxf_attribs(tagwriter, [
            'ext_line1_point', 'ext_line2_point', 'arc_center', 'start_angle',
            'end_angle', 'is_partial', 'has_leader', 'leader_point1',
            'leader_point2',
        ])

    def transform(self, m: 'Matrix44') -> 'Dimension':
        """ Transform ARC_DIMENSION entity by transformation matrix `m` inplace.

        Raises ``NonUniformScalingError()`` for non uniform scaling.

        .. versionadded:: 0.13

        """

        def transform_if_exist(name: str, func):
            if dxf.hasattr(name):
                dxf.set(name, func(dxf.get(name)))

        dxf = self.dxf
        ocs = OCSTransform(dxf.extrusion, m)
        super().transform(m)

        for angle_name in ('start_angle', 'end_angle'):
            transform_if_exist(angle_name, ocs.transform_deg_angle)

        for vertex_name in ('leader_point1', 'leader_point2'):
            transform_if_exist(vertex_name, m.transform)

        return self


acdb_radial_dimension_large = DefSubclass('AcDbRadialDimensionLarge', {
    # center_point = def_point from subclass AcDbDimension
    'chord_point': DXFAttr(13, xtype=XType.point3d, default=NULLVEC),
    'override_center': DXFAttr(14, xtype=XType.point3d, default=NULLVEC),
    'jog_point': DXFAttr(15, xtype=XType.point3d, default=NULLVEC),
    'unknown2': DXFAttr(40),
})
acdb_radial_dimension_large_group_codes = group_code_mapping(
    acdb_radial_dimension_large)


# Undocumented DXF entity - OpenDesignAlliance DWG Specification:
# chapter 20.4.30
@register_entity
class RadialDimensionLarge(Dimension):
    """ DXF LARGE_RADIAL_DIMENSION entity """
    DXFTYPE = 'LARGE_RADIAL_DIMENSION'
    DXFATTRIBS = DXFAttributes(base_class, acdb_entity, acdb_dimension,
                               acdb_radial_dimension_large)
    MIN_DXF_VERSION_FOR_EXPORT = DXF2004

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        # Skip Dimension loader:
        dxf = super(Dimension, self).load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_dimension_group_codes, 2, recover=True)
            processor.fast_load_dxfattribs(
                dxf, acdb_radial_dimension_large_group_codes, 3, recover=True)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export entity specific data as DXF tags. """
        super().export_entity(tagwriter)
        tagwriter.write_tag2(SUBCLASS_MARKER, 'AcDbRadialDimensionLarge')
        self.dxf.export_dxf_attribs(tagwriter, [
            'chord_point', 'override_center', 'jog_point', 'unknown2'
        ])

    def transform(self, m: 'Matrix44') -> 'Dimension':
        """ Transform LARGE_RADIAL_DIMENSION entity by transformation matrix
        `m` inplace.

        Raises ``NonUniformScalingError()`` for non uniform scaling.

        .. versionadded:: 0.13

        """

        def transform_if_exist(name: str, func):
            if dxf.hasattr(name):
                dxf.set(name, func(dxf.get(name)))

        dxf = self.dxf
        super().transform(m)
        # todo: are this WCS points?
        for vertex_name in ('chord_point', 'override_center', 'Jog_point'):
            transform_if_exist(vertex_name, m.transform)

        return self


# XDATA extension - meaning unknown
# 1001, ACAD_DSTYLE_DIMRADIAL_EXTENSION
# 1070, 387
# 1070, 1
# 1070, 388
# 1040, 0.0
# 1070, 390
# 1040, 0.0


# todo: DIMASSOC
acdb_dim_assoc = DefSubclass('AcDbDimAssoc', {
    # Handle of dimension object:
    'dimension': DXFAttr(330),

    # Associativity flag (bit-coded)
    # 1 = First point reference
    # 2 = Second point reference
    # 4 = Third point reference
    # 8 = Fourth point reference
    'point_flag': DXFAttr(90),

    'trans_space': DXFAttr(
        70,
        validator=validator.is_integer_bool,
        fixer=validator.fix_integer_bool,
    ),

    # Rotated Dimension type (parallel, perpendicular)
    # Autodesk gone crazy: subclass AcDbOsnapPointRef with group code 1!!!!!
    #  }), DefSubclass('AcDbOsnapPointRef', {
    'rotated_dim_type': DXFAttr(71),

    # Object Osnap type:
    # 0 = None
    # 1 = Endpoint
    # 2 = Midpoint
    # 3 = Center
    # 4 = Node
    # 5 = Quadrant
    # 6 = Intersection
    # 7 = Insertion
    # 8 = Perpendicular
    # 9 = Tangent
    # 10 = Nearest
    # 11 = Apparent intersection
    # 12 = Parallel
    # 13 = Start point
    'osnap_type': DXFAttr(
        72,
        validator=validator.is_in_integer_range(0, 14),
        fixer=validator.fit_into_integer_range(0, 14)
    ),

    # ID of main object (geometry)
    'object_id': DXFAttr(331),

    # Subtype of main object (edge, face)
    'object_subtype': DXFAttr(73),

    # GsMarker of main object (index)
    'object_gs_marker': DXFAttr(91),

    # Handle (string) of Xref object
    'object_xref_id': DXFAttr(301),

    # Geometry parameter for Near Osnap
    'near_param': DXFAttr(40),

    # Osnap point in WCS
    'osnap_point': DXFAttr(10, xtype=XType.point3d),

    # ID of intersection object (geometry)
    'intersect_id': DXFAttr(332),

    # Subtype of intersection object (edge/face)
    'intersect_subtype': DXFAttr(74),

    # GsMarker of intersection object (index)
    'intersect_gs_marker': DXFAttr(92),

    # Handle (string) of intersection Xref object
    'intersect_xref_id': DXFAttr(302),

    # hasLastPointRef flag (true/false)
    'has_last_point_ref': DXFAttr(
        75, validator=validator.is_integer_bool,
        fixer=validator.fix_integer_bool,
    ),
})


def linear_measurement(p1: Vec3, p2: Vec3, angle: float = 0,
                       ocs: 'OCS' = None) -> float:
    """ Returns distance from `p1` to `p2` projected onto ray defined by
    `angle`, `angle` in radians in the xy-plane.

    """
    if ocs is not None and ocs.uz != (0, 0, 1):
        p1 = ocs.to_wcs(p1)
        p2 = ocs.to_wcs(p2)
        # angle in OCS xy-plane
        ocs_direction = Vec3.from_angle(angle)
        measurement_direction = ocs.to_wcs(ocs_direction)
    else:
        # angle in WCS xy-plane
        measurement_direction = Vec3.from_angle(angle)

    t1 = measurement_direction.project(p1)
    t2 = measurement_direction.project(p2)
    return (t2 - t1).magnitude
