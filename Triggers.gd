extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"edit_trigger": "^.Workplane(.*).*",
		"action": {
			"name": "New Workplane",
			"group": "WP",
			"control": WorkplaneControl.new()
		}
	},
	"box": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".box(.*)$",
		"action": {
			"name": "box",
			"group": "3D",
			"control": BoxControl.new()
		}
	},
	"cboreHole": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".cboreHole(.*)$",
		"action": {
			"name": "cboreHole",
			"group": "3D",
			"control": CBoreHoleControl.new()
		}
	},
	"chamfer": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".chamfer(.*)$",
		"action": {
			"name": "chamfer",
			"group": "3D",
			"control": ChamferControl.new()
		}
	},
	"cskHole": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".cskHole(.*)$",
		"action": {
			"name": "cskHole",
			"group": "3D",
			"control": CSinkHoleControl.new()
		}
	},
	"cutBlind": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.cutBlind(.*)$",
		"action": {
			"name": "cutBlind",
			"group": "3D",
			"control": BlindCutControl.new()
		}
	},
	"cutThruAll": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.cutThruAll(.*)$",
		"action": {
			"name": "cutThruAll",
			"group": "3D",
			"control": ThruCutControl.new()
		}
	},
	"extrude": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.extrude(.*)$",
		"action": {
			"name": "extrude",
			"group": "3D",
			"control": ExtrudeControl.new()
		}
	},
	"fillet": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".fillet(.*)$",
		"action": {
			"name": "fillet",
			"group": "3D",
			"control": FilletControl.new()
		}
	},
	"hole": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".hole(.*)$",
		"action": {
			"name": "hole",
			"group": "3D",
			"control": HoleControl.new()
		}
	},
	"revolve": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".revolve(.*)$",
		"action": {
			"name": "revolve",
			"group": "3D",
			"control": RevolveControl.new()
		}
	},
	"shell": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".shell(.*)$",
		"action": {
			"name": "shell",
			"group": "3D",
			"control": ShellControl.new()
		}
	},
	"sphere": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".sphere(.*)$",
		"action": {
			"name": "sphere",
			"group": "3D",
			"control": SphereControl.new()
		}
	},
	"split": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".split(.*)$",
		"action": {
			"name": "split",
			"group": "3D",
			"control": SplitControl.new()
		}
	},
	"text": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".text(.*)$",
		"action": {
			"name": "text",
			"group": "3D",
			"control": TextControl.new()
		}
	},
	"twistExtrude": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.twistExtrude(.*)$",
		"action": {
			"name": "twistExtrude",
			"group": "3D",
			"control": TwistExtrudeControl.new()
		}
	},
	"wedge": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".wedge(.*)$",
		"action": {
			"name": "wedge",
			"group": "3D",
			"control": WedgeControl.new()
		}
	},
	"circle": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".circle(.*)$",
		"action": {
			"name": "circle",
			"group": "2D",
			"control": CircleControl.new()
		}
	},
	"close": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".close(.*)$",
		"action": {
			"name": "close",
			"group": "2D",
			"control": CloseControl.new()
		}
	},
	"ellipse": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".ellipse(.*)$",
		"action": {
			"name": "ellipse",
			"group": "2D",
			"control": EllipseControl.new()
		}
	},
	"ellipseArc": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".ellipseArc(.*)$",
		"action": {
			"name": "ellipseArc",
			"group": "2D",
			"control": EllipseArcControl.new()
		}
	},
	"hLine": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".hLine(.*)$",
		"action": {
			"name": "hLine",
			"group": "2D",
			"control": HLineControl.new()
		}
	},
	"hLineTo": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".hLineTo(.*)$",
		"action": {
			"name": "hLineTo",
			"group": "2D",
			"control": HLineToControl.new()
		}
	},
	"line": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".line(.*)$",
		"action": {
			"name": "line",
			"group": "2D",
			"control": LineControl.new()
		}
	},
	"lineTo": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".lineTo(.*)$",
		"action": {
			"name": "lineTo",
			"group": "2D",
			"control": LineToControl.new()
		}
	},
	"mirrorX": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".mirrorX(.*)$",
		"action": {
			"name": "mirrorX",
			"group": "2D",
			"control": MirrorXControl.new()
		}
	},
	"mirrorY": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".mirrorY(.*)$",
		"action": {
			"name": "mirrorY",
			"group": "2D",
			"control": MirrorYControl.new()
		}
	},
	"move": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".move(.*)$",
		"action": {
			"name": "move",
			"group": "2D",
			"control": MoveControl.new()
		}
	},
	"moveTo": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".moveTo(.*)$",
		"action": {
			"name": "moveTo",
			"group": "2D",
			"control": MoveToControl.new()
		}
	},
	"offset2D": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".offset2D(.*)$",
		"action": {
			"name": "offset2D",
			"group": "2D",
			"control": Offset2DControl.new()
		}
	},
	"polarArray": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".polarArray(.*)$",
		"action": {
			"name": "polarArray",
			"group": "2D",
			"control": PolarArrayControl.new()
		}
	},
	"polarLine": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".polarLine(.*)$",
		"action": {
			"name": "polarLine",
			"group": "2D",
			"control": PolarLineControl.new()
		}
	},
	"polarLineTo": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".polarLineTo(.*)$",
		"action": {
			"name": "polarLineTo",
			"group": "2D",
			"control": PolarLineToControl.new()
		}
	},
	"polygon": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".polygon(.*)$",
		"action": {
			"name": "polygon",
			"group": "2D",
			"control": PolygonControl.new()
		}
	},
	"pushPoints": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".pushPoints(.*)$",
		"action": {
			"name": "pushPoints",
			"group": "2D",
			"control": PushPointsControl.new()
		}
	},
	"radiusArc": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".radiusArc(.*)$",
		"action": {
			"name": "radiusArc",
			"group": "2D",
			"control": RadiusArcControl.new()
		}
	},
	"rarray": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".rarray(.*)$",
		"action": {
			"name": "rarray",
			"group": "2D",
			"control": RArrayControl.new()
		}
	},
	"rect": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".rect(.*)$",
		"action": {
			"name": "rect",
			"group": "2D",
			"control": RectControl.new()
		}
	},
	"sagittaArc": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".sagittaArc(.*)$",
		"action": {
			"name": "sagittaArc",
			"group": "2D",
			"control": SagittaArcControl.new()
		}
	},
	"slot2D": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".slot2D(.*)$",
		"action": {
			"name": "slot2D",
			"group": "2D",
			"control": SlotControl.new()
		}
	},
	"tangentArcPoint": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".tangentArcPoint(.*)$",
		"action": {
			"name": "tangentArcPoint",
			"group": "2D",
			"control": TangentArcPointControl.new()
		}
	},
	"threePointArc": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".threePointArc(.*)$",
		"action": {
			"name": "threePointArc",
			"group": "2D",
			"control": ThreePointArcControl.new()
		}
	},
	"vLine": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".vLine(.*)$",
		"action": {
			"name": "vLine",
			"group": "2D",
			"control": VLineControl.new()
		}
	},
	"vLineTo": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".vLineTo(.*)$",
		"action": {
			"name": "vLineTo",
			"group": "2D",
			"control": VLineToControl.new()
		}
	}
}
