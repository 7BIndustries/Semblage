# Copyright (c) 2020, Manfred Moitzi
# License: MIT License
import logging
import math
from typing import TYPE_CHECKING, Iterable, Callable, Optional, cast

from ezdxf.entities import factory
from ezdxf.lldxf.const import DXFStructureError, DXFTypeError
from ezdxf.math.transformtools import (
    NonUniformScalingError, InsertTransformationError,
)
from ezdxf.query import EntityQuery

logger = logging.getLogger('ezdxf')

if TYPE_CHECKING:
    from ezdxf.eztypes import Insert, BaseLayout, DXFGraphic, Attrib, Text


def default_logging_callback(entity, reason):
    logger.debug(
        f'(Virtual Block Reference Entities) Ignoring {str(entity)}: "{reason}"')


def explode_block_reference(block_ref: 'Insert',
                            target_layout: 'BaseLayout') -> EntityQuery:
    """ Explode a block reference into DXF primitives.

    Transforms the block entities into the required WCS location by applying the
    block reference attributes `insert`, `extrusion`, `rotation` and the scaling
    values `xscale`, `yscale` and `zscale`.

    Returns an EntityQuery() container with all exploded DXF entities.

    Attached ATTRIB entities are converted to TEXT entities, this is the
    behavior of the BURST command of the AutoCAD Express Tools.

    Args:
        block_ref: Block reference entity (INSERT)
        target_layout: explicit target layout for exploded DXF entities

    .. warning::

        **Non uniform scaling** may lead to incorrect results for text entities
        (TEXT, MTEXT, ATTRIB) and maybe some other entities.

    (internal API)

    """
    if target_layout is None:
        raise DXFStructureError('Target layout is None.')

    if block_ref.doc is None:
        raise DXFStructureError(
            'Block reference has to be assigned to a DXF document.')

    def _explode_single_block_ref(block_ref):
        for entity in virtual_block_reference_entities(block_ref):
            dxftype = entity.dxftype()
            target_layout.add_entity(entity)
            if dxftype == 'DIMENSION':
                # Render a graphical representation for each exploded DIMENSION
                # entity as anonymous block.
                cast('Dimension', entity).render()
            entities.append(entity)

        # Convert attached ATTRIB entities to TEXT entities:
        # This is the behavior of the BURST command of the AutoCAD Express Tools
        for attrib in block_ref.attribs:
            # Attached ATTRIB entities are already located in the WCS
            text = attrib_to_text(attrib)
            target_layout.add_entity(text)
            entities.append(text)

    entitydb = block_ref.doc.entitydb
    assert entitydb is not None, \
        'Exploding a block reference requires an entity database.'

    entities = []
    if block_ref.mcount > 1:
        for virtual_insert in block_ref.multi_insert():
            _explode_single_block_ref(virtual_insert)
    else:
        _explode_single_block_ref(block_ref)

    source_layout = block_ref.get_layout()
    if source_layout is not None:
        # Remove and destroy exploded INSERT if assigned to a layout
        source_layout.delete_entity(block_ref)
    else:
        entitydb.delete_entity(block_ref)
    return EntityQuery(entities)


IGNORE_FROM_ATTRIB = {
    'version', 'prompt', 'tag', 'flags', 'field_length', 'lock_position'
}


def attrib_to_text(attrib: 'Attrib') -> 'Text':
    dxfattribs = attrib.dxfattribs(drop=IGNORE_FROM_ATTRIB)
    # ATTRIB has same owner as INSERT but does not reside in any EntitySpace()
    # and must not deleted from any layout.
    # New TEXT entity has same handle as the replaced ATTRIB entity and replaces
    # the ATTRIB entity in the database.
    text = factory.new('TEXT', dxfattribs=dxfattribs)
    if attrib.doc:
        factory.bind(text, attrib.doc)
    return text


def virtual_block_reference_entities(
        block_ref: 'Insert', skipped_entity_callback: Optional[
            Callable[['DXFGraphic', str], None]] = None) -> Iterable[
    'DXFGraphic']:
    """ Yields 'virtual' parts of block reference `block_ref`. This method is meant
    to examine the the block reference entities without the need to explode the
    block reference. The `skipped_entity_callback()` will be called for all
    entities which are not processed, signature:
    :code:`skipped_entity_callback(entity: DXFGraphic, reason: str)`,
    `entity` is the original (untransformed) DXF entity of the block definition,
    the `reason` string is an explanation why the entity was skipped.

    This entities are located at the 'exploded' positions, but are not stored in
    the entity database, have no handle and are not assigned to any layout.

    Args:
        block_ref: Block reference entity (INSERT)
        skipped_entity_callback: called whenever the transformation of an entity
            is not supported and so was skipped.

    .. warning::

        **Non uniform scaling** may lead to incorrect results for text entities
        (TEXT, MTEXT, ATTRIB) and maybe some other entities.

    (internal API)

    """
    assert block_ref.dxftype() == 'INSERT'
    Ellipse = cast('Ellipse', factory.cls('ELLIPSE'))
    skipped_entity_callback = skipped_entity_callback or default_logging_callback

    def disassemble(layout) -> Iterable['DXFGraphic']:
        for entity in layout:
            # Do not explode ATTDEF entities. Already available in Insert.attribs
            if entity.dxftype() == 'ATTDEF':
                continue
            try:
                copy = entity.copy()
            except DXFTypeError:
                skipped_entity_callback(entity, 'non copyable')
            else:
                if hasattr(copy, 'remove_association'):
                    copy.remove_association()
                yield copy

    def transform(entities):
        for entity in entities:
            try:
                entity.transform(m)
            except NotImplementedError:
                skipped_entity_callback(entity, 'non transformable')
            except NonUniformScalingError:
                dxftype = entity.dxftype()
                if dxftype in {'ARC', 'CIRCLE'}:
                    if not math.isclose(entity.dxf.radius, 0.0):
                        # radius < 0 is ok.
                        yield Ellipse.from_arc(entity).transform(m)
                    else:
                        skipped_entity_callback(
                            entity, f'Invalid radius in entity {str(entity)}.')
                elif dxftype in {'LWPOLYLINE', 'POLYLINE'}:  # has arcs
                    yield from transform(entity.virtual_entities())
                else:
                    skipped_entity_callback(
                        entity, 'unsupported non-uniform scaling')
            except InsertTransformationError:
                # INSERT entity can not represented in the target coordinate
                # system defined by transformation matrix `m`.
                # Yield transformed sub-entities of the INSERT entity:
                yield from transform(
                    virtual_block_reference_entities(
                        entity, skipped_entity_callback))
            else:
                yield entity

    m = block_ref.matrix44()
    block_layout = block_ref.block()
    if block_layout is None:
        raise DXFStructureError(
            f'Required block definition for "{block_ref.dxf.name}" does not exist.')

    yield from transform(disassemble(block_layout))


EXCLUDE_FROM_EXPLODE = {'POINT'}


def explode_entity(
        entity: 'DXFGraphic',
        target_layout: 'BaseLayout' = None) -> 'EntityQuery':
    """ Explode parts of an entity as primitives into target layout, if target
    layout is ``None``, the target layout is the layout of the source entity.

    Returns an :class:`~ezdxf.query.EntityQuery` container with all DXF parts.

    Args:
        entity: DXF entity to explode, has to have a :meth:`virtual_entities()`
            method
        target_layout: target layout for DXF parts, ``None`` for same layout as
            source entity

    (internal API)

    """
    dxftype = entity.dxftype()

    if not hasattr(entity, 'virtual_entities') or \
            dxftype in EXCLUDE_FROM_EXPLODE:
        raise DXFTypeError(f'Can not explode entity {dxftype}.')

    if entity.doc is None:
        raise DXFStructureError(
            f'{dxftype} has to be assigned to a DXF document.')

    entitydb = entity.doc.entitydb
    if entitydb is None:
        raise DXFStructureError(
            f'Exploding {dxftype} requires an entity database.')

    if target_layout is None:
        target_layout = entity.get_layout()
        if target_layout is None:
            raise DXFStructureError(
                f'{dxftype} without layout assigment, specify target layout.')

    entities = []

    for e in entity.virtual_entities():
        target_layout.add_entity(e)
        entities.append(e)

    source_layout = entity.get_layout()
    if source_layout is not None:
        source_layout.delete_entity(entity)
    else:
        entitydb.delete_entity(entity)
    return EntityQuery(entities)
