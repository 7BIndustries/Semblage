# Copyright (c) 2019-2020, Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, Optional
import logging
from ezdxf.lldxf import validator
from ezdxf.lldxf.attributes import (
    DXFAttr, DXFAttributes, DefSubclass, RETURN_DEFAULT, group_code_mapping
)
from ezdxf.lldxf.const import (
    DXF12, SUBCLASS_MARKER, DXF2007,
    DXFInternalEzdxfError,
)
from ezdxf.entities.dxfentity import base_class, SubclassProcessor, DXFEntity
from ezdxf.entities.layer import acdb_symbol_table_record

from .factory import register_entity

logger = logging.getLogger('ezdxf')

if TYPE_CHECKING:
    from ezdxf.eztypes import (
        TagWriter, DXFNamespace, Block, EndBlk, DXFGraphic,
        EntitySpace, BlockLayout,
    )

__all__ = ['BlockRecord']

acdb_blockrec = DefSubclass('AcDbBlockTableRecord', {
    'name': DXFAttr(2, validator=validator.is_valid_block_name),
    # handle to associated DXF LAYOUT object
    'layout': DXFAttr(340, default='0'),
    # 0 = can not explode; 1 = can explode
    'explode': DXFAttr(280, default=1, dxfversion=DXF2007,
                       validator=validator.is_integer_bool,
                       fixer=RETURN_DEFAULT
                       ),
    # 0 = scale non uniformly; 1 = scale uniformly
    'scale': DXFAttr(281, default=0, dxfversion=DXF2007,
                     validator=validator.is_integer_bool,
                     fixer=RETURN_DEFAULT,
                     ),
    # see ezdxf/units.py
    'units': DXFAttr(70, default=0, dxfversion=DXF2007,
                     validator=validator.is_in_integer_range(0, 25),
                     fixer=RETURN_DEFAULT
                     ),
    # 310: Binary data for bitmap preview (optional) - removed (ignored) by ezdxf
})
acdb_blockrec_group_codes = group_code_mapping(acdb_blockrec)

# optional XDATA for all DXF versions
# 1000: "ACAD"
# 1001: "DesignCenter Data" (optional)
# 1002: "{"
# 1070: Autodesk Design Center version number
# 1070: Insert units: like 'units'
# 1002: "}"


@register_entity
class BlockRecord(DXFEntity):
    """ DXF BLOCK_RECORD table entity

    BLOCK_RECORD is the hard owner of all entities in BLOCK definitions, this
    means owner tag of entities is handle of BLOCK_RECORD.

    """
    DXFTYPE = 'BLOCK_RECORD'
    DXFATTRIBS = DXFAttributes(base_class, acdb_symbol_table_record,
                               acdb_blockrec)

    def __init__(self):
        from ezdxf.entitydb import EntitySpace
        super().__init__()
        # Store entities in the block_record instead of BlockLayout and Layout,
        # because BLOCK_RECORD is also the hard owner of all the entities.
        self.entity_space = EntitySpace()
        self.block: Optional[Block] = None
        self.endblk: Optional[EndBlk] = None
        # stores also the block layout structure
        self.block_layout: Optional[BlockLayout] = None

    def set_block(self, block: 'Block', endblk: 'EndBlk'):
        self.block = block
        self.endblk = endblk
        self.block.dxf.owner = self.dxf.handle
        self.endblk.dxf.owner = self.dxf.handle

    def set_entity_space(self, entity_space: 'EntitySpace') -> None:
        self.entity_space = entity_space

    def rename(self, name: str) -> None:
        self.dxf.name = name
        self.block.dxf.name = name

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> 'DXFNamespace':
        dxf = super().load_dxf_attribs(processor)
        if processor:
            processor.fast_load_dxfattribs(dxf, acdb_blockrec_group_codes, 2)
        return dxf

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        super().export_entity(tagwriter)
        if tagwriter.dxfversion == DXF12:
            raise DXFInternalEzdxfError('Exporting BLOCK_RECORDS for DXF R12.')
        tagwriter.write_tag2(SUBCLASS_MARKER, acdb_symbol_table_record.name)
        tagwriter.write_tag2(SUBCLASS_MARKER, acdb_blockrec.name)

        self.dxf.export_dxf_attribs(tagwriter, [
            'name', 'layout', 'units', 'explode', 'scale',
        ])

    def export_block_definition(self, tagwriter: 'TagWriter') -> None:
        """ Exports BLOCK, than all DXF entities and at last the ENDBLK entity,
        except for *Model_space and *Paper_Pacer, their entities are stored
        in the entities section.

        """
        if self.block_layout is not None:
            self.block_layout.update_block_flags()
        self.block.export_dxf(tagwriter)
        if not (self.is_modelspace or self.is_active_paperspace):
            self.entity_space.export_dxf(tagwriter)
        self.endblk.export_dxf(tagwriter)

    def destroy(self):
        """ Destroy associated data:

            - BLOCK
            - ENDBLK
            - all entities stored in this block definition

        Does not destroy the linked LAYOUT entity, this is the domain of the
        :class:`Layouts` object, which also should initiate the destruction of
        'this' BLOCK_RECORD.

        """
        if not self.is_alive:
            return

        self.block.destroy()
        self.endblk.destroy()
        for entity in self.entity_space:
            entity.destroy()

        # remove attributes to find invalid access after death
        del self.block
        del self.endblk
        del self.block_layout
        super().destroy()

    @property
    def is_active_paperspace(self) -> bool:
        """ ``True`` if is "active" paperspace layout. """
        return self.dxf.name.lower() == '*paper_space'

    @property
    def is_any_paperspace(self) -> bool:
        """ ``True`` if is any kind of paperspace layout. """
        return self.dxf.name.lower().startswith('*paper_space')

    @property
    def is_modelspace(self) -> bool:
        """ ``True`` if is the modelspace layout. """
        return self.dxf.name.lower() == '*model_space'

    @property
    def is_any_layout(self) -> bool:
        """ ``True`` if is any kind of modelspace or paperspace layout. """
        return self.is_modelspace or self.is_any_paperspace

    @property
    def is_block_layout(self) -> bool:
        """ ``True`` if not any kind of modelspace or paperspace layout, just a
        regular block definition.
        """
        return not self.is_any_layout

    def add_entity(self, entity: 'DXFGraphic') -> None:
        """ Add an existing DXF entity to BLOCK_RECORD.

        Args:
            entity: :class:`DXFGraphic`

        """
        # assign layout
        if hasattr(entity, 'set_owner'):
            entity.set_owner(self.dxf.handle,
                             paperspace=int(self.is_any_paperspace))
        else:
            logger.debug('Unexpected entity {}'.format(entity))
        self.entity_space.add(entity)

    def unlink_entity(self, entity: 'DXFGraphic') -> None:
        """ Unlink `entity` from BLOCK_RECORD.

        Removes `entity` just from  entity space but not from the drawing
        database.

        Args:
            entity: :class:`DXFGraphic`

        """
        if entity.is_alive:
            self.entity_space.remove(entity)
            entity.set_owner(None)

    def delete_entity(self, entity: 'DXFGraphic') -> None:
        """ Delete `entity` from BLOCK_RECORD entity space and drawing database.

        Args:
            entity: :class:`DXFGraphic`

        """
        self.unlink_entity(entity)  # 1. unlink from entity space
        entity.destroy()
