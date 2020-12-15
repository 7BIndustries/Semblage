extends Node
class_name ContextHandler

var cur_actions = {}
var cur_templates = {}
var latest_context_addition = null
var prev_object_addition = null
var latest_object_addition = null

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
		trig_rgx.compile(triggers[trigger].trigger)
		var trig_res = trig_rgx.search(context)

		# If this trigger matches, extract the info we can use to build controls
		if trig_res:
			action[trigger] = triggers[trigger].action

	return action


"""
Update the script context based on the string returned from the control.
"""
func update_context_string(context, addition):
	# Save this addition
	self.latest_context_addition = addition

	# Save the current and previous object additions, if any
	var tmp_obj = _get_object_from_context(self.latest_context_addition)
	if tmp_obj:
		# Save the previous object for editing purposes
		self.prev_object_addition = self.latest_object_addition

		# Save any objects that were added to the context
		self.latest_object_addition = tmp_obj

	# Create the new context based on the appropriate template of what comes next
	var new_context = context + self.latest_context_addition

	return new_context


"""
Alters the context string by replacing the old section with a new one.
"""
func edit_context_string(context, old_text, new_text):
	# Save this as the latest addition, if it is the one that changed
	if self.latest_context_addition == old_text:
		self.latest_context_addition = new_text

	# Save the current and previous object additions, if any
	var tmp_obj = _get_object_from_context(new_text)

	if tmp_obj:
		self.prev_object_addition = self.latest_object_addition
	
		self.latest_object_addition = tmp_obj

	var new_context = context.replace(old_text, new_text)

	return new_context

"""
Returns the latest action that was added to the script context.
"""
func get_latest_context_addition():
	return self.latest_context_addition


"""
Returns what the previous object addition's name was, if any.
"""
func get_prev_object_addition():
	return self.prev_object_addition


"""
Returns the latest object that was added to the script context.
"""
func get_latest_object_addition():
	return self.latest_object_addition


"""
Given a snippet of code, finds the Action control (if any) that matches it
so that an edit may be performed.
"""
func find_matching_edit_trigger(code_text):
	var matching_action = {}

	# Step through all the possible triggers, looking for matches
	for trigger in triggers.keys():
		var trig_rgx = RegEx.new()
		trig_rgx.compile(triggers[trigger]["edit_trigger"])
		var trig_res = trig_rgx.search(code_text)

		# If this trigger matches, extract the info we can use to build controls
		if trig_res:
			matching_action[trigger] = triggers[trigger].action
			break
	
	return matching_action


"""
Returns any tagged objects specified via tags in the context.
"""
func _get_object_from_context(context):
	# Use a regular expression to extract the tag names
	var object_rgx = RegEx.new()
	object_rgx.compile("(?<=tag\\(\")(.*)(?=\"\\))")
	var res = object_rgx.search(context)

	if res:
		return res.get_string()
	else:
		return null


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
