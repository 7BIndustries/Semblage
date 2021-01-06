extends Node

var triggers  = {
	"Workplane": {
		"group": "all",
		"trigger": "cq$",
		"edit_trigger": "^.Workplane(.*).*",
		"action": {
			"name": "New Workplane",
			"control": WorkplaneControl.new(),
		}
	},
	"box": {
		"group": "3d_primitives",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".box(.*)$",
		"action": {
			"name": "box",
			"control": BoxControl.new()
		}
	},
	"cboreHole": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".cboreHole(.*)$",
		"action": {
			"name": "cboreHole",
			"control": CBoreHoleControl.new()
		}
	},
	"cskHole": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".cskHole(.*)$",
		"action": {
			"name": "cskHole",
			"control": CSinkHoleControl.new()
		}
	},
	"chamfer": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".chamfer(.*)$",
		"action": {
			"name": "chamfer",
			"control": ChamferControl.new()
		}
	},
	"circle": {
		"group": "2d_primitives",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".circle(.*)$",
		"action": {
			"name": "circle",
			"control": CircleControl.new()
		}
	},
	"cutBlind": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.cutBlind(.*)$",
		"action": {
			"name": "cutBlind",
			"control": BlindCutControl.new()
		}
	},
	"cutThruAll": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.cutThruAll(.*)$",
		"action": {
			"name": "cutThruAll",
			"control": ThruCutControl.new()
		}
	},
	"extrude": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.extrude(.*)$",
		"action": {
			"name": "extrude",
			"control": ExtrudeControl.new()
		}
	},
	"fillet": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".fillet(.*)$",
		"action": {
			"name": "fillet",
			"control": FilletControl.new()
		}
	},
	"hole": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".hole(.*)$",
		"action": {
			"name": "hole",
			"control": HoleControl.new()
		}
	},
	"pushPoints": {
		"group": "2d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".pushPoints(.*)$",
		"action": {
			"name": "pushPoints",
			"control": PushPointsControl.new()
		}
	},
	"rect": {
		"group": "2d_primitives",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".rect(.*)$",
		"action": {
			"name": "rect",
			"control": RectControl.new()
		}
	},
	"shell": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".shell(.*)$",
		"action": {
			"name": "shell",
			"control": ShellControl.new()
		}
	},
	"slot": {
		"group": "2d_primitives",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".slot2D(.*)$",
		"action": {
			"name": "slot",
			"control": SlotControl.new()
		}
	},
	"split": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".split(.*)$",
		"action": {
			"name": "split",
			"control": SplitControl.new()
		}
	},
	"twistExtrude": {
		"group": "3d_operations",
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.twistExtrude(.*)$",
		"action": {
			"name": "twistExtrude",
			"control": TwistExtrudeControl.new()
		}
	}
}
