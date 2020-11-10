extends Node
class_name ContextHandler


"""
Adds constrols to the Actions popup based on the script text.
"""
func get_action_from_context(context):
	# Populate the menu with the workplane entries
	if context.ends_with('cq'):
		return "new_workplane"
	else:
		return "unknown"
