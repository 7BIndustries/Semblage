extends Node2D

var lines = []  # Array of line start-end points to use to draw the line segments
var line_width = 5 # Line width can be adjusted for the size of the object
var max_dim = 1  # Largest dimension of the object being rendered


"""
Called when the node is asked to redraw its contents.
"""
func _draw():
	var par_size = get_parent().rect_size
	var par_loc = get_parent().rect_position

	# Draw all the lines that have been stored for the canvas
	for line in lines:
		var l0x = (line[0].x / (max_dim * 2)) * 550
		var l1x = (line[1].x / (max_dim * 2)) * 550
		var l0y = (line[0].y / (max_dim * 2)) * -550
		var l1y = (line[1].y / (max_dim * 2)) * -550

		# Line start and end points
		var v1 = Vector2(l0x + par_loc.x + par_size.x / 4.0, l0y + par_loc.y + par_size.y / 2.0)
		var v2 = Vector2(l1x + par_loc.x + par_size.x / 4.0, l1y + par_loc.y + par_size.y / 2.0)

		# Draw the line
		self.draw_line(v1, v2, Color(255, 255, 255), line_width)


"""
Used to set the maximum dimension for the sketch.
"""
func set_max_dim(dim):
	# Only save this if it is bigger than what we had before
	if dim > max_dim:
		max_dim = dim


"""
Resets the 2D sketch canvas back to the default values
"""
func reset():
	self.lines = []  # Array of line start-end points to use to draw the line segments
	self.line_width = 5 # Line width can be adjusted for the size of the object
	self.max_dim = 1  # Largest dimension of the object being rendered
