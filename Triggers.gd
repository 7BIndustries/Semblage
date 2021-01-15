extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"edit_trigger": "^.Workplane(.*).*",
		"action": {
			"name": "New Workplane",
			"group": "All",
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
	"pushPoints": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".pushPoints(.*)$",
		"action": {
			"name": "pushPoints",
			"group": "2D",
			"control": PushPointsControl.new()
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
	"slot": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".slot2D(.*)$",
		"action": {
			"name": "slot",
			"group": "2D",
			"control": SlotControl.new()
		}
	}
}
