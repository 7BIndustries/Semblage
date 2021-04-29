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
				"control": WorkplaneControl.new(),
				"tooltip": ToolTips.get_tts().workplane_tooltip
			}
		},
		"center": {
			"trigger": "cq$",
			"edit_trigger": "^.center(.*).*",
			"action": {
				"name": "Center (center)",
				"group": "WP",
				"control": CenterControl.new(),
				"tooltip": ToolTips.get_tts().center_tooltip
			}
		},
		"rotate": {
			"trigger": "cq$",
			"edit_trigger": "^.rotate(.*).*",
			"action": {
				"name": "Rotate (rotate)",
				"group": "WP",
				"control": RotateControl.new(),
				"tooltip": ToolTips.get_tts().rotate_tooltip
			}
		},
		"rotateAboutCenter": {
			"trigger": "cq$",
			"edit_trigger": "^.rotateAboutCenter(.*).*",
			"action": {
				"name": "Rotate About Center (rotateAboutCenter)",
				"group": "WP",
				"control": RotateAboutCenterControl.new(),
				"tooltip": ToolTips.get_tts().rotate_about_center_tooltip
			}
		},
		"translate": {
			"trigger": "cq$",
			"edit_trigger": "^.translate(.*).*",
			"action": {
				"name": "Translate (translate)",
				"group": "WP",
				"control": TranslateControl.new(),
				"tooltip": ToolTips.get_tts().translate_tooltip
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
				"control": BlindCutControl.new(),
				"tooltip": ToolTips.get_tts().cut_blind_tooltip
			}
		},
		"box": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".box(.*)$",
			"action": {
				"name": "Box (box)",
				"group": "3D",
				"control": BoxControl.new(),
				"tooltip": ToolTips.get_tts().box_tooltip
			}
		},
		"chamfer": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".chamfer(.*)$",
			"action": {
				"name": "Chamfer (chamfer)",
				"group": "3D",
				"control": ChamferControl.new(),
				"tooltip": ToolTips.get_tts().chamfer_tooltip
			}
		},
		"cboreHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".cboreHole(.*)$",
			"action": {
				"name": "Counter-Bore Hole (cboreHole)",
				"group": "3D",
				"control": CBoreHoleControl.new(),
				"tooltip": ToolTips.get_tts().cbore_hole_tooltip
			}
		},
		"cskHole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".cskHole(.*)$",
			"action": {
				"name": "Counter-Sink Hole (cskHole)",
				"group": "3D",
				"control": CSinkHoleControl.new(),
				"tooltip": ToolTips.get_tts().csk_hole_tooltip
			}
		},
		"extrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.extrude(.*)$",
			"action": {
				"name": "Extrude (extrude)",
				"group": "3D",
				"control": ExtrudeControl.new(),
				"tooltip": ToolTips.get_tts().extrude_tooltip
			}
		},
		"fillet": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".fillet(.*)$",
			"action": {
				"name": "Fillet (fillet)",
				"group": "3D",
				"control": FilletControl.new(),
				"tooltip": ToolTips.get_tts().fillet_tooltip
			}
		},
		"hole": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hole(.*)$",
			"action": {
				"name": "Hole (hole)",
				"group": "3D",
				"control": HoleControl.new(),
				"tooltip": ToolTips.get_tts().hole_tooltip
			}
		},
		"revolve": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".revolve(.*)$",
			"action": {
				"name": "Revolve (revolve)",
				"group": "3D",
				"control": RevolveControl.new(),
				"tooltip": ToolTips.get_tts().revolve_tooltip
			}
		},
		"section": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".section(.*)$",
			"action": {
				"name": "Section (section)",
				"group": "3D",
				"control": SectionControl.new(),
				"tooltip": ToolTips.get_tts().section_tooltip
			}
		},
		"shell": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".shell(.*)$",
			"action": {
				"name": "Shell (shell)",
				"group": "3D",
				"control": ShellControl.new(),
				"tooltip": ToolTips.get_tts().shell_tooltip
			}
		},
		"sphere": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".sphere(.*)$",
			"action": {
				"name": "Sphere (sphere)",
				"group": "3D",
				"control": SphereControl.new(),
				"tooltip": ToolTips.get_tts().sphere_tooltip
			}
		},
		"split": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".split(.*)$",
			"action": {
				"name": "Split (split)",
				"group": "3D",
				"control": SplitControl.new(),
				"tooltip": ToolTips.get_tts().split_tooltip
			}
		},
		"text": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".text(.*)$",
			"action": {
				"name": "Text (text)",
				"group": "3D",
				"control": TextControl.new(),
				"tooltip": ToolTips.get_tts().text_tooltip
			}
		},
		"cutThruAll": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.cutThruAll(.*)$",
			"action": {
				"name": "Thru Cut (cutThruAll)",
				"group": "3D",
				"control": ThruCutControl.new(),
				"tooltip": ToolTips.get_tts().thru_cut_tooltip
			}
		},
		"twistExtrude": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": "^.twistExtrude(.*)$",
			"action": {
				"name": "Twist Extrude (twistExtrude)",
				"group": "3D",
				"control": TwistExtrudeControl.new(),
				"tooltip": ToolTips.get_tts().twist_extrude_tooltip
			}
		},
		"wedge": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".wedge(.*)$",
			"action": {
				"name": "Wedge (wedge)",
				"group": "3D",
				"control": WedgeControl.new(),
				"tooltip": ToolTips.get_tts().wedge_tooltip
			}
		},
		"circle": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".circle(.*)$",
			"action": {
				"name": "Circle (circle)",
				"group": "2D",
				"control": CircleControl.new(),
				"tooltip": ToolTips.get_tts().circle_tooltip
			}
		},
		"close": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".close(.*)$",
			"action": {
				"name": "Close (close)",
				"group": "2D",
				"control": CloseControl.new(),
				"tooltip": ToolTips.get_tts().close_tooltip
			}
		},
		"ellipseArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".ellipseArc(.*)$",
			"action": {
				"name": "Ellipse Arc (ellipseArc)",
				"group": "2D",
				"control": EllipseArcControl.new(),
				"tooltip": ToolTips.get_tts().ellipse_arc_tooltip
			}
		},
		"ellipse": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".ellipse(.*)$",
			"action": {
				"name": "Ellipse (ellipse)",
				"group": "2D",
				"control": EllipseControl.new(),
				"tooltip": ToolTips.get_tts().ellipse_tooltip
			}
		},
		"hLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hLine(.*)$",
			"action": {
				"name": "Horizontal Line (hLine)",
				"group": "2D",
				"control": HLineControl.new(),
				"tooltip": ToolTips.get_tts().hline_tooltip
			}
		},
		"hLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".hLineTo(.*)$",
			"action": {
				"name": "Horizontal Line To (hLineTo)",
				"group": "2D",
				"control": HLineToControl.new(),
				"tooltip": ToolTips.get_tts().hline_to_tooltip
			}
		},
		"line": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".line(.*)$",
			"action": {
				"name": "Line (line)",
				"group": "2D",
				"control": LineControl.new(),
				"tooltip": ToolTips.get_tts().line_tooltip
			}
		},
		"lineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".lineTo(.*)$",
			"action": {
				"name": "Line To (lineTo)",
				"group": "2D",
				"control": LineToControl.new(),
				"tooltip": ToolTips.get_tts().line_to_tooltip
			}
		},
		"mirrorX": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".mirrorX(.*)$",
			"action": {
				"name": "Mirror X (mirrorX)",
				"group": "2D",
				"control": MirrorXControl.new(),
				"tooltip": ToolTips.get_tts().mirror_x_tooltip
			}
		},
		"mirrorY": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".mirrorY(.*)$",
			"action": {
				"name": "Mirror Y (mirrorY)",
				"group": "2D",
				"control": MirrorYControl.new(),
				"tooltip": ToolTips.get_tts().mirror_y_tooltip
			}
		},
		"move": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".move(.*)$",
			"action": {
				"name": "Move (move)",
				"group": "2D",
				"control": MoveControl.new(),
				"tooltip": ToolTips.get_tts().move_tooltip
			}
		},
		"moveTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".moveTo(.*)$",
			"action": {
				"name": "Move To (moveTo)",
				"group": "2D",
				"control": MoveToControl.new(),
				"tooltip": ToolTips.get_tts().move_to_tooltip
			}
		},
		"offset2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".offset2D(.*)$",
			"action": {
				"name": "Offset (offset2D)",
				"group": "2D",
				"control": Offset2DControl.new(),
				"tooltip": ToolTips.get_tts().offset_2d_tooltip
			}
		},
		"polarArray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarArray(.*)$",
			"action": {
				"name": "Polar Array (polarArray)",
				"group": "2D",
				"control": PolarArrayControl.new(),
				"tooltip": ToolTips.get_tts().polar_array_tooltip
			}
		},
		"polarLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarLine(.*)$",
			"action": {
				"name": "Polar Line (polarLine)",
				"group": "2D",
				"control": PolarLineControl.new(),
				"tooltip": ToolTips.get_tts().polar_line_tooltip
			}
		},
		"polarLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polarLineTo(.*)$",
			"action": {
				"name": "Polar Line To (polarLineTo)",
				"group": "2D",
				"control": PolarLineToControl.new(),
				"tooltip": ToolTips.get_tts().polar_line_to_tooltip
			}
		},
		"polygon": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polygon(.*)$",
			"action": {
				"name": "Polygon (polygon)",
				"group": "2D",
				"control": PolygonControl.new(),
				"tooltip": ToolTips.get_tts().polygon_tooltip
			}
		},
		"polyline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".polyline(.*)$",
			"action": {
				"name": "Polyline (polyline)",
				"group": "2D",
				"control": PolylineControl.new(),
				"tooltip": ToolTips.get_tts().polyline_tooltip
			}
		},
		"pushPoints": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".pushPoints(.*)$",
			"action": {
				"name": "Push Points (pushPoints)",
				"group": "2D",
				"control": PushPointsControl.new(),
				"tooltip": ToolTips.get_tts().push_points_tooltip
			}
		},
		"radiusArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".radiusArc(.*)$",
			"action": {
				"name": "Radius Arc (radiusArc)",
				"group": "2D",
				"control": RadiusArcControl.new(),
				"tooltip": ToolTips.get_tts().radius_arc_tooltip
			}
		},
		"rarray": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".rarray(.*)$",
			"action": {
				"name": "Rectangular Array (rarray)",
				"group": "2D",
				"control": RArrayControl.new(),
				"tooltip": ToolTips.get_tts().rarray_tooltip
			}
		},
		"rect": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".rect(.*)$",
			"action": {
				"name": "Rectangle (rect)",
				"group": "2D",
				"control": RectControl.new(),
				"tooltip": ToolTips.get_tts().rect_tooltip
			}
		},
		"sagittaArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".sagittaArc(.*)$",
			"action": {
				"name": "Sagitta Arc (sagittaArc)",
				"group": "2D",
				"control": SagittaArcControl.new(),
				"tooltip": ToolTips.get_tts().sagitta_arc_tooltip
			}
		},
		"slot2D": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".slot2D(.*)$",
			"action": {
				"name": "Slot (slot2D)",
				"group": "2D",
				"control": SlotControl.new(),
				"tooltip": ToolTips.get_tts().slot_tooltip
			}
		},
		"spline": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".spline(.*)$",
			"action": {
				"name": "Spline (spline)",
				"group": "2D",
				"control": SplineControl.new(),
				"tooltip": ToolTips.get_tts().spline_tooltip
			}
		},
		"tangentArcPoint": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".tangentArcPoint(.*)$",
			"action": {
				"name": "Tangent Arc Point (tangentArcPoint)",
				"group": "2D",
				"control": TangentArcPointControl.new(),
				"tooltip": ToolTips.get_tts().tangent_arc_point_tooltip
			}
		},
		"threePointArc": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".threePointArc(.*)$",
			"action": {
				"name": "Three Point Arc (threePointArc)",
				"group": "2D",
				"control": ThreePointArcControl.new(),
				"tooltip": ToolTips.get_tts().three_point_arc_tooltip
			}
		},
		"vLine": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".vLine(.*)$",
			"action": {
				"name": "Vertical Line (vLine)",
				"group": "2D",
				"control": VLineControl.new(),
				"tooltip": ToolTips.get_tts().vline_tooltip
			}
		},
		"vLineTo": {
			"trigger": "\\..*(.*)$",
			"edit_trigger": ".vLineTo(.*)$",
			"action": {
				"name": "Vertical Line To (vLineTo)",
				"group": "2D",
				"control": VLineToControl.new(),
				"tooltip": ToolTips.get_tts().vline_to_tooltip
			}
		}
	}
	return triggers
