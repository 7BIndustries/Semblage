extends VBoxContainer

signal redraw

class_name FilletControl

var template = ".fillet({fillet_radius})"

func _ready():
	add_child(SelectorControl.new())
