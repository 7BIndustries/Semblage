extends LineEdit

class_name NumberEdit

export(String, "float", "int") var NumberFormat
export(bool) var CanBeNegative
export(int) var MinValue
export(int) var MaxValue


var invalid_lbl = null
var is_valid = true


# Called when the node enters the scene tree for the first time.
func _ready():
	self.invalid_lbl = Label.new()
	self.invalid_lbl.set_text("!")
	self.invalid_lbl.add_color_override("font_color", Color(1,0,0,1))
	self.invalid_lbl.hide()
	add_child(self.invalid_lbl)


"""
Called on mouse and key events on the control.
"""
func _gui_input(event):
	# Check to see a key was pressed
	if event is InputEventKey:
		# Get the key that was pressed
		var s = OS.get_scancode_string(event.scancode)

		# Full text, including the new entry
		var txt = self.get_text()

		# Make sure an integer does not include aa decimal point
		if not txt.is_valid_float():
			self.invalid_lbl.show()
			self.hint_tooltip = "Enter a valid number"

			is_valid = false
		elif NumberFormat == "int" and txt.find(".") > 0:
			self.invalid_lbl.show()
			self.hint_tooltip = "Enter an integer"

			is_valid = false
		elif not CanBeNegative and (txt.left(1) == "-" or float(txt) < 0.0):
			self.invalid_lbl.show()
			self.hint_tooltip = "Must be > 0"

			is_valid = false
		elif MinValue != MaxValue and (float(txt) < MinValue or float(txt) > MaxValue):
			self.invalid_lbl.show()
			self.hint_tooltip = "Value must be between " + str(MinValue) + " and " + str(MaxValue)

			is_valid = false
		else:
			self.invalid_lbl.hide()
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
