extends VBoxContainer

class_name SelectorControl

var face_comps_opt_1 = null
var face_comps_opt_2 = null
var extra_face_selector_adder = null
var face_logic_option_button = null
var face_comps_opt_3 = null
var face_comps_opt_4 = null
var face_selector_txt = null

var edge_comps_opt_1 = null
var edge_comps_opt_2 = null
var extra_edge_selector_adder = null
var edge_comps_opt_3 = null
var edge_comps_opt_4 = null
var edge_selector_txt = null

var filter_items = ["All", "Maximum", "Minimum", "Positive Normal", "Negative Normal", "Parallel", "Orthogonal"]
var axis_items = ["X", "Y", "Z"]

var template = ".faces({face_selector}).edges({edge_selector})"


func get_completed_template():
	return template.format(
		{"face_selector": face_selector_txt.get_text(),
		 "edge_selector": edge_selector_txt.get_text()
		})


func _ready():
	# 
	# Populate the face selector controls
	#
	var face_comps = HBoxContainer.new()

	var face_comps_lbl = Label.new()
	face_comps_lbl.set_text("Face Selector: ")
	face_comps.add_child(face_comps_lbl)

	# The first face filter (i.e. >, <, |)
	face_comps_opt_1 = OptionButton.new()
	_load_items(face_comps_opt_1, filter_items)
	face_comps_opt_1.connect("item_selected", self, "_first_face_filter_selected")
	face_comps.add_child(face_comps_opt_1)

	# First axis filter (X, Y, Z)
	face_comps_opt_2 = OptionButton.new()
	_load_items(face_comps_opt_2, axis_items)
	face_comps_opt_2.connect("item_selected", self, "_first_face_axis_selected")
	face_comps_opt_2.hide()
	face_comps.add_child(face_comps_opt_2)

	# Button that allows the user to add another section of selectors
	extra_face_selector_adder = Button.new()
	extra_face_selector_adder.set_text("+")
	extra_face_selector_adder.hide()
	extra_face_selector_adder.connect("button_down", self, "_first_add_button_clicked")
	face_comps.add_child(extra_face_selector_adder)

	# The logic operator (and/or)
	face_logic_option_button = OptionButton.new()
	face_logic_option_button.add_item("and")
	face_logic_option_button.add_item("or")
	face_logic_option_button.hide()
	face_logic_option_button.connect("item_selected", self, "_face_logic_button_changed")
	face_comps.add_child(face_logic_option_button)

	# The second face filter (i.e. >, <, |)
	face_comps_opt_3 = OptionButton.new()
	_load_items(face_comps_opt_3, filter_items)
	face_comps_opt_3.connect("item_selected", self, "_second_face_filter_selected")
	face_comps_opt_3.hide()
	face_comps.add_child(face_comps_opt_3)

	# Second axis filter (X, Y, Z)
	face_comps_opt_4 = OptionButton.new()
	_load_items(face_comps_opt_4, axis_items)
	face_comps_opt_4.connect("item_selected", self, "_second_face_axis_selected")
	face_comps_opt_4.hide()
	face_comps.add_child(face_comps_opt_4)

	# Populate the face selector readout controls
	var face_selector = HBoxContainer.new()
	var face_selector_lbl = Label.new()
	face_selector_lbl.set_text("Face Selector String: ")
	face_selector.add_child(face_selector_lbl)
	face_selector_txt = LineEdit.new()
	face_selector_txt.size_flags_horizontal = face_selector_txt.SIZE_EXPAND_FILL
	face_selector.add_child(face_selector_txt)

	add_child(face_comps)
	add_child(face_selector)

	# 
	# Populate the edge selector controls
	#
	var edge_comps = HBoxContainer.new()
	var edge_comps_lbl = Label.new()
	edge_comps_lbl.set_text("Edge Selector: ")
	edge_comps.add_child(edge_comps_lbl)

	# The first face filter (i.e. >, <, |)
	edge_comps_opt_1 = OptionButton.new()
	_load_items(edge_comps_opt_1, filter_items)
	edge_comps_opt_1.connect("item_selected", self, "_first_edge_filter_selected")
	edge_comps.add_child(edge_comps_opt_1)

	# First axis filter (X, Y, Z)
	edge_comps_opt_2 = OptionButton.new()
	_load_items(edge_comps_opt_2, axis_items)
	edge_comps_opt_2.connect("item_selected", self, "_first_edge_axis_selected")
	edge_comps_opt_2.hide()
	edge_comps.add_child(edge_comps_opt_2)

	# Button that allows the user to add another section of selectors
	extra_edge_selector_adder = Button.new()
	extra_edge_selector_adder.set_text("+")
	extra_edge_selector_adder.hide()
	extra_edge_selector_adder.connect("button_down", self, "_first_edge_add_button_clicked")
	edge_comps.add_child(extra_edge_selector_adder)

	# The second face filter (i.e. >, <, |)
	edge_comps_opt_3 = OptionButton.new()
	_load_items(edge_comps_opt_3, filter_items)
	edge_comps_opt_3.connect("item_selected", self, "_second_edge_filter_selected")
	edge_comps_opt_3.hide()
	edge_comps.add_child(edge_comps_opt_3)

	# Second axis filter (X, Y, Z)
	edge_comps_opt_4 = OptionButton.new()
	_load_items(edge_comps_opt_4, axis_items)
	edge_comps_opt_4.connect("item_selected", self, "_second_edge_axis_selected")
	edge_comps_opt_4.hide()
	edge_comps.add_child(edge_comps_opt_4)

	# Populate the face selector readout controls
	var edge_selector = HBoxContainer.new()
	var edge_selector_lbl = Label.new()
	edge_selector_lbl.set_text("Edge Selector String: ")
	edge_selector.add_child(edge_selector_lbl)
	edge_selector_txt = LineEdit.new()
	edge_selector_txt.size_flags_horizontal = edge_selector_txt.SIZE_EXPAND_FILL
	edge_selector.add_child(edge_selector_txt)

	add_child(edge_comps)
	add_child(edge_selector)


"""
Called when the first face filter is selected.
"""
func _first_face_filter_selected(index):
	var selected = face_comps_opt_1.get_item_text(index)

	# If something other that None was selected, unhide the next control in line
	if selected != "All":
		_update_face_selector_string()

		self.face_comps_opt_2.show()
		self.extra_face_selector_adder.show()


"""
Called when the first face axis is selected.
"""
func _first_face_axis_selected(index):
	_update_face_selector_string()


"""
Called when the first button is clicked to add another face selector.
"""
func _first_add_button_clicked():
	face_logic_option_button.show()
	face_comps_opt_3.show()
	face_comps_opt_4.show()

	_update_face_selector_string()


"""
Called when the second face filter is selected.
"""
func _second_face_filter_selected(index):
	print("HERE1")


"""
Called when the first face axis is selected.
"""
func _second_face_axis_selected(index):
	print("HERE2")


"""
Called when the first edge filter is selected.
"""
func _first_edge_filter_selected(index):
	var selected = edge_comps_opt_1.get_item_text(index)

	# If something other that None was selected, unhide the next control in line
	if selected != "All":
		_update_edge_selector_string()

		self.edge_comps_opt_2.show()
		self.extra_edge_selector_adder.show()


"""
Called when the first edge axis is selected.
"""
func _first_edge_axis_selected(index):
	_update_edge_selector_string()


"""
Called when the first button is clicked to add another edge selector.
"""
func _first_edge_add_button_clicked():
	edge_comps_opt_3.show()
	edge_comps_opt_4.show()


"""
Update the face selector string with a logic combiner, if needed.
"""
func _face_logic_button_changed(index):
	_update_face_selector_string()

"""
Loads all of the items from an array into an option button.
"""
func _load_items(option_button, items):
	for item in items:
		option_button.add_item(item)


"""
Converts a human-readable filter string into a CQ string selector symbol.
"""
func _get_filter_symbol(human_readable):
#	 ["All", "Maximum", "Minimum", "Positive Normal", "Negative Normal", "Parallel", "Orthogonal"]

	if human_readable == "Maximum":
		return ">"
	elif human_readable == "Minimum":
		return "<"
	elif human_readable == "Positive Normal":
		return "+"
	elif human_readable == "Negative Normal":
		return "-"
	elif human_readable == "Parallel":
		return "|"
	elif human_readable == "Orthogonal":
		return "#"
	else:
		return null


"""
Updates the face selector based on the controls that are visible and what they contain.
"""
func _update_face_selector_string():
	# Build the first filter part of the selector string
	var first_face_filter = face_comps_opt_1.get_item_text(face_comps_opt_1.get_selected_id())
	face_selector_txt.set_text(_get_filter_symbol(first_face_filter))

	# Add the first axis part of the selector string
	var first_face_axis = face_comps_opt_2.get_item_text(face_comps_opt_2.get_selected_id())
	var face_selector_string = face_selector_txt.get_text()
	face_selector_string += first_face_axis
	face_selector_txt.set_text(face_selector_string)

	# If the logic operator option button is visible, pull its value into the selector string
	if face_logic_option_button.visible:
		var logic_txt = face_logic_option_button.get_item_text(face_logic_option_button.get_selected_id())
		face_selector_string = face_selector_txt.get_text()
		face_selector_string += " " + logic_txt + " "
		face_selector_txt.set_text(face_selector_string)


"""
Updates the edge selector based on the controls that are visible and what they contain.
"""
func _update_edge_selector_string():
	var first_edge_filter = edge_comps_opt_1.get_item_text(edge_comps_opt_1.get_selected_id())
	edge_selector_txt.set_text(_get_filter_symbol(first_edge_filter))

	# Add the first axis part of the selector string
	var first_edge_axis = edge_comps_opt_2.get_item_text(edge_comps_opt_2.get_selected_id())
	var edge_selector_string = edge_selector_txt.get_text()
	edge_selector_string += first_edge_axis
	edge_selector_txt.set_text(edge_selector_string)
