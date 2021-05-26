# Copyright (c) 2020, Manfred Moitzi
# License: MIT License
from typing import TYPE_CHECKING, Iterable, Tuple, Dict, Union, List
import heapq

if TYPE_CHECKING:
    from ezdxf.eztypes import DXFGraphic

__all__ = ['ascending', 'descending']

# ODA DWG Specs: 2.13. Handle References
# COUNTER is 4 bits, which allows handles up to 16 * 1 byte = 128-bit
# Example for 128-bit handles: "CADKitSamples\AEC Plan Elev Sample.dxf"
MAX_HANDLE = 'FFFFFFFFFFFFFFFF'
NULL_HANDLE = '0'


def ascending(entities: Iterable['DXFGraphic'],
              mapping: Union[Dict, Iterable[Tuple[str, str]]] = None,
              ) -> Iterable['DXFGraphic']:
    """ Yields entities in ascending handle order.

    The sort handle doesn't have to be the entity handle, every entity handle
    in `mapping` will be replaced by the given sort handle, `mapping` is an
    iterable of 2-tuples (entity_handle, sort_handle) or a
    dict (entity_handle, sort_handle). Entities with equal sort handles show
    up in source entities order.

    Args:
        entities: iterable of :class:`DXFGraphic` objects
        mapping: iterable of 2-tuples (entity_handle, sort_handle) or a
            handle mapping as dict.

    """
    mapping = dict(mapping) if mapping else {}
    heap = _build(entities, mapping, +1)
    return _sorted(heap)


def descending(entities: Iterable['DXFGraphic'],
               mapping: Union[Dict, Iterable[Tuple[str, str]]] = None,
               ) -> Iterable['DXFGraphic']:
    """ Yields entities in descending handle order.

    The sort handle doesn't have to be the entity handle, every entity handle
    in `mapping` will be replaced by the given sort handle, `mapping` is an
    iterable of 2-tuples (entity_handle, sort_handle) or a
    dict (entity_handle, sort_handle). Entities with equal sort handles show
    up in reversed source entities order.

    Args:
        entities: iterable of :class:`DXFGraphic` objects
        mapping: iterable of 2-tuples (entity_handle, sort_handle) or a
            handle mapping as dict.

    """
    mapping = dict(mapping) if mapping else {}
    heap = _build(entities, mapping, -1)
    return _sorted(heap)


def _sorted(heap) -> Iterable['DXFGraphic']:
    """ Yields heap content in order. """
    while heap:
        yield heapq.heappop(heap)[-1]


def _build(entities: Iterable['DXFGraphic'], mapping: Dict, order: int) -> List:
    """ Returns a heap structure.

    Args:
        entities: DXF entities to order
        mapping: handle remapping
        order: +1 for ascending, -1 for descending

    """

    def sort_handle(entity: 'DXFGraphic') -> int:
        handle = entity.dxf.handle
        sort_handle_ = mapping.get(handle, handle)
        if sort_handle_ == NULL_HANDLE:
            # This behavior is defined by AutoCAD but not documented in the
            # DXF reference.
            sort_handle_ = MAX_HANDLE
        return int(sort_handle_, 16)

    heap = []
    for index, entity in enumerate(entities):
        # DXFGraphic is not sortable, using the index as second value avoids
        # a key function and preserves explicit the source order of
        # equal sort handles.
        heapq.heappush(heap, (
            sort_handle(entity) * order,
            index * order,
            entity,
        ))
    return heap
