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
	"extrude": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".extrude(.*)$",
		"action": {
			"name": "extrude",
			"template": ".extrude({distance}, combine={combine}, both={both}, taper={taper})",
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
	}
}
