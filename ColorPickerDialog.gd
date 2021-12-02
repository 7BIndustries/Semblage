extends WindowDialog

signal ok_pressed

func _ready():
	pass


"""
Called when the PanelContainer has to resize to fit its contents.
"""
func _on_PanelContainer_resized():
	var pc = get_node("PanelContainer")

	rect_size = pc.rect_size
	rect_min_size = pc.rect_min_size


"""
Mainly used to resize the dialog properly when it first opens.
"""
func _on_ColorPickerDialog_resized():
	_on_PanelContainer_resized()


"""
Called when the user clicks the OK button.
"""
func _on_OkButton_button_down():
	var cp = get_node("PanelContainer/VBoxContainer/ColorPicker")

	# Let the caller know which color values were chosen
	emit_signal("ok_pressed", cp.color)
	hide()


"""
Called when the user clicks the Cancel button.
"""
func _on_CancelButton_button_down():
	hide()


"""
Used to set an existing color value in this dialog.
"""
func set_color_rgba(r, g, b, a):
	var cp = get_node("PanelContainer/VBoxContainer/ColorPicker")
	cp.color.r = r
	cp.color.g = g
	cp.color.b = b
	cp.color.a = a
