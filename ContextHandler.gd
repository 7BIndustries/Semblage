extends Node
class_name ContextHandler

var wp_template = ".Workplane(cq.Plane(origin=({origin_x},{origin_y},{origin_z}), xDir=(1,0,0), normal=({normal_x},{normal_y},{normal_z})))"

var triggers = load("res://Triggers.gd").new().triggers

"""
Looks for the next Action besed on its trigger and extract the needed controls.
"""
func get_next_action(context):
	var action = {}

	# Step through all the possible triggers, looking for matches
	for trigger in triggers.keys():
		# See if the trigger matches
		var trig_rgx = RegEx.new()
		trig_rgx.compile(trigger)
		var trig_res = trig_rgx.search(context)

		# If this trigger matches, extract the info we can use to build controls
		if trig_res:
			action = triggers[trigger].action

	return action
	
# Get any groups of controls
#var group_rgx = RegEx.new()
#group_rgx.compile("(?=\\w+\\=)(?<=\\()(.*?)(?=\\))")
#var group_res = group_rgx.search_all(triggers[trigger])
#if group_res:
#	print(group_res)
#	print(group_res[0].get_string())
#
## Get the individual controls in the group
#var ctrl_rgx = RegEx.new()
#ctrl_rgx.compile("(?<=\\{)(.*?)(?=\\})")
#var ctrl_res = ctrl_rgx.search_all(triggers[trigger])
#for res in ctrl_res:
#	var ctrl_parts = res.get_string().split(";")
#
#	ctrls[ctrl_parts[0]] = res.get_string()


"""
Adds constrols to the Actions popup based on the script text.
"""
func get_action_from_context(context):
	# Populate the menu with the workplane entries
	if context.ends_with('cq'):
		return "new_workplane"
	else:
		return "unknown"

"""
Updates the script context based on 
"""
func update_context(context, action_args):

	# Create the new context based on the appropriate template of what comes next
	var new_context = context + wp_template.format({
		"origin_x": action_args["origin_x"],
		"origin_y": action_args["origin_y"],
		"origin_z": action_args["origin_z"],
		"normal_x": action_args["normal_x"],
		"normal_y": action_args["normal_y"],
		"normal_z": action_args["normal_z"],
	})

	return new_context
	
	
"""
Get things that will not be tessellated during execution, like workplanes so
that they can be displayed as previews to the user.
"""
func get_untessellateds(context):
	var untessellateds = []

	# Check to see if there is an object that will be untessellated at the end of the context
	var regex = RegEx.new()
	regex.compile("Workplane\\(.*\\)$")
	var result = regex.search(context)
	
	# If we found an untessellated at the end of the context, figure out the dimensions
	if result:
		var untess = result.get_string()
		var origin_vec = Vector3(0, 0, 0)
		var normal_vec = Vector3(0, 0, 0)

		# Extract the origin from the Workplane string
		regex.compile("origin=(.*)")
		result = regex.search(untess)
		if result:
			var origin_parts = result.get_string().split("(")[1].split(")")[0].split(",")

			origin_vec[0] = float(origin_parts[0])
			origin_vec[1] = float(origin_parts[1])
			origin_vec[2] = float(origin_parts[2])
		
		# Extract the normal from the Workplane string
		regex.compile("normal=(.*)")
		result = regex.search(untess)
		if result:
			var normal_parts = result.get_string().split("(")[1].split(")")[0].split(",")

			normal_vec[0] = float(normal_parts[0])
			normal_vec[1] = float(normal_parts[1])
			normal_vec[2] = float(normal_parts[2])

		untessellateds.append({"origin": origin_vec, "normal": normal_vec, "width": 5, "height": 5, "depth": 0.1})

	return untessellateds
