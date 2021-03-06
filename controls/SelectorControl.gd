extends VBoxContainer

class_name SelectorControl

# Face selector controls
var face_comps = null
var face_comps_opt_1 = null
var face_comps_opt_2 = null
var extra_face_selector_adder = null
var face_logic_option_button = null
var face_comps_opt_3 = null
var face_comps_opt_4 = null
var hide_show_face_str = null
var face_selector_txt = null

# Edge selector controls
var edge_comps = null
var edge_comps_opt_1 = null
var edge_comps_opt_2 = null
var extra_edge_selector_adder = null
var edge_logic_option_button = null
var edge_comps_opt_3 = null
var edge_comps_opt_4 = null
var hide_show_edge_str = null
var edge_selector_txt = null

# Vertex selector controls
var vertex_comps = null
var vertex_comps_opt_1 = null
var vertex_comps_opt_2 = null
var extra_vertex_selector_adder = null
var vertex_logic_option_button = null
var vertex_comps_opt_3 = null
var vertex_comps_opt_4 = null
var hide_show_vertex_str = null
var vertex_selector_txt = null

var filter_items = ["None", "All", "Maximum", "Minimum", "Positive Normal", "Negative Normal", "Parallel", "Orthogonal"]
var vertex_filter_items = ["None", "All", "Maximum", "Minimum"]
var axis_items = ["X", "Y", "Z"]

var prev_template = null

var faces_template = ".faces({face_selector})"
var edges_template = ".edges({edge_selector})"
var vertices_template = ".vertices({vertex_selector})"

var face_sel_edit_rgx = "(?<=.faces\\(\")(.*?)(?=\"\\))"
var edge_sel_edit_rgx = "(?<=.edges\\(\")(.*?)(?=\"\\))"
var vertex_sel_edit_rgx = "(?<=.vertices\\(\")(.*?)(?=\"\\))"
var logic_edit_rgx = "(and|or)"
var second_edit_rgx = "(and|or).*"

var show_faces = true
var show_edges = true
var show_vertices = true


func _ready():
	var show_btn_texture = load("res://assets/icons/show_button_flat_ready.png")
	
	# 
	# Populate the face selector controls
	#
	face_comps = HBoxContainer.new()

	# Make sure the appropriate controls are visible
	if not self.show_faces:
		face_comps.hide()

	var face_comps_lbl = Label.new()
	face_comps_lbl.set_text("Face Selector: ")
	face_comps.add_child(face_comps_lbl)

	# The first face filter (i.e. >, <, |)
	face_comps_opt_1 = OptionButton.new()
	Common.load_option_button(face_comps_opt_1, filter_items)
	face_comps_opt_1.connect("item_selected", self, "_first_face_filter_selected")
	face_comps.add_child(face_comps_opt_1)

	# First axis filter (X, Y, Z)
	face_comps_opt_2 = OptionButton.new()
	Common.load_option_button(face_comps_opt_2, axis_items)
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
	var short_filter_items = filter_items.slice(2, -1)
	Common.load_option_button(face_comps_opt_3, short_filter_items)
	face_comps_opt_3.connect("item_selected", self, "_second_face_filter_selected")
	face_comps_opt_3.hide()
	face_comps.add_child(face_comps_opt_3)

	# Second axis filter (X, Y, Z)
	face_comps_opt_4 = OptionButton.new()
	Common.load_option_button(face_comps_opt_4, axis_items)
	face_comps_opt_4.connect("item_selected", self, "_second_face_axis_selected")
	face_comps_opt_4.hide()
	face_comps.add_child(face_comps_opt_4)

	# Button to make the raw face selector string visible
	hide_show_face_str = Button.new()
	hide_show_face_str.set_button_icon(show_btn_texture)
	hide_show_face_str.connect("button_down", self, "_hide_show_face_sel_string")
	face_comps.add_child(hide_show_face_str)

	# Populate the face selector readout controls
	face_selector_txt = LineEdit.new()
	face_selector_txt.size_flags_horizontal = face_selector_txt.SIZE_EXPAND_FILL
	face_selector_txt.hide()

	add_child(face_comps)
	add_child(face_selector_txt)

	# 
	# Populate the edge selector controls
	#
	edge_comps = HBoxContainer.new()

	# Make sure the appropriate controls are visible
	if not self.show_edges:
		edge_comps.hide()

	var edge_comps_lbl = Label.new()
	edge_comps_lbl.set_text("Edge Selector: ")
	edge_comps.add_child(edge_comps_lbl)

	# The first face filter (i.e. >, <, |)
	edge_comps_opt_1 = OptionButton.new()
	Common.load_option_button(edge_comps_opt_1, filter_items)
	edge_comps_opt_1.connect("item_selected", self, "_first_edge_filter_selected")
	edge_comps.add_child(edge_comps_opt_1)

	# First axis filter (X, Y, Z)
	edge_comps_opt_2 = OptionButton.new()
	Common.load_option_button(edge_comps_opt_2, axis_items)
	edge_comps_opt_2.connect("item_selected", self, "_first_edge_axis_selected")
	edge_comps_opt_2.hide()
	edge_comps.add_child(edge_comps_opt_2)

	# Button that allows the user to add another section of selectors
	extra_edge_selector_adder = Button.new()
	extra_edge_selector_adder.set_text("+")
	extra_edge_selector_adder.hide()
	extra_edge_selector_adder.connect("button_down", self, "_first_edge_add_button_clicked")
	edge_comps.add_child(extra_edge_selector_adder)

	# The logic operator (and/or)
	edge_logic_option_button = OptionButton.new()
	edge_logic_option_button.add_item("and")
	edge_logic_option_button.add_item("or")
	edge_logic_option_button.hide()
	edge_logic_option_button.connect("item_selected", self, "_edge_logic_button_changed")
	edge_comps.add_child(edge_logic_option_button)

	# The second face filter (i.e. >, <, |)
	edge_comps_opt_3 = OptionButton.new()
	Common.load_option_button(edge_comps_opt_3, short_filter_items)
	edge_comps_opt_3.connect("item_selected", self, "_second_edge_filter_selected")
	edge_comps_opt_3.hide()
	edge_comps.add_child(edge_comps_opt_3)

	# Second axis filter (X, Y, Z)
	edge_comps_opt_4 = OptionButton.new()
	Common.load_option_button(edge_comps_opt_4, axis_items)
	edge_comps_opt_4.connect("item_selected", self, "_second_edge_axis_selected")
	edge_comps_opt_4.hide()
	edge_comps.add_child(edge_comps_opt_4)

	# Button to make the raw edge selector string visible
	hide_show_edge_str = Button.new()
	hide_show_edge_str.set_button_icon(show_btn_texture)
	hide_show_edge_str.connect("button_down", self, "_hide_show_edge_sel_string")
	edge_comps.add_child(hide_show_edge_str)

	# Populate the edge selector readout controls
	edge_selector_txt = LineEdit.new()
	edge_selector_txt.size_flags_horizontal = edge_selector_txt.SIZE_EXPAND_FILL
	edge_selector_txt.hide()

	add_child(edge_comps)
	add_child(edge_selector_txt)

	#
	# Add the vertex selector controls.
	#
	vertex_comps = HBoxContainer.new()

	# Make sure the appropriate controls are visible
	if not self.show_vertices:
		vertex_comps.hide()

	var vertex_comps_lbl = Label.new()
	vertex_comps_lbl.set_text("Vertex Selector: ")
	vertex_comps.add_child(vertex_comps_lbl)

	# The first vertex filter (i.e. >, <)
	vertex_comps_opt_1 = OptionButton.new()
	Common.load_option_button(vertex_comps_opt_1, vertex_filter_items)
	vertex_comps_opt_1.connect("item_selected", self, "_first_vertex_filter_selected")
	vertex_comps.add_child(vertex_comps_opt_1)

	# First axis filter (X, Y, Z)
	vertex_comps_opt_2 = OptionButton.new()
	Common.load_option_button(vertex_comps_opt_2, axis_items)
	vertex_comps_opt_2.connect("item_selected", self, "_first_vertex_axis_selected")
	vertex_comps_opt_2.hide()
	vertex_comps.add_child(vertex_comps_opt_2)

	# Button that allows the user to add another section of selectors
	extra_vertex_selector_adder = Button.new()
	extra_vertex_selector_adder.set_text("+")
	extra_vertex_selector_adder.hide()
	extra_vertex_selector_adder.connect("button_down", self, "_first_vertex_add_button_clicked")
	vertex_comps.add_child(extra_vertex_selector_adder)

	# The logic operator (and/or)
	vertex_logic_option_button = OptionButton.new()
	vertex_logic_option_button.add_item("and")
	vertex_logic_option_button.add_item("or")
	vertex_logic_option_button.hide()
	vertex_logic_option_button.connect("item_selected", self, "_vertex_logic_button_changed")
	vertex_comps.add_child(vertex_logic_option_button)

	# The second vertex filter (i.e. >, <)
	var short_vertex_filter_items = vertex_filter_items.slice(2, -1)
	vertex_comps_opt_3 = OptionButton.new()
	Common.load_option_button(vertex_comps_opt_3, short_vertex_filter_items)
	vertex_comps_opt_3.connect("item_selected", self, "_second_vertex_filter_selected")
	vertex_comps_opt_3.hide()
	vertex_comps.add_child(vertex_comps_opt_3)

	# Second axis filter (X, Y, Z)
	vertex_comps_opt_4 = OptionButton.new()
	Common.load_option_button(vertex_comps_opt_4, axis_items)
	vertex_comps_opt_4.connect("item_selected", self, "_second_vertex_axis_selected")
	vertex_comps_opt_4.hide()
	vertex_comps.add_child(vertex_comps_opt_4)

	# Button to make the raw vertex selector string visible
	hide_show_vertex_str = Button.new()
	hide_show_vertex_str.set_button_icon(show_btn_texture)
	hide_show_vertex_str.connect("button_down", self, "_hide_show_vertex_sel_string")
	vertex_comps.add_child(hide_show_vertex_str)

	# Populate the face selector readout controls
	vertex_selector_txt = LineEdit.new()
	vertex_selector_txt.size_flags_horizontal = vertex_selector_txt.SIZE_EXPAND_FILL
	vertex_selector_txt.hide()

	add_child(vertex_comps)
	add_child(vertex_selector_txt)


"""
Fills out the template and returns it.
"""
func get_completed_template():
	var completed = ""

	# Add face selector(s), if needed
	if show_faces and face_comps_opt_1.get_item_text(face_comps_opt_1.get_selected_id()) != "None":
		# Add the escaped quotes if needed
		var face_selector = face_selector_txt.get_text()
		if face_selector != "":
			face_selector = "\"\"" + face_selector + "\"\""
		
		completed += faces_template.format({"face_selector": face_selector});

	# Add edge selector(s), if needed
	if show_edges and edge_comps_opt_1.get_item_text(edge_comps_opt_1.get_selected_id()) != "None":
		var edge_selector = edge_selector_txt.get_text()
		if edge_selector != "":
			edge_selector = "\"\"" + edge_selector + "\"\""

		completed += edges_template.format({"edge_selector": edge_selector})

	# Add vertex selector(s), if needed
	if show_vertices and vertex_comps_opt_1.get_item_text(vertex_comps_opt_1.get_selected_id()) != "None":
		var vertex_selector = vertex_selector_txt.get_text()
		if vertex_selector != "":
			vertex_selector = "\"\"" + vertex_selector + "\"\""

		completed += vertices_template.format({"vertex_selector": vertex_selector})

	return completed


"""
Allows the caller to hide any selectors that do not apply.
"""
func config_visibility(faces=true, edges=true):
	self.show_faces = faces
	self.show_edges = edges


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
	else:
		self.face_comps_opt_2.hide()
		self.extra_face_selector_adder.hide()
		face_selector_txt.set_text("")


"""
Called when the first face axis is selected.
"""
func _first_face_axis_selected(index):
	_update_face_selector_string()


"""
Called when the first button is clicked to add another face selector.
"""
func _first_add_button_clicked():
	# If the button is visible already, hide it and change its text
	if face_logic_option_button.visible:
		# Show the second set of selector buttons
		face_logic_option_button.hide()
		face_comps_opt_3.hide()
		face_comps_opt_4.hide()

		extra_face_selector_adder.set_text("+")
	else:
		# Show the second set of selector buttons
		face_logic_option_button.show()
		face_comps_opt_3.show()
		face_comps_opt_4.show()

		extra_face_selector_adder.set_text("-")

	_update_face_selector_string()


"""
Called when the second face filter is selected.
"""
func _second_face_filter_selected(index):
	_update_face_selector_string()


"""
Called when the first face axis is selected.
"""
func _second_face_axis_selected(index):
	_update_face_selector_string()


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
	else:
		self.edge_comps_opt_2.hide()
		self.extra_edge_selector_adder.hide()
		edge_selector_txt.set_text("")


"""
Called when the first vertex filter is selected.
"""
func _first_vertex_filter_selected(index):
	var selected = vertex_comps_opt_1.get_item_text(index)

	# If something other that None was selected, unhide the next control in line
	if selected != "All":
		_update_vertex_selector_string()

		self.vertex_comps_opt_2.show()
		self.extra_vertex_selector_adder.show()
	else:
		self.vertex_comps_opt_2.hide()
		self.extra_vertex_selector_adder.hide()
		vertex_selector_txt.set_text("")


"""
Called when the first edge axis is selected.
"""
func _first_edge_axis_selected(index):
	_update_edge_selector_string()


"""
Called when the first vertex axis is selected.
"""
func _first_vertex_axis_selected(index):
	_update_vertex_selector_string()


"""
Called when the button to hide/show the raw face selector string is pressed.
"""
func _hide_show_face_sel_string():
	if face_selector_txt.visible:
		face_selector_txt.hide()
	else:
		face_selector_txt.show()


"""
Called when the button to hide/show the raw edge selector string is pressed.
"""
func _hide_show_edge_sel_string():
	if edge_selector_txt.visible:
		edge_selector_txt.hide()
	else:
		edge_selector_txt.show()


"""
Called when the button to hide/show the raw vertex selector string is pressed.
"""
func _hide_show_vertex_sel_string():
	if vertex_selector_txt.visible:
		vertex_selector_txt.hide()
	else:
		vertex_selector_txt.show()


"""
Called when the first button is clicked to add another edge selector.
"""
func _first_edge_add_button_clicked():
	if edge_comps_opt_3.visible:
		edge_logic_option_button.hide()
		edge_comps_opt_3.hide()
		edge_comps_opt_4.hide()

		extra_edge_selector_adder.set_text("+")
	else:
		edge_logic_option_button.show()
		edge_comps_opt_3.show()
		edge_comps_opt_4.show()

		extra_edge_selector_adder.set_text("-")

	_update_edge_selector_string()


"""
Called when the first button is clicked to add another vertex selector.
"""
func _first_vertex_add_button_clicked():
	if vertex_comps_opt_3.visible:
		vertex_logic_option_button.hide()
		vertex_comps_opt_3.hide()
		vertex_comps_opt_4.hide()

		extra_vertex_selector_adder.set_text("+")
	else:
		vertex_logic_option_button.show()
		vertex_comps_opt_3.show()
		vertex_comps_opt_4.show()

		extra_vertex_selector_adder.set_text("-")

	_update_vertex_selector_string()

"""
Update the face selector string with the logic combiner, if needed.
"""
func _face_logic_button_changed(index):
	_update_face_selector_string()


"""
Update the edge selector string with the logic combiner, if needed.
"""
func _edge_logic_button_changed(index):
	_update_edge_selector_string()


"""
Update the vertex selector string with the logic combiner, if needed.
"""
func _vertex_logic_button_changed(index):
	_update_vertex_selector_string()


"""
Update the edge selector for the second edge filter.
"""
func _second_edge_filter_selected(index):
	_update_edge_selector_string()


"""
Update the vertex selector for the second vertex filter.
"""
func _second_vertex_filter_selected(index):
	_update_vertex_selector_string()


"""
Update the edge selector for the second edge axis.
"""
func _second_edge_axis_selected(index):
	_update_edge_selector_string()


"""
Update the vertex selector for the second vertex axis.
"""
func _second_vertex_axis_selected(index):
	_update_vertex_selector_string()


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
Converts a script filter operator into the human-readable version.
"""
func _get_filter_text(symbol):
	if symbol == ">":
		return "Maximum"
	elif symbol == "<":
		return "Minimum"
	elif symbol == "+":
		return "Positive Normal"
	elif symbol == "-":
		return "Negative Normal"
	elif symbol == "|":
		return "Parallel"
	elif symbol == "#":
		return "Orthogonal"
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

	# If the second face filter option button is visible, pull its value
	if face_comps_opt_3.visible:
		var sec_face_selector_txt = _get_filter_symbol(face_comps_opt_3.get_item_text(face_comps_opt_3.get_selected_id()))
		face_selector_string = face_selector_txt.get_text()
		face_selector_string += sec_face_selector_txt
		face_selector_txt.set_text(face_selector_string)

	# If the second axis option button is visible, pull its value
	if face_comps_opt_4.visible:
		var sec_axis_selector_txt = face_comps_opt_4.get_item_text(face_comps_opt_4.get_selected_id())
		face_selector_string = face_selector_txt.get_text()
		face_selector_string += sec_axis_selector_txt
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

	# If the logic operator option button is visible, pull its value into the selector string
	if edge_logic_option_button.visible:
		var logic_txt = edge_logic_option_button.get_item_text(edge_logic_option_button.get_selected_id())
		edge_selector_string = edge_selector_txt.get_text()
		edge_selector_string += " " + logic_txt + " "
		edge_selector_txt.set_text(edge_selector_string)

	# If the second face filter option button is visible, pull its value
	if edge_comps_opt_3.visible:
		var sec_edge_selector_txt = _get_filter_symbol(edge_comps_opt_3.get_item_text(edge_comps_opt_3.get_selected_id()))
		edge_selector_string = edge_selector_txt.get_text()
		edge_selector_string += sec_edge_selector_txt
		edge_selector_txt.set_text(edge_selector_string)

	# If the second axis option button is visible, pull its value
	if edge_comps_opt_4.visible:
		var sec_axis_selector_txt = edge_comps_opt_4.get_item_text(edge_comps_opt_4.get_selected_id())
		edge_selector_string = edge_selector_txt.get_text()
		edge_selector_string += sec_axis_selector_txt
		edge_selector_txt.set_text(edge_selector_string)


"""
Updates the vertex selector based on the controls that are visible and what they contain.
"""
func _update_vertex_selector_string():
	var first_vertex_filter = vertex_comps_opt_1.get_item_text(vertex_comps_opt_1.get_selected_id())
	vertex_selector_txt.set_text(_get_filter_symbol(first_vertex_filter))

	# Add the first axis part of the selector string
	var first_vertex_axis = vertex_comps_opt_2.get_item_text(vertex_comps_opt_2.get_selected_id())
	var vertex_selector_string = vertex_selector_txt.get_text()
	vertex_selector_string += first_vertex_axis
	vertex_selector_txt.set_text(vertex_selector_string)

	# If the logic operator option button is visible, pull its value into the selector string
	if vertex_logic_option_button.visible:
		var logic_txt = vertex_logic_option_button.get_item_text(vertex_logic_option_button.get_selected_id())
		vertex_selector_string = vertex_selector_txt.get_text()
		vertex_selector_string += " " + logic_txt + " "
		vertex_selector_txt.set_text(vertex_selector_string)

	# If the second vertex filter option button is visible, pull its value
	if vertex_comps_opt_3.visible:
		print(vertex_comps_opt_3.get_item_text(vertex_comps_opt_3.get_selected_id()))
		var sec_vertex_selector_txt = _get_filter_symbol(vertex_comps_opt_3.get_item_text(vertex_comps_opt_3.get_selected_id()))
		vertex_selector_string = vertex_selector_txt.get_text()
		vertex_selector_string += sec_vertex_selector_txt
		vertex_selector_txt.set_text(vertex_selector_string)

	# If the second axis option button is visible, pull its value
	if vertex_comps_opt_4.visible:
		var sec_axis_selector_txt = vertex_comps_opt_4.get_item_text(vertex_comps_opt_4.get_selected_id())
		vertex_selector_string = vertex_selector_txt.get_text()
		vertex_selector_string += sec_axis_selector_txt
		vertex_selector_txt.set_text(vertex_selector_string)


"""
When in editing mode, uses a string that is passed in to set up the controls.
"""
func set_values_from_string(text_line):
	prev_template = text_line

	var rgx = RegEx.new()

	# Face selector
	rgx.compile(face_sel_edit_rgx)
	var res = rgx.search(text_line)
	if res:
		# Set the face selector controls
		var sel = res.get_string()
		set_face_sel_dropdowns_from_string(sel)

	# Edge selector
	rgx.compile(edge_sel_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Set the edge selector controls
		var sel = res.get_string()
		set_edge_sel_dropdowns_from_string(sel)

	# Vertex selector
	rgx.compile(vertex_sel_edit_rgx)
	res = rgx.search(text_line)
	if res:
		# Set the vertex selector controls
		var sel = res.get_string()
		set_vertex_sel_dropwdowns_from_string(sel)


"""
Parses the selector and sets the face selector dropdowns appropriately.
"""
func set_face_sel_dropdowns_from_string(sel_string):
	# Set the filter control
	var filter_text = _get_filter_text(sel_string.substr(0, 1))
	Common.set_option_btn_by_text(face_comps_opt_1, filter_text)

	# Handle the axis
	Common.set_option_btn_by_text(face_comps_opt_2, sel_string.substr(1, 1))
	face_comps_opt_2.show()

	# If there is a logic operator, we need to display the add/remove button properly
	var rgx = RegEx.new()
	rgx.compile(logic_edit_rgx)
	var res = rgx.search(sel_string)
	if res:
		extra_face_selector_adder.set_text("-")
		extra_face_selector_adder.show()

		# Show the face logic operator and set it to the correct value
		face_logic_option_button.show()
		Common.set_option_btn_by_text(face_logic_option_button, res.get_string())

		# Extract the second face selector
		var second_filter = null
		var second_axis = null
		rgx.compile(second_edit_rgx)
		res = rgx.search(sel_string)
		if res:
			var second_sel = res.get_string().split(" ")[1]
			second_filter = second_sel.substr(0, 1)
			second_axis = second_sel.substr(1, 1)

		# Show the second face's controls and set them appropriately
		Common.set_option_btn_by_text(face_comps_opt_3, _get_filter_text(second_filter))
		face_comps_opt_3.show()
		Common.set_option_btn_by_text(face_comps_opt_4, second_axis)
		face_comps_opt_4.show()

	# Make sure that the face selector string reflects the control settings
	_update_face_selector_string()


"""
Parses the selector and sets the edge selector dropdowns appropriately.
"""
func set_edge_sel_dropdowns_from_string(sel_string):
	# Set the filter control
	var filter_text = _get_filter_text(sel_string.substr(0, 1))
	Common.set_option_btn_by_text(edge_comps_opt_1, filter_text)

	# Handle the axis
	Common.set_option_btn_by_text(edge_comps_opt_2, sel_string.substr(1, 1))
	edge_comps_opt_2.show()

	# If there is a logic operator, we need to display the add/remove button properly
	var rgx = RegEx.new()
	rgx.compile(logic_edit_rgx)
	var res = rgx.search(sel_string)
	if res:
		extra_edge_selector_adder.set_text("-")
		extra_edge_selector_adder.show()

		# Show the edge logic operator and set it to the correct value
		edge_logic_option_button.show()
		Common.set_option_btn_by_text(edge_logic_option_button, res.get_string())

		# Extract the second edge selector
		var second_filter = null
		var second_axis = null
		rgx.compile(second_edit_rgx)
		res = rgx.search(sel_string)
		if res:
			var second_sel = res.get_string().split(" ")[1]
			second_filter = second_sel.substr(0, 1)
			second_axis = second_sel.substr(1, 1)

		# Show the second edge's controls and set them appropriately
		Common.set_option_btn_by_text(edge_comps_opt_3, _get_filter_text(second_filter))
		edge_comps_opt_3.show()
		Common.set_option_btn_by_text(edge_comps_opt_4, second_axis)
		edge_comps_opt_4.show()

	# Make sure that the edge selector string reflects the control settings
	_update_edge_selector_string()


"""
Sets the vertex selector controls based on a selector string.
"""
func set_vertex_sel_dropwdowns_from_string(sel_string):
	# Set the filter control
	var filter_text = _get_filter_text(sel_string.substr(0, 1))
	Common.set_option_btn_by_text(vertex_comps_opt_1, filter_text)

	# Handle the axis
	Common.set_option_btn_by_text(vertex_comps_opt_2, sel_string.substr(1, 1))
	vertex_comps_opt_2.show()

	# If there is a logic operator, we need to display the add/remove button properly
	var rgx = RegEx.new()
	rgx.compile(logic_edit_rgx)
	var res = rgx.search(sel_string)
	if res:
		extra_vertex_selector_adder.set_text("-")
		extra_vertex_selector_adder.show()

		# Show the vertex logic operator and set it to the correct value
		vertex_logic_option_button.show()
		Common.set_option_btn_by_text(vertex_logic_option_button, res.get_string())

		# Extract the second vertex selector
		var second_filter = null
		var second_axis = null
		rgx.compile(second_edit_rgx)
		res = rgx.search(sel_string)
		if res:
			var second_sel = res.get_string().split(" ")[1]
			second_filter = second_sel.substr(0, 1)
			second_axis = second_sel.substr(1, 1)

		# Show the second vertex selector's controls and set them appropriately
		Common.set_option_btn_by_text(vertex_comps_opt_3, _get_filter_text(second_filter))
		vertex_comps_opt_3.show()
		Common.set_option_btn_by_text(vertex_comps_opt_4, second_axis)
		vertex_comps_opt_4.show()

	# Make sure that the vertex selector string reflects the control settings
	_update_vertex_selector_string()
