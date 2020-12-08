extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"action": {
			"name": "New Workplane",
			"control": WorkplaneControl.new()
		}
	},
	"box": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "box",
			"control": BoxControl.new()
		}
	},
	"rect": {
		"trigger": "\\..*(.*)$",
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
		"action": {
			"name": "chamfer",
			"control": ChamferControl.new()
		}
	},
	"extrude": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "extrude",
			"template": ".extrude({distance}, combine={combine}, both={both}, taper={taper})",
			"control": ExtrudeControl.new()
		}
	}
}
