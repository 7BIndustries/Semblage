extends TabContainer

var accept_input = true
var rotating = false # Whether or not the user is requesting a camera rotation
var panning = false # Whether or not the user is requesting a camera pan
var act_pos2d = Vector2(0,0) # The position the mouse has moved to during an operation
var last_pos2d = Vector2(0,0) # Tracks the relative starting position of the mouse cursor

signal activate_action_popup
signal cam_rotate
signal cam_zoom
signal cam_pan


func _input(event):
	# Allows dialogs to lock this out so that dragging does not rotate the view
	if not accept_input:
		return

	# Make sure no dialogs are present over the top of the viewport
	var error_dlg = find_parent('Control').get_node("ErrorDialog")
	if error_dlg.visible:
		return
	var open_dlg = find_parent('Control').get_node("OpenDialog")
	if open_dlg.visible:
		return
	var export_dlg = find_parent('Control').get_node("ExportDialog")
	if export_dlg.visible:
		return
	var save_dlg = find_parent('Control').get_node("SaveDialog")
	if save_dlg.visible:
		return
	var export_file_dlg = find_parent('Control').get_node("ExportFileDialog")
	if export_file_dlg.visible:
		return
	var confirmation_dlg = find_parent('Control').get_node("ConfirmationDialog")
	if confirmation_dlg.visible:
		return
	var export_svg_dlg = find_parent('Control').get_node("ExportSVGDialog")
	if export_svg_dlg.visible:
		return
	var about_dlg = find_parent('Control').get_node("AboutDialog")
	if about_dlg.visible:
		return
	var add_parameter_dlg = find_parent('Control').get_node("AddParameterDialog")
	if add_parameter_dlg.visible:
		return
	var export_dxf_dlg = find_parent('Control').get_node("ExportDXFDialog")
	if export_dxf_dlg.visible:
		return
	var color_dlg = find_parent('Control').get_node("ColorPickerDialog")
	if color_dlg.visible:
		return
	var save_before_close_dlg = find_parent('Control').get_node("SaveBeforeCloseDialog")
	if save_before_close_dlg.visible:
		return

	act_pos2d = get_viewport().get_mouse_position()

	match event.get_class():
		"InputEventMouseButton":
			# Limit the mouse inputs to only work inside the document tabs
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				return

			# See if the user requested the action menu
			if Input.is_action_just_pressed("Action"):

				emit_signal("activate_action_popup")
			elif Input.is_action_just_pressed("Rotating"):
				rotating = true
				last_pos2d = Vector2(0,0)
			elif Input.is_action_just_released("Rotating"):
				rotating = false
			elif Input.is_action_just_released("ZoomingIn"):
				emit_signal("cam_zoom", -1)
			elif Input.is_action_just_released("ZoomingOut"):
				emit_signal("cam_zoom", 1)
			elif Input.is_action_just_pressed("Panning"):
				panning = true
				last_pos2d = Vector2(0,0)
			elif Input.is_action_just_released("Panning"):
				panning = false
		"InputEventMouseMotion":
			# Limit the mouse inputs to only work inside the document tabs
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				return

			if rotating:
				# Let any cameras know that we are requesting rotation
				emit_signal("cam_rotate", last_pos2d, act_pos2d)
			elif panning:
				# Let any cameras know that we are requesting a pan
				emit_signal("cam_pan", last_pos2d, act_pos2d)

	last_pos2d = act_pos2d


"""
Locks the 3D mouse controls when the action popup panel is about to show.
"""
func _on_ActionPopupPanel_about_to_show():
	accept_input = false


"""
Unlocks the 3D mouse controls when the cancel button is clicked on the
action popup panel.
"""
func _on_ActionPopupPanel_cancel():
	accept_input = true


"""
Unlocks the 3D mouse controls when the ok button is clicked on the
action popup panel.
"""
func _on_ActionPopupPanel_ok_signal(_new_template, _combine_map):
	accept_input = true


"""
Dialogs can use this to tell the document tabs not to accept input
while they are open.
"""
func _dialog_about_to_show():
	accept_input = false


"""
Dialogs can use this to tell the document tabs to accept input again
when they close.
"""
func _dialog_popup_hide():
	accept_input = true
