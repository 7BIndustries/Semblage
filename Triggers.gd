extends Node

var triggers  = {
	"Workplane": {
		"trigger": "cq$",
		"action": {
			"name": "New Workplane",
			"template": ".Workplane(cq.Plane(origin=({origin_x},{origin_y},{origin_z}), xDir=(1,0,0), normal=({normal_x},{normal_y},{normal_z}))).tag(\"{comp_name}\")",
			"control_groups": {
				"component_name": {
					"label": "Component Name",
					"controls": {
						"comp_name":  {"label": "None", "value_type": "string", "type": "LineEdit", "values": ["Change_Me"]},
					}
				},
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
		"trigger": "\\..*(.*)$",
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
		"trigger": "\\..*(.*)$",
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
	},
	"fillet": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "faces",
			"template": ".faces({face_selector}).edges({edge_selector}).fillet({fillet_radius})",
			"control_groups": {
				"face_selector": {
					"label": "Face(s) Selector",
					"controls": {
#						"first_face_op": {"label": "Filter Operator", "value_type": "string", "type": "OptionButton", "values": ["None", "Max", "Min", "Parallel", "Orthogonal"]},
#						"first_face_arg": {"label": "Filter Direction", "value_type": "string", "type": "OptionButton", "values": ["None", "X", "Y", "Z"]},
#						"first_face_nth": {"label": "Nth Selector", "value_type": "float", "type": "LineEdit", "values": ["0"]},
						"face_selector": {"label": "Selctor Text", "value_type": "float", "type": "LineEdit", "values": ["None"]}
					}
				},
				"edge_selector": {
					"label": "Edge(s) Selector",
					"controls": {
#						"first_edge_op": {"label": "Filter Operator", "value_type": "string", "type": "OptionButton", "values": ["None", "Max", "Min", "Parallel", "Orthogonal"]},
#						"first_edge_arg": {"label": "Filter Direction", "value_type": "string", "type": "OptionButton", "values": ["None", "X", "Y", "Z"]},
#						"first_edge_nth": {"label": "Width", "value_type": "float", "type": "LineEdit", "values": ["0"]},
						"edge_selector": {"label": "Selctor Text", "value_type": "float", "type": "LineEdit", "values": ["None"]}
					}
				},
				"fillet": {
					"label": "Fillet",
					"controls": {
						"fillet_radius": {"label": "Radius", "value_type": "float", "type": "LineEdit", "values": ["0.1"]}
					}
				}
			}
		}
	},
	"chamfer": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "faces",
			"template": ".faces({face_selector}).edges({edge_selector}).chamfer({chamfer_length})",
			"control_groups": {
				"face_selector": {
					"label": "Face(s) Selector",
					"controls": {
#						"first_face_op": {"label": "Filter Operator", "value_type": "string", "type": "OptionButton", "values": ["None", "Max", "Min", "Parallel", "Orthogonal"]},
#						"first_face_arg": {"label": "Filter Direction", "value_type": "string", "type": "OptionButton", "values": ["None", "X", "Y", "Z"]},
#						"first_face_nth": {"label": "Nth Selector", "value_type": "float", "type": "LineEdit", "values": ["0"]},
						"face_selector": {"label": "Selctor Text", "value_type": "float", "type": "LineEdit", "values": ["None"]}
					}
				},
				"edge_selector": {
					"label": "Edge(s) Selector",
					"controls": {
#						"first_edge_op": {"label": "Filter Operator", "value_type": "string", "type": "OptionButton", "values": ["None", "Max", "Min", "Parallel", "Orthogonal"]},
#						"first_edge_arg": {"label": "Filter Direction", "value_type": "string", "type": "OptionButton", "values": ["None", "X", "Y", "Z"]},
#						"first_edge_nth": {"label": "Width", "value_type": "float", "type": "LineEdit", "values": ["0"]},
						"edge_selector": {"label": "Selctor Text", "value_type": "float", "type": "LineEdit", "values": ["None"]}
					}
				},
				"chamfer": {
					"label": "Chamfer",
					"controls": {
						"chamfer_length": {"label": "Length", "value_type": "float", "type": "LineEdit", "values": ["0.1"]}
					}
				}
			}
		}
	},
	"extrude": {
		"trigger": "\\..*(.*)$",
		"action": {
			"name": "extrude",
			"template": ".extrude({distance}, combine={combine}, both={both}, taper={taper})",
			"control_groups": {
				"distance": {
					"label": "Distance",
					"controls": {
						"distance": {"label": "Distance", "value_type": "float", "type": "LineEdit", "values": ["1.0"]}
					}
				},
				"combine": {
					"label": "Combine?",
					"controls": {
						"combine": {"label": "None", "value_type": "bool", "type": "CheckBox", "values": [true]}
					}
				},
				"both": {
					"label": "Both?",
					"controls": {
						"both": {"label": "None", "value_type": "bool", "type": "CheckBox", "values": [false]}
					}
				},
				"taper": {
					"label": "Taper",
					"controls": {
						"taper": {"label": "Taper", "value_type": "float", "type": "LineEdit", "values": ["0.0"]}
					}
				}
			}
		}
	}
}
