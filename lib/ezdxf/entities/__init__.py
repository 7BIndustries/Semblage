# Copyright (c) 2019-2020 Manfred Moitzi
# License: MIT License
# Created 2019-02-13

# first factory
from . import factory

# basic classes
from .xdict import ExtensionDict
from .xdata import XData, EmbeddedObjects
from .appdata import AppData, Reactors
from .dxfentity import DXFEntity
from .dxfgfx import DXFGraphic, SeqEnd
from .dxfobj import DXFObject
from .dxfns import DXFNamespace, SubclassProcessor

# register management structures
from .dxfclass import DXFClass
from .table import TableHead

# register table entries
from .ltype import Linetype
from .layer import Layer
from .textstyle import Textstyle
from .dimstyle import DimStyle
from .view import View
from .vport import VPort
from .ucs import UCSTable
from .appid import AppID
from .blockrecord import BlockRecord

# register DXF objects R2000
from .dxfobj import XRecord, Placeholder, VBAProject, SortEntsTable
from .dictionary import Dictionary, DictionaryVar, DictionaryWithDefault
from .layout import DXFLayout
from .idbuffer import IDBuffer
from .sun import Sun
from .material import Material, MaterialCollection

# register DXF objects R2007
from .visualstyle import VisualStyle

# register entities R12
from .line import Line
from .point import Point
from .circle import Circle
from .arc import Arc
from .shape import Shape
from .solid import Solid, Face3d, Trace
from .text import Text
from .subentity import LinkedEntities, entity_linker
from .insert import Insert
from .block import Block, EndBlk
from .polyline import Polyline, Polyface, Polymesh, MeshVertexCache
from .attrib import Attrib, AttDef
from .dimension import Dimension, ArcDimension
from .dimstyleoverride import DimStyleOverride
from .viewport import Viewport

# register graphical entities R2000
from .lwpolyline import LWPolyline
from .ellipse import Ellipse
from .xline import XLine, Ray
from .mtext import MText
from .spline import Spline
from .mesh import Mesh, MeshData
from .hatch import (
    Hatch, BoundaryPaths, PolylinePath, EdgePath, LineEdge,
    ArcEdge, EllipseEdge, SplineEdge, Pattern, PatternLine, Gradient,
)
from .image import Image, ImageDef, Wipeout
from .underlay import (
    Underlay, UnderlayDefinition, PdfUnderlay, DgnUnderlay,
    DwfUnderlay,
)
from .leader import Leader
from .tolerance import Tolerance
from .helix import Helix
from .acis import (
    Body, Solid3d, Region, Surface, ExtrudedSurface,
    LoftedSurface, RevolvedSurface, SweptSurface,
)
from .mline import MLine, MLineVertex, MLineStyle, MLineStyleCollection
from .mleader import MLeader, MLeaderStyle, MLeaderStyleCollection

# register graphical entities R2004

# register graphical entities R2007

from .light import Light

# register graphical entities R2010

from .geodata import GeoData

# register graphical entities R2013

# register graphical entities R2018
