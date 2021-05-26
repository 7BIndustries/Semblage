# Copyright (c) 2019-2020 Manfred Moitzi
# License: MIT License
""" :class:`DXFEntity` is the super class of all DXF entities.

The current entity system uses the features of the latest supported DXF version.

The stored DXF version of the document is used to warn users if they use
unsupported DXF features of the current DXF version.

The DXF version of the document can be changed at runtime or overridden by
exporting, but unsupported DXF features are just ignored by exporting.

Ezdxf does no conversion between different DXF versions, this package is
still not a CAD application.

"""
from typing import (
    TYPE_CHECKING, List, Dict, Any, Iterable, Optional, Type, TypeVar, Set,
    Callable,
)
import copy
import logging
import uuid
from ezdxf import options
from ezdxf.lldxf import const
from ezdxf.lldxf.tags import Tags
from ezdxf.lldxf.extendedtags import ExtendedTags
from ezdxf.lldxf.attributes import DXFAttr, DXFAttributes, DefSubclass
from ezdxf.tools import set_flag_state
from . import factory
from .appdata import AppData, Reactors
from .dxfns import DXFNamespace, SubclassProcessor
from .xdata import XData, EmbeddedObjects
from .xdict import ExtensionDict

logger = logging.getLogger('ezdxf')

if TYPE_CHECKING:
    from ezdxf.eztypes import Auditor, TagWriter, Drawing, DXFAttr

__all__ = ['DXFEntity', 'DXFTagStorage', 'base_class', 'SubclassProcessor']

base_class = DefSubclass(None, {
    'handle': DXFAttr(5),

    # owner: Soft-pointer ID/handle to owner BLOCK_RECORD object
    # This tag is not supported by DXF R12, but is used intern to unify entity
    # handling between DXF R12 and DXF R2000+
    # Do not write this tag into DXF R12 files!
    'owner': DXFAttr(330),

    # Application defined data can only appear here:
    # 102, {APPID ... multiple entries possible DXF R12?
    # 102, {ACAD_REACTORS ... one entry DXF R2000+, optional
    # 102, {ACAD_XDICTIONARY  ... one entry DXF R2000+, optional
})

T = TypeVar('T', bound='DXFEntity')


class DXFEntity:
    """ Common super class for all DXF entities. """
    DXFTYPE = 'DXFENTITY'  # storing as class var needs less memory
    DXFATTRIBS = DXFAttributes(base_class)  # DXF attribute definitions

    # Default DXF attributes are set at instantiating a new object, the the
    # difference to attribute default values is, that this attributes are
    # really set, this means there is an real object in the dxf namespace
    # defined, where default attribute values get returned on access without
    # an existing object in the dxf namespace.
    DEFAULT_ATTRIBS: Dict = {}
    MIN_DXF_VERSION_FOR_EXPORT = const.DXF12

    def __init__(self):
        """ Default constructor. (internal API)"""
        # Public attributes for package users
        self.doc: Optional[Drawing] = None
        self.dxf: DXFNamespace = DXFNamespace(entity=self)

        # None public attributes for package users
        # create extended data only if needed:
        self.appdata: Optional[AppData] = None
        self.reactors: Optional[Reactors] = None
        self.extension_dict: Optional[ExtensionDict] = None
        self.xdata: Optional[XData] = None
        # TODO: remove embedded_objects - no need to waste memory for every entity,
        #  this is a seldom used feature (ATTRIB, ATTDEF), and this entities have to
        #  manage the embedded objects by itself at loading stage and DXF export.
        #  Removing is possible if ATTRIB and ATTDEF have explicit
        #  support for embedded MTEXT objects
        self.embedded_objects: Optional[EmbeddedObjects] = None
        self.proxy_graphic: Optional[bytes] = None
        # self._uuid  # uuid generated at first request

    @property
    def uuid(self) -> uuid.UUID:
        """ Returns an UUID, which allows to distinguish even
        virtual entities without a handle.

        This UUID will be created at the first request.

        """
        uuid_ = getattr(self, '_uuid', None)
        if uuid_ is None:
            uuid_ = uuid.uuid4()
            self._uuid = uuid_
        return uuid_

    @classmethod
    def new(cls: Type[T], handle: str = None, owner: str = None,
            dxfattribs: Dict = None, doc: 'Drawing' = None) -> T:
        """ Constructor for building new entities from scratch by ezdxf.

        NEW process:

        This is a trusted environment where everything is under control of
        ezdxf respectively the package-user, it is okay to raise exception
        to show implementation errors in ezdxf or usage errors of the
        package-user.

        The :attr:`Drawing.is_loading` flag can be checked to distinguish the
        NEW and the LOAD process.

        Args:
            handle: unique DXF entity handle or None
            owner: owner handle if entity has an owner else None or '0'
            dxfattribs: DXF attributes
            doc: DXF document

        (internal API)
        """
        entity = cls()
        entity.doc = doc
        entity.dxf.handle = handle
        entity.dxf.owner = owner
        attribs = dict(cls.DEFAULT_ATTRIBS)
        attribs.update(dxfattribs or {})
        entity.update_dxf_attribs(attribs)
        # Only this method triggers the post_new_hook()
        entity.post_new_hook()
        return entity

    def post_new_hook(self):
        """ Post processing and integrity validation after entity creation.

        Called only if created by ezdxf (see :meth:`DXFEntity.new`),
        not if loaded from an external source.

        (internal API)
        """
        pass

    def post_bind_hook(self):
        """ Post processing and integrity validation after binding entity to a
        DXF Document. This method is triggered by the :func:`factory.bind`
        function only when the entity was created by ezdxf.

        If the entity was loaded in the 1st loading stage, the
        :func:`factory.load` functions also calls the :func:`factory.bind`
        to bind entities to the loaded document, but not all entities are
        loaded at this time. To avoid problems this method will not be called
        when loading content from DXF file, but :meth:`post_load_hook` will be
        triggered for loaded entities at a later and safer point in time.

        (internal API)
        """
        pass

    @classmethod
    def load(cls: Type[T], tags: ExtendedTags, doc: 'Drawing' = None) -> T:
        """ Constructor to generate entities loaded from an external source.

        LOAD process:

        This is an untrusted environment where valid structure are not
        guaranteed and errors should be fixed, because the package-user is not
        responsible for the problems and also can't fix them, raising
        exceptions should only be done for unrecoverable issues.
        Log fixes for debugging!

            Be more like BricsCAD and not as mean as AutoCAD!

        The :attr:`Drawing.is_loading` flag can be checked to distinguish the
        NEW and the LOAD process.

        Args:
            tags: DXF tags as :class:`ExtendedTags`
            doc: DXF Document

        (internal API)
        """
        # This method does not trigger the post_new_hook()
        entity = cls()
        entity.doc = doc
        dxfversion = doc.dxfversion if doc else None
        entity.load_tags(tags, dxfversion=dxfversion)
        return entity

    def load_tags(self, tags: ExtendedTags, dxfversion: str = None) -> None:
        """ Generic tag loading interface, called if DXF document is loaded
        from external sources.

        1. Loading stage which set the basic DXF attributes, additional
           resources (DXF objects) are not loaded yet. References to these
           resources have to be stored as handles and can be resolved in the
        2. Loading stage: :meth:`post_load_hook`.

        (internal API)
        """
        if tags:
            if len(tags.appdata):
                self.setup_app_data(tags.appdata)
            if len(tags.xdata):
                self.xdata = XData(tags.xdata)
            if tags.embedded_objects:  # TODO: remove
                self.embedded_objects = EmbeddedObjects(
                    tags.embedded_objects)
            processor = SubclassProcessor(tags, dxfversion=dxfversion)
            self.dxf = self.load_dxf_attribs(processor)

    def load_dxf_attribs(
            self, processor: SubclassProcessor = None) -> DXFNamespace:
        """ Load DXF attributes into DXF namespace. """
        return DXFNamespace(processor, self)

    def post_load_hook(self, doc: 'Drawing') -> Optional[Callable]:
        """ The 2nd loading stage when loading DXF documents from an external
        source, for the 1st loading stage see :meth:`load_tags`.

        This stage is meant to convert resource handles into :class:`DXFEntity`
        objects. This is an untrusted environment where valid structure are not
        guaranteed, raise exceptions only for unrecoverable structure errors
        and fix everything else. Log fixes for debugging!

        Some fixes can not be applied at this stage, because some structures
        like the OBJECTS section are not initialized, in this case return a
        callable, which will be executed after the DXF document is fully
        initialized, for an example see :class:`Image`.

        Triggered in method: :meth:`Drawing._2nd_loading_stage`

        Examples for two stage loading:
        Image, Underlay, DXFGroup, Dictionary, Dimstyle

        """
        if self.extension_dict is not None:
            self.extension_dict.load_resources(doc)
        return None

    @classmethod
    def from_text(cls: Type[T], text: str, doc: 'Drawing' = None) -> T:
        """ Load constructor from text for testing. (internal API)"""
        return cls.load(ExtendedTags.from_text(text), doc)

    @classmethod
    def shallow_copy(cls: Type[T], other: 'DXFEntity') -> T:
        """ Copy constructor for type casting e.g. Polyface and Polymesh.
        (internal API)
        """
        entity = cls()
        entity.doc = other.doc
        entity.dxf = other.dxf
        entity.extension_dict = other.extension_dict
        entity.reactors = other.reactors
        entity.appdata = other.appdata
        entity.xdata = other.xdata
        entity.embedded_objects = other.embedded_objects  # todo: remove
        entity.proxy_graphic = other.proxy_graphic
        entity.dxf.rewire(entity)
        return entity

    def copy(self: T) -> T:
        """ Returns a copy of `self` but without handle, owner and reactors.
        This copy is NOT stored in the entity database and does NOT reside
        in any layout, block, table or objects section! Extension dictionary
        and reactors are not copied.

        Don't use this function to duplicate DXF entities in drawing,
        use :meth:`EntityDB.duplicate_entity` instead for this task.

        Copying is not trivial, because of linked resources and the lack of
        documentation how to handle this linked resources: extension dictionary,
        handles in appdata, xdata or embedded objects.

        (internal API)
        """
        entity = self.__class__()
        entity.doc = self.doc
        # copy and bind dxf namespace to new entity
        entity.dxf = self.dxf.copy(entity)
        entity.dxf.reset_handles()

        # Do not copy extension dict: if the extension dict should be copied
        # in the future - a deep copy is maybe required!
        entity.extension_dict = None
        # Do not copy reactors:
        entity.reactors = None

        entity.proxy_graphic = self.proxy_graphic  # immutable bytes

        # if appdata contains handles, they are treated as shared resources
        entity.appdata = copy.deepcopy(self.appdata)

        # if xdata contains handles, they are treated as shared resources
        entity.xdata = copy.deepcopy(self.xdata)

        # if embedded objects contains handles, they are treated as shared resources
        entity.embedded_objects = copy.deepcopy(self.embedded_objects)  # todo: remove
        self._copy_data(entity)
        return entity

    def _copy_data(self, entity: 'DXFEntity') -> None:
        """ Copy entity data like vertices or attribs and store the copies into
        the entity database.
        (internal API)
        """
        pass

    def __deepcopy__(self, memodict: Dict = None):
        """ Some entities maybe linked by more than one entity, to be safe use
        `memodict` for bookkeeping.
        (internal API)
        """
        memodict = memodict or {}
        try:
            return memodict[id(self)]
        except KeyError:
            copy = self.copy()
            memodict[id(self)] = copy
            return copy

    def update_dxf_attribs(self, dxfattribs: Dict) -> None:
        """ Set DXF attributes by a ``dict`` like :code:`{'layer': 'test',
        'color': 4}`.
        """
        setter = self.dxf.set
        for key, value in dxfattribs.items():
            setter(key, value)

    def setup_app_data(self, appdata: List[Tags]) -> None:
        """ Setup data structures from APP data. (internal API) """
        for data in appdata:
            code, appid = data[0]
            if appid == const.ACAD_REACTORS:
                self.reactors = Reactors.from_tags(data)
            elif appid == const.ACAD_XDICTIONARY:
                self.extension_dict = ExtensionDict.from_tags(data)
            else:
                self.set_app_data(appid, data)

    def update_handle(self, handle: str) -> None:
        """ Update entity handle. (internal API) """
        self.dxf.handle = handle
        if self.extension_dict:
            self.extension_dict.update_owner(handle)

    @property
    def is_alive(self):
        """ Returns ``False`` if entity has been deleted. """
        return hasattr(self, 'dxf')

    @property
    def is_virtual(self):
        """ Returns ``True`` if entity is a virtual entity. """
        return self.doc is None or self.dxf.handle is None

    @property
    def is_bound(self):
        """ Returns ``True`` if entity is bound to DXF document. """
        if self.is_alive and not self.is_virtual:
            return factory.is_bound(self, self.doc)
        return False

    def get_dxf_attrib(self, key: str, default: Any = None) -> Any:
        """ Get DXF attribute `key`, returns `default` if key doesn't exist, or
        raise :class:`DXFValueError` if `default` is :class:`DXFValueError`
        and no DXF default value is defined::

            layer = entity.get_dxf_attrib("layer")
            # same as
            layer = entity.dxf.layer

        Raises :class:`DXFAttributeError` if `key` is not an supported DXF
        attribute.

        """
        return self.dxf.get(key, default)

    def set_dxf_attrib(self, key: str, value: Any) -> None:
        """ Set new `value` for DXF attribute `key`::

           entity.set_dxf_attrib("layer", "MyLayer")
           # same as
           entity.dxf.layer = "MyLayer"

        Raises :class:`DXFAttributeError` if `key` is not an supported DXF
        attribute.

        """
        self.dxf.set(key, value)

    def del_dxf_attrib(self, key: str) -> None:
        """ Delete DXF attribute `key`, does not raise an error if attribute is
        supported but not present.

        Raises :class:`DXFAttributeError` if `key` is not an supported DXF
        attribute.

        """
        self.dxf.discard(key)

    def has_dxf_attrib(self, key: str) -> bool:
        """ Returns ``True`` if DXF attribute `key` really exist.

        Raises :class:`DXFAttributeError` if `key` is not an supported DXF
        attribute.

        """
        return self.dxf.hasattr(key)

    dxf_attrib_exists = has_dxf_attrib

    def is_supported_dxf_attrib(self, key: str) -> bool:
        """ Returns ``True`` if DXF attrib `key` is supported by this entity.
        Does not grant that attribute `key` really exist.

        """
        if key in self.DXFATTRIBS:
            if self.doc:
                return self.doc.dxfversion >= self.DXFATTRIBS.get(
                    key).dxfversion
            else:
                return True
        else:
            return False

    def dxftype(self) -> str:
        """ Get DXF type as string, like ``LINE`` for the line entity. """
        return self.DXFTYPE

    def __str__(self) -> str:
        """ Returns a simple string representation. """
        return "{}(#{})".format(self.dxftype(), self.dxf.handle)

    def __repr__(self) -> str:
        """ Returns a simple string representation including the class. """
        return str(self.__class__) + " " + str(self)

    def dxfattribs(self, drop: Set[str] = None) -> Dict:
        """ Returns a ``dict`` with all existing DXF attributes and their
        values and exclude all DXF attributes listed in set `drop`.

        """
        all_attribs = self.dxf.all_existing_dxf_attribs()
        if drop:
            return {k: v for k, v in all_attribs.items() if k not in drop}
        else:
            return all_attribs

    def set_flag_state(self, flag: int, state: bool = True,
                       name: str = 'flags') -> None:
        """ Set binary coded `flag` of DXF attribute `name` to ``1`` (on)
        if `state` is ``True``, set `flag` to ``0`` (off)
        if `state` is ``False``.
        """
        flags = self.dxf.get(name, 0)
        self.dxf.set(name, set_flag_state(flags, flag, state=state))

    def get_flag_state(self, flag: int, name: str = 'flags') -> bool:
        """ Returns ``True`` if any `flag` of DXF attribute is ``1`` (on), else
        ``False``. Always check only one flag state at the time.
        """
        return bool(self.dxf.get(name, 0) & flag)

    def remove_dependencies(self, other: 'Drawing' = None):
        """ Remove all dependencies from current document.

        Intended usage is to remove dependencies from the current document to
        move or copy the entity to `other` DXF document.

        An error free call of this method does NOT guarantee that this entity
        can be moved/copied to the `other` document, some entities like
        DIMENSION have too much dependencies to a document to move or copy
        them, but to check this is not the domain of this method!

        (internal API)
        """
        if self.is_alive:
            self.dxf.owner = None
            self.dxf.handle = None
            self.reactors = None
            self.extension_dict = None
            self.appdata = None
            self.xdata = None
            self.embedded_objects = None  # todo: remove

    def destroy(self) -> None:
        """ Delete all data and references. Does not delete entity from
        structures like layouts or groups.

        Starting with `ezdxf` v0.14 this method could be used to delete
        entities.

        (internal API)

        """
        if not self.is_alive:
            return

        if self.extension_dict is not None:
            self.extension_dict.destroy()
            del self.extension_dict
        del self.appdata
        del self.reactors
        del self.xdata
        del self.embedded_objects  # todo: remove
        del self.doc
        del self.dxf  # check mark for is_alive

    def preprocess_export(self, tagwriter: 'TagWriter') -> bool:
        """ Pre requirement check and pre processing for export.

        Returns False if entity should not be exported at all.

        (internal API)
        """
        return True

    def export_dxf(self, tagwriter: 'TagWriter') -> None:
        """ Export DXF entity by `tagwriter`.

        This is the first key method for exporting DXF entities:

            - has to know the group codes for each attribute
            - has to add subclass tags in correct order
            - has to integrate extended data: ExtensionDict, Reactors, AppData
            - has to maintain the correct tag order (because sometimes order matters)

        (internal API)

        """
        if tagwriter.dxfversion < self.MIN_DXF_VERSION_FOR_EXPORT:
            return
        if not self.preprocess_export(tagwriter):
            return
        # ! first step !
        # write handle, AppData, Reactors, ExtensionDict, owner
        self.export_base_class(tagwriter)

        # this is the entity specific part
        self.export_entity(tagwriter)

        # ! Last step !
        # write xdata, embedded objects
        self.export_embedded_objects(tagwriter)
        self.export_xdata(tagwriter)

    def export_base_class(self, tagwriter: 'TagWriter') -> None:
        """ Export base class DXF attributes and structures. (internal API) """
        dxftype = self.DXFTYPE
        _handle_code = 105 if dxftype == 'DIMSTYLE' else 5
        # 1. tag: (0, DXFTYPE)
        tagwriter.write_tag2(const.STRUCTURE_MARKER, dxftype)

        if tagwriter.dxfversion >= const.DXF2000:
            tagwriter.write_tag2(_handle_code, self.dxf.handle)
            if self.appdata:
                self.appdata.export_dxf(tagwriter)
            if self.has_extension_dict:
                self.extension_dict.export_dxf(tagwriter)
            if self.reactors:
                self.reactors.export_dxf(tagwriter)
            tagwriter.write_tag2(const.OWNER_CODE, self.dxf.owner)
        else:  # DXF R12
            if tagwriter.write_handles:
                tagwriter.write_tag2(_handle_code, self.dxf.handle)
                # do not write owner handle - not supported by DXF R12

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Export DXF entity specific data by `tagwriter`.

        This is the second key method for exporting DXF entities:

            - has to know the group codes for each attribute
            - has to add subclass tags in correct order
            - has to maintain the correct tag order (because sometimes order matters)

        (internal API)
        """
        # base class (handle, appid, reactors, xdict, owner) export is done by parent class
        pass
        # xdata and embedded objects  export is also done by parent

    def export_xdata(self, tagwriter: 'TagWriter') -> None:
        """ Export DXF XDATA by `tagwriter`. (internal API)"""
        if self.xdata:
            self.xdata.export_dxf(tagwriter)

    def export_embedded_objects(self, tagwriter: 'TagWriter') -> None:
        """ Export embedded objects by `tagwriter`. (internal API)"""
        if self.embedded_objects:  # todo: remove
            self.embedded_objects.export_dxf(tagwriter)  # todo: remove

    def audit(self, auditor: 'Auditor') -> None:
        """ Validity check. (internal API) """
        # Important: do not check owner handle! -> DXFGraphic(), DXFObject()
        # check app data
        # check reactors
        # check extension dict
        # check XDATA

    @property
    def has_extension_dict(self) -> bool:
        """ Returns ``True`` if entity has an attached
        :class:`~ezdxf.entities.xdict.ExtensionDict`.
        """
        xdict = self.extension_dict
        # Don't use None check: bool(xdict) for an empty extension dict is False
        if xdict is not None and xdict.is_alive:
            # Check the associated Dictionary object
            dictionary = xdict.dictionary
            if isinstance(dictionary, str):
                # just a handle string - SUT
                return True
            else:
                return dictionary.is_alive
        return False

    def get_extension_dict(self) -> 'ExtensionDict':
        """ Returns the existing :class:`~ezdxf.entities.xdict.ExtensionDict`.

        Raises:
            AttributeError: extension dict does not exist

        """
        if self.has_extension_dict:
            return self.extension_dict
        else:
            raise AttributeError('Entity has no extension dictionary.')

    def new_extension_dict(self) -> 'ExtensionDict':
        self.extension_dict = ExtensionDict.new(self.dxf.handle, self.doc)
        return self.extension_dict

    def has_app_data(self, appid: str) -> bool:
        """ Returns ``True`` if application defined data for `appid` exist. """
        if self.appdata:
            return appid in self.appdata
        else:
            return False

    def get_app_data(self, appid: str) -> Tags:
        """ Returns application defined data for `appid`.

        Args:
            appid: application name as defined in the APPID table.

        Raises:
            DXFValueError: no data for `appid` found

        """
        if self.appdata:
            return self.appdata.get(appid)[1:-1]
        else:
            raise const.DXFValueError(appid)

    def set_app_data(self, appid: str, tags: Iterable) -> None:
        """ Set application defined data for `appid` as iterable of tags.

        Args:
             appid: application name as defined in the APPID table.
             tags: iterable of (code, value) tuples or :class:`~ezdxf.lldxf.types.DXFTag`

        """
        if self.appdata is None:
            self.appdata = AppData()
        self.appdata.add(appid, tags)

    def discard_app_data(self, appid: str):
        """ Discard application defined data for `appid`. Does not raise an
        exception if no data for `appid` exist.
        """
        if self.appdata:
            self.appdata.discard(appid)

    def has_xdata(self, appid: str) -> bool:
        """ Returns ``True`` if extended data for `appid` exist. """
        if self.xdata:
            return appid in self.xdata
        else:
            return False

    def get_xdata(self, appid: str) -> Tags:
        """ Returns extended data for `appid`.

        Args:
            appid: application name as defined in the APPID table.

        Raises:
            DXFValueError: no extended data for `appid` found

        """
        if self.xdata:
            return Tags(self.xdata.get(appid)[1:])
        else:
            raise const.DXFValueError(appid)

    def set_xdata(self, appid: str, tags: Iterable) -> None:
        """ Set extended data for `appid` as iterable of tags.

        Args:
             appid: application name as defined in the APPID table.
             tags: iterable of (code, value) tuples or :class:`~ezdxf.lldxf.types.DXFTag`

        """
        if self.xdata is None:
            self.xdata = XData()
        self.xdata.add(appid, tags)

    def discard_xdata(self, appid: str) -> None:
        """ Discard extended data for `appid`. Does not raise an exception if
        no extended data for `appid` exist.
        """
        if self.xdata:
            self.xdata.discard(appid)

    def has_xdata_list(self, appid: str, name: str) -> bool:
        """ Returns ``True`` if a tag list `name` for extended data `appid`
        exist.
        """
        if self.has_xdata(appid):
            return self.xdata.has_xlist(appid, name)
        else:
            return False

    def get_xdata_list(self, appid: str, name: str) -> Tags:
        """ Returns tag list `name` for extended data `appid`.

        Args:
            appid: application name as defined in the APPID table.
            name: extended data list name

        Raises:
            DXFValueError: no extended data for `appid` found or no data list `name` not found

        """
        if self.xdata:
            return Tags(self.xdata.get_xlist(appid, name))
        else:
            raise const.DXFValueError(appid)

    def set_xdata_list(self, appid: str, name: str, tags: Iterable) -> None:
        """ Set tag list `name` for extended data `appid` as iterable of tags.

        Args:
             appid: application name as defined in the APPID table.
             name: extended data list name
             tags: iterable of (code, value) tuples or :class:`~ezdxf.lldxf.types.DXFTag`

        """
        if self.xdata is None:
            self.xdata = XData()
        self.xdata.set_xlist(appid, name, tags)

    def discard_xdata_list(self, appid: str, name: str) -> None:
        """ Discard tag list `name` for extended data `appid`. Does not raise
        an exception if no extended data for `appid` or no tag list `name`
        exist.
        """
        if self.xdata:
            self.xdata.discard_xlist(appid, name)

    def replace_xdata_list(self, appid: str, name: str, tags: Iterable) -> None:
        """
        Replaces tag list `name` for existing extended data `appid` by `tags`.
        Appends new list if tag list `name` do not exist, but raises
        :class:`DXFValueError` if extended data `appid` do not exist.

        Args:
             appid: application name as defined in the APPID table.
             name: extended data list name
             tags: iterable of (code, value) tuples or :class:`~ezdxf.lldxf.types.DXFTag`

        Raises:
            DXFValueError: no extended data for `appid` found

        """
        self.xdata.replace_xlist(appid, name, tags)

    def has_reactors(self) -> bool:
        """ Returns ``True`` if entity has reactors. """
        return bool(self.reactors)

    def get_reactors(self) -> List[str]:
        """ Returns associated reactors as list of handles. """
        return self.reactors.get() if self.reactors else []

    def set_reactors(self, handles: Iterable[str]) -> None:
        """ Set reactors as list of handles. """
        if self.reactors is None:
            self.reactors = Reactors()
        self.reactors.set(handles)

    def append_reactor_handle(self, handle: str) -> None:
        """ Append `handle` to reactors. """
        if self.reactors is None:
            self.reactors = Reactors()
        self.reactors.add(handle)

    def discard_reactor_handle(self, handle: str) -> None:
        """ Discard `handle` from reactors. Does not raise an exception if
        `handle` does not exist.
        """
        if self.reactors:
            self.reactors.discard(handle)


@factory.set_default_class
class DXFTagStorage(DXFEntity):
    """ Just store all the tags as they are. (internal class) """

    def __init__(self):
        """ Default constructor """
        super().__init__()
        self.xtags: Optional[ExtendedTags] = None

    def copy(self) -> 'DXFEntity':
        raise const.DXFTypeError(
            f'Cloning of tag storage {self.dxftype()} not supported.'
        )

    @property
    def base_class(self):
        return self.xtags.subclasses[0]

    @classmethod
    def load(cls, tags: ExtendedTags, doc: 'Drawing' = None) -> 'DXFTagStorage':
        assert isinstance(tags, ExtendedTags)
        entity = cls.new(doc=doc)
        dxfversion = doc.dxfversion if doc else None
        entity.load_tags(tags, dxfversion=dxfversion)
        entity.store_tags(tags)
        if options.load_proxy_graphics:
            entity.load_proxy_graphic()
        return entity

    def load_proxy_graphic(self) -> Optional[bytes]:
        try:
            acdb_entity = self.xtags.get_subclass('AcDbEntity')
        except const.DXFKeyError:
            return
        binary_data = [tag.value for tag in acdb_entity.find_all(310)]
        if len(binary_data):
            self.proxy_graphic = b''.join(binary_data)

    def store_tags(self, tags: ExtendedTags) -> None:
        # store DXFTYPE, overrides class member
        # 1. tag of 1. subclass is the structure tag (0, DXFTYPE)
        self.xtags = tags
        self.DXFTYPE = self.base_class[0].value
        try:
            acdb_entity = tags.get_subclass('AcDbEntity')
            self.dxf.__dict__['paperspace'] = acdb_entity.get_first_value(67, 0)
        except const.DXFKeyError:
            # just fake it
            self.dxf.__dict__['paperspace'] = 0

    def export_entity(self, tagwriter: 'TagWriter') -> None:
        """ Write subclass tags as they are. """
        for subclass in self.xtags.subclasses[1:]:
            tagwriter.write_tags(subclass)

    def destroy(self) -> None:
        if not self.is_alive:
            return

        del self.xtags
        super().destroy()
