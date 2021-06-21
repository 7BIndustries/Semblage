extends LineEdit

class_name WPNameEdit

var invalid_lbl = null
var is_valid = true

var num_start_regex = null
var valid_chars_regex = null


"""
Called when the node enters the scene tree for the first time.
"""
func _ready():
	self.invalid_lbl = Label.new()
	self.invalid_lbl.set_text("!")
	self.invalid_lbl.add_color_override("font_color", Color(1,0,0,1))
	self.invalid_lbl.hide()
	add_child(self.invalid_lbl)

	# Regex to protect against component names that start with a number
	num_start_regex = RegEx.new()
	num_start_regex.compile("^[0-9].*")

	# Regex to protect against invalid characters in component names
	valid_chars_regex = RegEx.new()
	valid_chars_regex.compile("^[a-zA-Z0-9_]+$")


"""
Called on mouse and key events on the control.
"""
func _gui_input(event):
	# Check to see a key was pressed
	if event is InputEventKey:
		# Get the key that was pressed
		#var s = OS.get_scancode_string(event.scancode)

		# Full text, including the new entry
		var txt = self.get_text()

		# Check to make sure the input is valid
		if txt.find(" ") > 0:
			self.invalid_lbl.show()
			self.hint_tooltip = "Component name cannot contain spaces.\nUse underscores instead of spaces."

			is_valid = false
		elif num_start_regex.search(txt):
			self.invalid_lbl.show()
			self.hint_tooltip = "Component name cannot start with a number."

			is_valid = false
		elif not valid_chars_regex.search(txt):
			self.invalid_lbl.show()
			self.hint_tooltip = "Component name an only contain letters, numbers and underscores."

			is_valid = false
		else:
			self.invalid_lbl.hide()
			self.hint_tooltip = ""

			is_valid = true
