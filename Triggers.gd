extends Node

var triggers  = {
	"cq$": {
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
	}
}
