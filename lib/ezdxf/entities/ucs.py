# Copyright (c) 2019-2020, Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING
import logging
from ezdxf.lldxf.attributes import (
    DXFAttr, DXFAttributes, DefSubclass, XType, RETURN_DEFAULT,
    group_code_mapping,
)
from ezdxf.lldxf.const import DXF12, SUBCLASS_MARKER
from ezdxf.lldxf import validator
from ezdxf.math import UCS, NULLVEC, X_AXIS, Y_AXIS
from ezdxf.entities.dxfentity import base_class, SubclassProcessor, DXFEntity
from ezdxf.entities.layer import acdb_symbol_table_record
from .factory import register_entity

logger = logging.getLogger('ezdxf')

if TYPE_CHECKING:
    from ezdxf.eztypes import TagWriter, DXFNamespace

__all__ = ['UCSTable']

acdb_ucs = DefSubclass('AcDbUCSTableRecord', {
    'name': DXFAttr(2, validator=validator.is_valid_table_name),
    'flags': DXFAttr(70, default=0),
    'origin': DXFAttr(10, xtype=XType.point3d, default=NULLVEC),
    'xaxis': DXFAttr(
        11, xtype=XType.point3d, default=X_AXIS,
        validator=validator.is_not_null_vector,
        fixer=RETURN_DEFAULT,
    ),
    'yaxis': DXFAttr(
        12, xtype=XType.point3d, default=Y_AXIS,
        validator=validator.is_not_null_vector,
        fixer=RETURN_DEFAULT,
    ),
})
acdb_ucs_group_codes = group_code_mapping(acdb_ucs)


@register_entity
class UCSTable(DXFEntity):
    """ DXF UCS table entity """
    DXFTYPE = 'UCS'
    DXFATTRIBS = DXFAttributes(base_class, acdb_symbol_table_record, acdb_ucs)

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        dxf = super().load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(
                dxf, acdb_ucs_group_codes, subclass=2)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        super().export_entity(tagwriter)
        if tagwriter.dxfversion > DXF12:
            tagwriter.write_tag2(SUBCLASS_MARKER, acdb_symbol_table_record.name)
            tagwriter.write_tag2(SUBCLASS_MARKER, acdb_ucs.name)

        self.dxf.export_dxf_attribs(tagwriter, [
            'name', 'flags', 'origin', 'xaxis', 'yaxis'
        ])

    def ucs(self) -> UCS:
        """ Returns an :class:`ezdxf.math.UCS` object for this UCS table entry.
        """
        return UCS(
            origin=self.dxf.origin,
            ux=self.dxf.xaxis,
            uy=self.dxf.yaxis,
        )
