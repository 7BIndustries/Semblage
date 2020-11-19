extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"action": {
			"name": "New Workplane",
			"template": ".Workplane(cq.Plane(origin=({origin_x},{origin_y},{origin_z}), xDir=(1,0,0), normal=({normal_x},{normal_y},{normal_z})))",
			"control_groups": {
				"inPlane": {
					"label": "Workplane Name",
					"controls": {
						"inPlane": {"label": "None", "value_type": "string", "type": "OptionButton", "values": ["None", "XY", "XZ", "YZ"]}
					}
				},
				"origin": {
					"label": "Origin Location",
					"controls": {
						"origin_x": {"label": "X", "value_type": "int", "type": "LineEdit", "values": ["0"]},
						"origin_y": {"label": "Y", "value_type": "int", "type": "LineEdit", "values": ["0"]},
						"origin_z": {"label": "Z", "value_type": "int", "type": "LineEdit", "values": ["0"]}
					}
				},
				"normal": {
					"label": "Normal Direction",
					"controls": {
						"normal_x": {"label": "X", "value_type": "int", "type": "LineEdit", "values": ["0"]},
						"normal_y": {"label": "Y", "value_type": "int", "type": "LineEdit", "values": ["0"]},
						"normal_z": {"label": "Z", "value_type": "int", "type": "LineEdit", "values": ["1"]}
					}
				}
			}
		}
	},
	"box": {
		"trigger": "Workplane(.*)$",
		"action": {
			"name": "box",
			"template": ".box({length},{width},{height}, centered=({centered_x},{centered_y},{centered_z}))",
			"control_groups": {
				"dimensions": {
					"label": "Dimensions",
					"controls": {
						"length": {"label": "Length", "value_type": "float", "type": "LineEdit", "values": ["1.0"]},
						"width": {"label": "Width", "value_type": "float", "type": "LineEdit", "values": ["1.0"]},
						"height": {"label": "Height", "value_type": "float", "type": "LineEdit", "values": ["1.0"]}
					}
				},
				"centered": {
					"label": "Centered?",
					"controls": {
						"centered_x": {"label": "X", "value_type": "bool", "type": "CheckBox", "values": [true]},
						"centered_y": {"label": "Y", "value_type": "bool", "type": "CheckBox", "values": [true]},
						"centered_z": {"label": "Z", "value_type": "bool", "type": "CheckBox", "values": [true]}
					}
				}
			}
		}
	},
	"rect": {
		"trigger": "Workplane(.*)$",
		"action": {
			"name": "rect",
			"template": ".rect({xLen},{yLen},centered={centered},forConstruction={for_construction})",
			"control_groups": {
				"dimensions": {
					"label": "Dimensions",
					"controls": {
						"xLen": {"label": "Width", "value_type": "float", "type": "LineEdit", "values": ["1.0"]},
						"yLen": {"label": "Height", "value_type": "float", "type": "LineEdit", "values": ["1.0"]}
					}
				},
				"centered": {
					"label": "Centered?",
					"controls": {
						"centered": {"label": "None", "value_type": "bool", "type": "CheckBox", "values": [true]}
					}
				},
				"forConstruction": {
					"label": "For Construction?",
					"controls": {
						"for_construction": {"label": "None", "value_type": "bool", "type": "CheckBox", "values": [true]}
					}
				}
			}
		}
	}
}
