extends VBoxContainer

class_name CloseControl

var prev_template = null

var template = ".close()"


# Called when the node enters the scene tree for the first time.
func _ready():
	var close_lbl = Label.new()
	close_lbl.set_text("No Options")
	add_child(close_lbl)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false


"""
Fills out the template and returns it.
"""
func get_completed_template():
	return template


"""
When in edit mode, returns the previous template string that needs to
be replaced.
"""
func get_previous_template():
	return prev_template


"""
Loads values into the control's sub-controls based on a code string.
"""
func set_values_from_string(_text_line):
	pass


"""
Checks whether or not all the values in the controls are valid.
"""
func is_valid():
	return true
