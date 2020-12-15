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
	"rect": {
		"trigger": "\\..*(.*)$",
		"edit_trigger": ".rect(.*)$",
		"action": {
			"name": "rect",
			"control": RectControl.new()
		}
	},
	"fillet": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "fillet",
			"control": FilletControl.new()
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
	}
}
