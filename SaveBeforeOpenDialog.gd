extends WindowDialog

signal yes_save_before_open
signal no_save_before_open

"""
Called when this object is ready to enter the scene tree.
"""
func _ready():
	pass


"""
Called when the panel container containing all the controls is called.
"""
func _on_PanelContainer_resized():
	var pc = get_node("PanelContainer")

	pc.rect_size = self.rect_size


"""
Called when the user clicks the Yes button to save a component before close.
"""
func _on_YesButton_button_down():
	emit_signal("yes_save_before_open")
	hide()


"""
Called when the user clicks the No button to not save a component before close.
"""
func _on_NoButton_button_down():
	emit_signal("no_save_before_open")
	hide()


"""
Called when the dialog window is resized.
"""
func _on_SaveBeforeOpenDialog_resized():
	_on_PanelContainer_resized()
