extends LineEdit

class_name NumberEdit

export(String, "float", "int") var NumberFormat
export(bool) var CanBeAVariable = true
export(bool) var CanBeNegative
export(bool) var CanBeZero = true
export(int) var MinValue
export(int) var MaxValue


var is_valid = true


# Called when the node enters the scene tree for the first time.
func _ready():
	var invalid_lbl = Label.new()
	invalid_lbl.name = "invalid_lbl"
	invalid_lbl.set_text("!")
	invalid_lbl.add_color_override("font_color", Color(1,0,0,1))
	invalid_lbl.hide()
	add_child(invalid_lbl)


"""
Called on mouse and key events on the control.
"""
func _gui_input(event):
	var invalid_lbl = get_node("invalid_lbl")

	# Check to see a key was pressed
	if event is InputEventKey:
		# Get the key that was pressed
		#var s = OS.get_scancode_string(event.scancode)

		# Full text, including the new entry
		var txt = self.get_text()

		# Allows us to check if we have a variable name
		var rgx = RegEx.new()
		rgx.compile("^[a-zA-Z]+")
		var res = rgx.search(txt)

		# Make sure an integer does not include a decimal point
		if CanBeAVariable and res:
			invalid_lbl.hide()
			self.hint_tooltip = ""

			is_valid = true
		elif not txt.is_valid_float():
			invalid_lbl.show()
			self.hint_tooltip = "Enter a valid number"

			is_valid = false
		elif NumberFormat == "int" and txt.find(".") > 0:
			invalid_lbl.show()
			self.hint_tooltip = "Enter an integer"

			is_valid = false
		elif not CanBeNegative and (txt.left(1) == "-" or float(txt) < 0.0):
			invalid_lbl.show()
			self.hint_tooltip = "Must be >= 0"

			is_valid = false
		elif not CanBeZero and (txt.left(1) == "-" or float(txt) <= 0.0):
			invalid_lbl.show()
			self.hint_tooltip = "Must be > 0"

			is_valid = false
		elif MinValue != MaxValue and (float(txt) < MinValue or float(txt) > MaxValue):
			invalid_lbl.show()
			self.hint_tooltip = "Value must be between " + str(MinValue) + " and " + str(MaxValue)

			is_valid = false
		elif txt.empty():
			# The user has not entered anything
			invalid_lbl.show()
			self.hint_tooltip = "Enter a value"

			is_valid = false
		else:
			invalid_lbl.hide()
			self.hint_tooltip = ""

			is_valid = true

		# TODO: Possibly use this in the future to detect valid parameters
		# Figure out if we could be dealing with a variable
#		var rgx = RegEx.new()
#		rgx.compile("[a-zA-Z]")
#		var res = rgx.search(self.get_text())
#		if res:
#			# TODO: Check if the entry matches a variable name
#			print("Alphanum")
