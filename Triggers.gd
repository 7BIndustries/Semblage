extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"edit_trigger": "^.Workplane(.*).*",
		"action": {
			"name": "New Workplane",
			"control": WorkplaneControl.new(),
		}
	},
	"box": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".box(.*)$",
		"action": {
			"name": "box",
			"control": BoxControl.new()
		}
	},
	"chamfer": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".chamfer(.*)$",
		"action": {
			"name": "chamfer",
			"control": ChamferControl.new()
		}
	},
	"cutBlind": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.cutBlind(.*)$",
		"action": {
			"name": "cutBlind",
			"control": BlindCutControl.new()
		}
	},
	"extrude": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": "^.extrude(.*)$",
		"action": {
			"name": "extrude",
			"control": ExtrudeControl.new()
		}
	},
	"fillet": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".fillet(.*)$",
		"action": {
			"name": "fillet",
			"control": FilletControl.new()
		}
	},
	"rect": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".rect(.*)$",
		"action": {
			"name": "rect",
			"control": RectControl.new()
		}
	},
	"shell": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".shell(.*)$",
		"action": {
			"name": "shell",
			"control": ShellControl.new()
		}
	},
	"slot": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".slot2D(.*)$",
		"action": {
			"name": "slot",
			"control": SlotControl.new()
		}
	}
}
