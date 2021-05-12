extends Node

class_name Triggers


"""
Returns the available Action triggers to the caller.
"""
static func get_triggers():
	var triggers  = {
		"Workplane": {
			"trigger": "cq$",
			"edit_trigger": "^.Workplane(.*).*",
			"action": {
				"name": "Workplane",
				"group": "WP",
				"control": WorkplaneControl.new()
			}
		},
		"center": {
			"trigger": "cq$",
			"edit_trigger": "^.center(.*).*",
			"action": {
				"name": "Center (center)",
				"group": "WP",
				"control": CenterControl.new()
			}
		},
		"rotate": {
			"trigger": "cq$",
			"edit_trigger": "^.rotate(.*).*",
			"action": {
				"name": "Rotate (rotate)",
				"group": "WP",
				"control": RotateControl.new()
			}
		},
		"rotateAboutCenter": {
			"trigger": "cq$",
			"edit_trigger": "^.rotateAboutCenter(.*).*",
			"action": {
				"name": "Rotate About Center (rotateAboutCenter)",
				"group": "WP",
				"control": RotateAboutCenterControl.new()
			}
		},
		"translate": {
			"trigger": "cq$",
			"edit_trigger": "^.translate(.*).*",
			"action": {
				"name": "Translate (translate)",
				"group": "WP",
				"control": TranslateControl.new()
			}
		},
		"faces": {
			"trigger": "cq$",
			"edit_trigger": "^.faces(.*).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": SelectorControl.new()
			}
		},
		"edges": {
			"trigger": "cq$",
			"edit_trigger": "^.edges(.*).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": SelectorControl.new()
			}
		},
		"vertices": {
			"trigger": "cq$",
			"edit_trigger": "^.vertices(.*).*",
			"action": {
				"name": "selectors",
				"group": "SELECTORS",
				"control": SelectorControl.new()
			}
		},
		"cutBlind": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.cutBlind(.*)$",
			"action": {
				"name": "Blind Cut (cutBlind)",
				"group": "3D",
				"control": BlindCutControl.new()
			}
		},
		"box": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".box(.*)$",
			"action": {
				"name": "Box (box)",
				"group": "3D",
				"control": BoxControl.new()
			}
		},
		"chamfer": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".chamfer(.*)$",
			"action": {
				"name": "Chamfer (chamfer)",
				"group": "3D",
				"control": ChamferControl.new()
			}
		},
		"cboreHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".cboreHole(.*)$",
			"action": {
				"name": "Counter-Bore Hole (cboreHole)",
				"group": "3D",
				"control": CBoreHoleControl.new()
			}
		},
		"cskHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".cskHole(.*)$",
			"action": {
				"name": "Counter-Sink Hole (cskHole)",
				"group": "3D",
				"control": CSinkHoleControl.new()
			}
		},
		"extrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.extrude(.*)$",
			"action": {
				"name": "Extrude (extrude)",
				"group": "3D",
				"control": ExtrudeControl.new()
			}
		},
		"fillet": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".fillet(.*)$",
			"action": {
				"name": "Fillet (fillet)",
				"group": "3D",
				"control": FilletControl.new()
			}
		},
		"hole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hole(.*)$",
			"action": {
				"name": "Hole (hole)",
				"group": "3D",
				"control": HoleControl.new()
			}
		},
		"revolve": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".revolve(.*)$",
			"action": {
				"name": "Revolve (revolve)",
				"group": "3D",
				"control": RevolveControl.new()
			}
		},
		"section": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".section(.*)$",
			"action": {
				"name": "Section (section)",
				"group": "3D",
				"control": SectionControl.new()
			}
		},
		"shell": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".shell(.*)$",
			"action": {
				"name": "Shell (shell)",
				"group": "3D",
				"control": ShellControl.new()
			}
		},
		"sphere": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".sphere(.*)$",
			"action": {
				"name": "Sphere (sphere)",
				"group": "3D",
				"control": SphereControl.new()
			}
		},
		"split": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".split(.*)$",
			"action": {
				"name": "Split (split)",
				"group": "3D",
				"control": SplitControl.new()
			}
		},
		"text": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".text(.*)$",
			"action": {
				"name": "Text (text)",
				"group": "3D",
				"control": TextControl.new()
			}
		},
		"cutThruAll": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.cutThruAll(.*)$",
			"action": {
				"name": "Thru Cut (cutThruAll)",
				"group": "3D",
				"control": ThruCutControl.new()
			}
		},
		"twistExtrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.twistExtrude(.*)$",
			"action": {
				"name": "Twist Extrude (twistExtrude)",
				"group": "3D",
				"control": TwistExtrudeControl.new()
			}
		},
		"wedge": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".wedge(.*)$",
			"action": {
				"name": "Wedge (wedge)",
				"group": "3D",
				"control": WedgeControl.new()
			}
		},
		"circle": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".circle(.*)$",
			"action": {
				"name": "Circle (circle)",
				"group": "2D",
				"control": CircleControl.new()
			}
		},
		"close": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".close(.*)$",
			"action": {
				"name": "Close (close)",
				"group": "2D",
				"control": CloseControl.new()
			}
		},
		"ellipseArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".ellipseArc(.*)$",
			"action": {
				"name": "Ellipse Arc (ellipseArc)",
				"group": "2D",
				"control": EllipseArcControl.new()
			}
		},
		"ellipse": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".ellipse(.*)$",
			"action": {
				"name": "Ellipse (ellipse)",
				"group": "2D",
				"control": EllipseControl.new()
			}
		},
		"hLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hLine(.*)$",
			"action": {
				"name": "Horizontal Line (hLine)",
				"group": "2D",
				"control": HLineControl.new()
			}
		},
		"hLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hLineTo(.*)$",
			"action": {
				"name": "Horizontal Line To (hLineTo)",
				"group": "2D",
				"control": HLineToControl.new()
			}
		},
		"line": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".line(.*)$",
			"action": {
				"name": "Line (line)",
				"group": "2D",
				"control": LineControl.new()
			}
		},
		"lineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".lineTo(.*)$",
			"action": {
				"name": "Line To (lineTo)",
				"group": "2D",
				"control": LineToControl.new()
			}
		},
		"mirrorX": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".mirrorX(.*)$",
			"action": {
				"name": "Mirror X (mirrorX)",
				"group": "2D",
				"control": MirrorXControl.new()
			}
		},
		"mirrorY": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".mirrorY(.*)$",
			"action": {
				"name": "Mirror Y (mirrorY)",
				"group": "2D",
				"control": MirrorYControl.new()
			}
		},
		"move": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".move(.*)$",
			"action": {
				"name": "Move (move)",
				"group": "2D",
				"control": MoveControl.new()
			}
		},
		"moveTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".moveTo(.*)$",
			"action": {
				"name": "Move To (moveTo)",
				"group": "2D",
				"control": MoveToControl.new()
			}
		},
		"offset2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".offset2D(.*)$",
			"action": {
				"name": "Offset (offset2D)",
				"group": "2D",
				"control": Offset2DControl.new()
			}
		},
		"polarArray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarArray(.*)$",
			"action": {
				"name": "Polar Array (polarArray)",
				"group": "2D",
				"control": PolarArrayControl.new()
			}
		},
		"polarLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarLine(.*)$",
			"action": {
				"name": "Polar Line (polarLine)",
				"group": "2D",
				"control": PolarLineControl.new()
			}
		},
		"polarLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarLineTo(.*)$",
			"action": {
				"name": "Polar Line To (polarLineTo)",
				"group": "2D",
				"control": PolarLineToControl.new()
			}
		},
		"polygon": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polygon(.*)$",
			"action": {
				"name": "Polygon (polygon)",
				"group": "2D",
				"control": PolygonControl.new()
			}
		},
		"polyline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polyline(.*)$",
			"action": {
				"name": "Polyline (polyline)",
				"group": "2D",
				"control": PolylineControl.new()
			}
		},
		"pushPoints": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".pushPoints(.*)$",
			"action": {
				"name": "Push Points (pushPoints)",
				"group": "2D",
				"control": PushPointsControl.new()
			}
		},
		"radiusArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".radiusArc(.*)$",
			"action": {
				"name": "Radius Arc (radiusArc)",
				"group": "2D",
				"control": RadiusArcControl.new()
			}
		},
		"rarray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".rarray(.*)$",
			"action": {
				"name": "Rectangular Array (rarray)",
				"group": "2D",
				"control": RArrayControl.new()
			}
		},
		"rect": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".rect(.*)$",
			"action": {
				"name": "Rectangle (rect)",
				"group": "2D",
				"control": RectControl.new()
			}
		},
		"sagittaArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".sagittaArc(.*)$",
			"action": {
				"name": "Sagitta Arc (sagittaArc)",
				"group": "2D",
				"control": SagittaArcControl.new()
			}
		},
		"slot2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".slot2D(.*)$",
			"action": {
				"name": "Slot (slot2D)",
				"group": "2D",
				"control": SlotControl.new()
			}
		},
		"spline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".spline(.*)$",
			"action": {
				"name": "Spline (spline)",
				"group": "2D",
				"control": SplineControl.new()
			}
		},
		"tangentArcPoint": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".tangentArcPoint(.*)$",
			"action": {
				"name": "Tangent Arc Point (tangentArcPoint)",
				"group": "2D",
				"control": TangentArcPointControl.new()
			}
		},
		"threePointArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".threePointArc(.*)$",
			"action": {
				"name": "Three Point Arc (threePointArc)",
				"group": "2D",
				"control": ThreePointArcControl.new()
			}
		},
		"vLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".vLine(.*)$",
			"action": {
				"name": "Vertical Line (vLine)",
				"group": "2D",
				"control": VLineControl.new()
			}
		},
		"vLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".vLineTo(.*)$",
			"action": {
				"name": "Vertical Line To (vLineTo)",
				"group": "2D",
				"control": VLineToControl.new()
			}
		}
	}
	return triggers
