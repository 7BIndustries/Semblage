extends Reference

class_name Triggers


"""
Returns the available Action triggers to the caller.
"""
static func get_triggers():
	var triggers  = {
		"Assembly": {
			"trigger": "cq$",
			"edit_trigger": "^\\.Assembly\\(.*\\).*",
			"action": {
				"name": "New Assembly",
				"group": "ASSEMBLY",
				"control": "res://controls/AssemblyControl.gd"
			}
		},
		"add": {
			"trigger": "cq$",
			"edit_trigger": "^\\.add\\(.*\\).*",
			"action": {
				"name": "Add Component (add)",
				"group": "ASSEMBLY",
				"control": "res://controls/AssemblyComponentControl.gd"
			}
		},
		"faces": {
			"trigger": "cq$",
			"edit_trigger": "^\\.faces\\(.*\\).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": "res://controls/SelectorControl.gd"
			}
		},
		"edges": {
			"trigger": "cq$",
			"edit_trigger": "^\\.edges\\(.*\\).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": "res://controls/SelectorControl.gd"
			}
		},
		"vertices": {
			"trigger": "cq$",
			"edit_trigger": "^\\.vertices\\(.*\\).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": "res://controls/SelectorControl.gd"
			}
		},
		"cutBlind": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "\\.cutBlind\\(.*\\)$",
			"action": {
				"name": "Blind Cut (cutBlind)",
				"group": "3D",
				"control": "res://controls/BlindCutControl.gd"
			}
		},
		"box": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.box(.*)$",
			"action": {
				"name": "Box (box)",
				"group": "3D",
				"control": "res://controls/BoxControl.gd"
			}
		},
		"chamfer": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.chamfer\\(.*\\)$",
			"action": {
				"name": "Chamfer (chamfer)",
				"group": "3D",
				"control": "res://controls/ChamferControl.gd"
			}
		},
		"cboreHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.cboreHole\\(.*\\)$",
			"action": {
				"name": "Counter-Bore Hole (cboreHole)",
				"group": "3D",
				"control": "res://controls/CBoreHoleControl.gd"
			}
		},
		"cskHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.cskHole\\(.*\\)$",
			"action": {
				"name": "Counter-Sink Hole (cskHole)",
				"group": "3D",
				"control": "res://controls/CSinkHoleControl.gd"
			}
		},
		"extrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "\\.extrude\\(.*\\)$",
			"action": {
				"name": "Extrude (extrude)",
				"group": "3D",
				"control": "res://controls/ExtrudeControl.gd"
			}
		},
		"fillet": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.fillet\\(.*\\)$",
			"action": {
				"name": "Fillet (fillet)",
				"group": "3D",
				"control": "res://controls/FilletControl.gd"
			}
		},
		"hole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.hole\\(.*\\)$",
			"action": {
				"name": "Hole (hole)",
				"group": "3D",
				"control": "res://controls/HoleControl.gd"
			}
		},
		"loft": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.loft\\(.*\\)$",
			"action": {
				"name": "Loft (loft)",
				"group": "3D",
				"control": "res://controls/LoftControl.gd"
			}
		},
		"revolve": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "\\.revolve\\(.*\\)$",
			"action": {
				"name": "Revolve (revolve)",
				"group": "3D",
				"control": "res://controls/RevolveControl.gd"
			}
		},
		"section": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.section\\(.*\\)$",
			"action": {
				"name": "Section (section)",
				"group": "3D",
				"control": "res://controls/SectionControl.gd"
			}
		},
		"shell": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.shell\\(.*\\)$",
			"action": {
				"name": "Shell (shell)",
				"group": "3D",
				"control": "res://controls/ShellControl.gd"
			}
		},
		"sphere": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.sphere\\(.*\\)$",
			"action": {
				"name": "Sphere (sphere)",
				"group": "3D",
				"control": "res://controls/SphereControl.gd"
			}
		},
		"split": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.split\\(.*\\)$",
			"action": {
				"name": "Split (split)",
				"group": "3D",
				"control": "res://controls/SplitControl.gd"
			}
		},
		"sweep": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.sweep\\(.*\\)$",
			"action": {
				"name": "Sweep (sweep)",
				"group": "3D",
				"control": "res://controls/SweepControl.gd"
			}
		},
		"text": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.text\\(.*\\)$",
			"action": {
				"name": "Text (text)",
				"group": "3D",
				"control": "res://controls/TextControl.gd"
			}
		},
		"cutThruAll": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "\\.cutThruAll\\(.*\\)$",
			"action": {
				"name": "Thru Cut (cutThruAll)",
				"group": "3D",
				"control": "res://controls/ThruCutControl.gd"
			}
		},
		"twistExtrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "\\.twistExtrude\\(.*\\)$",
			"action": {
				"name": "Twist Extrude (twistExtrude)",
				"group": "3D",
				"control": "res://controls/TwistExtrudeControl.gd"
			}
		},
		"wedge": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.wedge\\(.*\\)$",
			"action": {
				"name": "Wedge (wedge)",
				"group": "3D",
				"control": "res://controls/WedgeControl.gd"
			}
		},
		"cut": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.cut\\(.*\\)$",
			"action": {
				"name": "Boolean - Cut (cut)",
				"group": "3D",
				"control": "res://controls/CutControl.gd"
			}
		},
		"intersect": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.intersect\\(.*\\)$",
			"action": {
				"name": "Boolean - Intersect (intersect)",
				"group": "3D",
				"control": "res://controls/IntersectControl.gd"
			}
		},
		"union": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.union\\(.*\\)$",
			"action": {
				"name": "Boolean - Union (union)",
				"group": "3D",
				"control": "res://controls/UnionControl.gd"
			}
		},
		"circle": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.circle\\(.*\\)$",
			"action": {
				"name": "Circle (circle)",
				"group": "2D",
				"control": "res://controls/CircleControl.gd"
			}
		},
		"close": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.close\\(.*\\)$",
			"action": {
				"name": "Close (close)",
				"group": "2D",
				"control": "res://controls/CloseControl.gd"
			}
		},
		"ellipseArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.ellipseArc\\(.*\\)$",
			"action": {
				"name": "Ellipse Arc (ellipseArc)",
				"group": "2D",
				"control": "res://controls/EllipseArcControl.gd"
			}
		},
		"ellipse": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.ellipse\\(.*\\)$",
			"action": {
				"name": "Ellipse (ellipse)",
				"group": "2D",
				"control": "res://controls/EllipseControl.gd"
			}
		},
		"hLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.hLine\\(.*\\)$",
			"action": {
				"name": "Horizontal Line (hLine)",
				"group": "2D",
				"control": "res://controls/HLineControl.gd"
			}
		},
		"hLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.hLineTo\\(.*\\)$",
			"action": {
				"name": "Horizontal Line To (hLineTo)",
				"group": "2D",
				"control": "res://controls/HLineToControl.gd"
			}
		},
		"line": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.line\\(.*\\)$",
			"action": {
				"name": "Line (line)",
				"group": "2D",
				"control": "res://controls/LineControl.gd"
			}
		},
		"lineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.lineTo\\(.*\\)$",
			"action": {
				"name": "Line To (lineTo)",
				"group": "2D",
				"control": "res://controls/LineToControl.gd"
			}
		},
		"mirrorX": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.mirrorX\\(.*\\)$",
			"action": {
				"name": "Mirror X (mirrorX)",
				"group": "2D",
				"control": "res://controls/MirrorXControl.gd"
			}
		},
		"mirrorY": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.mirrorY\\(.*\\)$",
			"action": {
				"name": "Mirror Y (mirrorY)",
				"group": "2D",
				"control": "res://controls/MirrorYControl.gd"
			}
		},
		"move": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.move\\(.*\\)$",
			"action": {
				"name": "Move (move)",
				"group": "2D",
				"control": "res://controls/MoveControl.gd"
			}
		},
		"moveTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.moveTo\\(.*\\)$",
			"action": {
				"name": "Move To (moveTo)",
				"group": "2D",
				"control": "res://controls/MoveToControl.gd"
			}
		},
		"offset2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.offset2D\\(.*\\)$",
			"action": {
				"name": "Offset (offset2D)",
				"group": "2D",
				"control": "res://controls/Offset2DControl.gd"
			}
		},
		"polarArray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.polarArray\\(.*\\)$",
			"action": {
				"name": "Polar Array (polarArray)",
				"group": "2D",
				"control": "res://controls/PolarArrayControl.gd"
			}
		},
		"polarLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.polarLine\\(.*\\)$",
			"action": {
				"name": "Polar Line (polarLine)",
				"group": "2D",
				"control": "res://controls/PolarLineControl.gd"
			}
		},
		"polarLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.polarLineTo\\(.*\\)$",
			"action": {
				"name": "Polar Line To (polarLineTo)",
				"group": "2D",
				"control": "res://controls/PolarLineToControl.gd"
			}
		},
		"polygon": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.polygon\\(.*\\)$",
			"action": {
				"name": "Polygon (polygon)",
				"group": "2D",
				"control": "res://controls/PolygonControl.gd"
			}
		},
		"polyline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.polyline\\(.*\\)$",
			"action": {
				"name": "Polyline (polyline)",
				"group": "2D",
				"control": "res://controls/PolylineControl.gd"
			}
		},
		"pushPoints": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.pushPoints\\(.*\\)$",
			"action": {
				"name": "Push Points (pushPoints)",
				"group": "2D",
				"control": "res://controls/PushPointsControl.gd"
			}
		},
		"radiusArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.radiusArc\\(.*\\)$",
			"action": {
				"name": "Radius Arc (radiusArc)",
				"group": "2D",
				"control": "res://controls/RadiusArcControl.gd"
			}
		},
		"rarray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.rarray\\(.*\\)$",
			"action": {
				"name": "Rectangular Array (rarray)",
				"group": "2D",
				"control": "res://controls/RArrayControl.gd"
			}
		},
		"rect": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.rect\\(.*\\)$",
			"action": {
				"name": "Rectangle (rect)",
				"group": "2D",
				"control": "res://controls/RectControl.gd"
			}
		},
		"sagittaArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.sagittaArc\\(.*\\)$",
			"action": {
				"name": "Sagitta Arc (sagittaArc)",
				"group": "2D",
				"control": "res://controls/SagittaArcControl.gd"
			}
		},
		"slot2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.slot2D\\(.*\\)$",
			"action": {
				"name": "Slot (slot2D)",
				"group": "2D",
				"control": "res://controls/SlotControl.gd"
			}
		},
		"spline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.spline\\(.*\\)$",
			"action": {
				"name": "Spline (spline)",
				"group": "2D",
				"control": "res://controls/SplineControl.gd"
			}
		},
		"tangentArcPoint": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.tangentArcPoint\\(.*\\)$",
			"action": {
				"name": "Tangent Arc Point (tangentArcPoint)",
				"group": "2D",
				"control": "res://controls/TangentArcPointControl.gd"
			}
		},
		"threePointArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.threePointArc\\(.*\\)$",
			"action": {
				"name": "Three Point Arc (threePointArc)",
				"group": "2D",
				"control": "res://controls/ThreePointArcControl.gd"
			}
		},
		"vLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.vLine\\(.*\\)$",
			"action": {
				"name": "Vertical Line (vLine)",
				"group": "2D",
				"control": "res://controls/VLineControl.gd"
			}
		},
		"vLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^\\.vLineTo\\(.*\\)$",
			"action": {
				"name": "Vertical Line To (vLineTo)",
				"group": "2D",
				"control": "res://controls/VLineToControl.gd"
			}
		},
		"Workplane": {
			"trigger": "cq$",
			"edit_trigger": "^\\.Workplane\\(.*\\).*",
			"action": {
				"name": "New Component",
				"group": "WP",
				"control": "res://controls/WorkplaneControl.gd"
			}
		},
		"workplane": {
			"trigger": "cq$",
			"edit_trigger": "^\\.workplane\\(.*\\).*",
			"action": {
				"name": "workplane (workplane)",
				"group": "WP",
				"control": "res://controls/InlineWorkplaneControl.gd"
			}
		},
		"ExistingCompoent": {
			"trigger": "cq$",
			"edit_trigger": "^~$",  # Will not match anything on purpose
			"action": {
				"name": "Existing Component",
				"group": "WP",
				"control": "res://controls/ExistingComponentControl.gd"
			}
		},
		"center": {
			"trigger": "cq$",
			"edit_trigger": "^\\.center\\(.*\\).*",
			"action": {
				"name": "Center (center)",
				"group": "WP",
				"control": "res://controls/CenterControl.gd"
			}
		},
		"rotate": {
			"trigger": "cq$",
			"edit_trigger": "^\\.rotate\\(.*\\).*",
			"action": {
				"name": "Rotate (rotate)",
				"group": "WP",
				"control": "res://controls/RotateControl.gd"
			}
		},
		"rotateAboutCenter": {
			"trigger": "cq$",
			"edit_trigger": "^\\.rotateAboutCenter\\(.*\\).*",
			"action": {
				"name": "Rotate About Center (rotateAboutCenter)",
				"group": "WP",
				"control": "res://controls/RotateAboutCenterControl.gd"
			}
		},
		"translate": {
			"trigger": "cq$",
			"edit_trigger": "^\\.translate\\(.*\\).*",
			"action": {
				"name": "Translate (translate)",
				"group": "WP",
				"control": "res://controls/TranslateControl.gd"
			}
		},
		"import": {
			"trigger": "cq$",
			"edit_trigger": "^\\cq.importers.*\\(.*\\).*",
			"action": {
				"name": "Import (import)",
				"group": "WP",
				"control": "res://controls/ImportComponentControl.gd"
			}
		}
	}
	return triggers
