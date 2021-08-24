extends Tree
signal activate_data_popup

func _input(event):
	match event.get_class():
		"InputEventMouseButton":
			# Limit the mouse inputs to only work inside the document tabs
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				return

			# See if the user requested the action menu
			if Input.is_action_just_pressed("Action"):
				var pos = get_local_mouse_position()
				var item = get_item_at_position(pos)
				if item:
					item.select(0)

				emit_signal("activate_data_popup")
