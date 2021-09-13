extends LineEdit

class_name WPNameEdit

var is_valid = true


"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	var invalid_lbl = Label.new()
	invalid_lbl.name = "invalid_lbl"
	invalid_lbl.set_text("!")
	invalid_lbl.add_color_override("font_color", Color(1,0,0,1))
	invalid_lbl.hide()
	add_child(invalid_lbl)


"""
Tells whether or not this control represents a binary operation.
"""
func is_binary():
	return false

"""
Called on mouse and key events on the control.
"""
func _gui_input(event):
	var invalid_lbl = find_node("invalid_lbl", true, false)

	# Check to see a key was pressed
	if event is InputEventKey:
		# Get the key that was pressed
		#var s = OS.get_scancode_string(event.scancode)

		# Full text, including the new entry
		var txt = self.get_text()

		var valid_tag_name = Common._validate_tag_name(txt)

		# Check to make sure the input is valid
		if not valid_tag_name:
			invalid_lbl.show()
			self.hint_tooltip = tr("TAG_NAME_CHARACTER_ERROR")

			is_valid = false
		else:
			invalid_lbl.hide()
			self.hint_tooltip = ""

			is_valid = true
