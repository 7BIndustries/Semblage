extends Tree
signal activate_data_popup
signal error
signal requesting_render

var pressed = false
var drag_item = null
var dragging = false


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
			elif Input.is_mouse_button_pressed(1):
				pressed = true

				# See if there is a component tree item that the user is trying to drag
				var pos = get_local_mouse_position()
				drag_item = get_item_at_position(pos)
			elif not Input.is_mouse_button_pressed(1):
				pressed = false

				# See if the user was dragging the item to a differen item
				if dragging:
					dragging = false

					# Let the user know they have dropped the item
					set_default_cursor_shape(Input.CURSOR_ARROW)

					var pos = get_local_mouse_position()
					var drop_item = get_item_at_position(pos)

					# Protect against weird drag and drop interactions
					if drag_item == null or drop_item == null:
						return

					# If the items are different, start a drop operation
					if drag_item != drop_item:
						# Protect against the user dropping a component onto an operation
						if not drag_item.get_text(0).begins_with(".") and drop_item.get_text(0).begins_with("."):
							emit_signal("error", "You cannot drop a component onto an operation.")
						else:
							Common.move_before(drag_item, drop_item)
							emit_signal("requesting_render")

		"InputEventMouseMotion":
			# Limit the mouse inputs to only work inside the document tabs
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				return

			# Check to see if we are dragging a tree item
			if pressed:
				dragging = true

				# Let the user know they are dragging an item
				set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				dragging = false

				# Let the user know they have dropped the item
				set_default_cursor_shape(Input.CURSOR_ARROW)
