extends Reference

class_name ContextHandler


"""
Looks for the next Action besed on its trigger and extract the needed controls.
"""
static func get_next_action(context):
	var action = {}

	# Step through all the possible triggers, looking for matches
	for trigger in Triggers.get_triggers().keys():
		# See if the trigger matches
		var trig_rgx = RegEx.new()
		trig_rgx.compile(Triggers.get_triggers()[trigger].trigger)
		var trig_res = trig_rgx.search(context)

		# If this trigger matches, extract the info we can use to build controls
		if trig_res:
			action[trigger] = Triggers.get_triggers()[trigger].action

	return action


"""
Update the script context based on the string returned from the control.
"""
static func update_context_string(context, addition):
	# Create the new context based on the appropriate template of what comes next
	var new_context = context + "\n" + "result = result" + addition

	return new_context


"""
Alters the context string by replacing the old section with a new one.
"""
static func edit_context_string(context, old_text, new_text):
	var new_context = context.replace(old_text, new_text)

	return new_context


"""
Given a snippet of code, finds the Action control (if any) that matches it
so that an edit may be performed.
"""
static func find_matching_edit_trigger(code_text):
	var matching_action = {}

	# Check to see if this is a binary operation (i.e. boolean)
	var is_binary = is_binary(code_text)
	if is_binary:
		code_text = "." + code_text.split(".", false, 1)[1]

	# Check to see if there is a leading workplane entry
	var starts_with_wp = starts_with_workplane(code_text)
	if starts_with_wp != null:
		code_text = code_text.replace(starts_with_wp, ".")

	# Step through all the possible triggers, looking for matches
	for trigger in Triggers.get_triggers().keys():
		var trig_rgx = RegEx.new()
		trig_rgx.compile(Triggers.get_triggers()[trigger]["edit_trigger"])
		var trig_res = trig_rgx.search(code_text)

		# If this trigger matches, extract the info we can use to build controls
		if trig_res:
			matching_action[trigger] = Triggers.get_triggers()[trigger].action
			break

	return matching_action


"""
Returns the tagged object specified in the given template.
"""
static func get_object_from_template(template):
	# Use a regular expression to extract the tag names
	var object_rgx = RegEx.new()
	object_rgx.compile("(?<=tag\\(\")(.*)(?=\"\\))")
	var res = object_rgx.search(template)

	if res:
		return res.get_string()
	else:
		return null


"""
Allows the caller to pull all component tag names from the given context.
"""
static func get_objects_from_context(context):
	# Use a regular expression to extract the tag names
	var object_rgx = RegEx.new()
	object_rgx.compile("(?<=tag\\(\")(.*)(?=\"\\))")
	var res = object_rgx.search_all(context)

	if res != null and res.size() > 0:
		return res
	else:
		return null


"""
Get things that will not be tessellated during execution, like workplanes so
that they can be displayed as previews to the user.
"""
static func get_untessellateds(context):
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
		else:
			origin_vec[0] = 0.0
			origin_vec[1] = 0.0
			origin_vec[2] = 0.0

		# Extract the normal from the Workplane string
		regex.compile("normal=(.*)")
		result = regex.search(untess)
		if result:
			var normal_parts = result.get_string().split("(")[1].split(")")[0].split(",")

			normal_vec[0] = float(normal_parts[0])
			normal_vec[1] = float(normal_parts[1])
			normal_vec[2] = float(normal_parts[2])
		else:
			# Allow us to invert the normal indicator prism
			var norm_multiplier = 1
			if untess.find("invert=True") > 0:
				norm_multiplier = -1

			if untess.find("XY") > 0:
				normal_vec[0] = 0
				normal_vec[1] = 0
				normal_vec[2] = 1 * norm_multiplier
			elif untess.find("YZ") > 0:
				normal_vec[0] = 1 * norm_multiplier
				normal_vec[1] = 0
				normal_vec[2] = 0
			elif untess.find("XZ") > 0:
				normal_vec[0] = 0
				normal_vec[1] = 1 * norm_multiplier
				normal_vec[2] = 0

		untessellateds.append({"origin": origin_vec, "normal": normal_vec, "width": 5, "height": 5, "depth": 0.1})

	return untessellateds


"""
Filters out to only 2D actions.
"""
static func get_2d_actions():
	var two_d_actions = []

	# Grab only actions from the 2D group
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.group == "2D":
			two_d_actions.append(Triggers.get_triggers()[trigger].action.name)

	return two_d_actions


"""
Filters out to only 3D actions.
"""
static func get_3d_actions():
	var three_d_actions = []

	# Grab only actions from the 2D group
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.group == "3D":
			three_d_actions.append(Triggers.get_triggers()[trigger].action.name)

	return three_d_actions


"""
Filters out to only workplane actions.
"""
static func get_wp_actions():
	var wp_actions = []

	# Grab only actions from the Workplane group
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.group == "WP":
			wp_actions.append(Triggers.get_triggers()[trigger].action.name)

	return wp_actions


"""
Filters out only selector actions.
"""
static func get_selector_actions():
	var selector_actions = []

	# Grab only actions from the selector group
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.group == "SELECTORS":
			selector_actions.append(Triggers.get_triggers()[trigger].action.name)

	return selector_actions

"""
Gets the matching action given the action's name.
"""
static func get_action_for_name(name):
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.name == name:
			return Triggers.get_triggers()[trigger]

	return null


"""
Used to find the help tooltip that is associated with the operation.
"""
static func find_action_tooltip_by_name(action_name):
	for trigger in Triggers.get_triggers().keys():
		if Triggers.get_triggers()[trigger].action.name == action_name:
			if Triggers.get_triggers()[trigger].action.has("tooltip"):
				return Triggers.get_triggers()[trigger].action["tooltip"]


"""
Used to determine whether or not the user wants/needs an implicit main workplane.
"""
static func needs_implicit_worplane(context):
	var regex = RegEx.new()
	regex.compile("\\.Workplane\\(")
	var res = regex.search(context)

	# The value to return
	var ret = false

	# If there was no match, alert the caller that a workplane will have to be added
	if not res:
		ret = true

	return ret


"""
Detects whether or not the statement is a binary (i.e. boolean) where
two objects/components are used together.
"""
static func is_binary(item_text):
	# See if this is a binary (i.e. boolean) item
	var is_binary = false

	var rgx = RegEx.new()
	rgx.compile("^[a-zA-Z0-9_]+")
	var res = rgx.search(item_text)
	if res:
		is_binary = true

	return is_binary


"""
Tells whether a line starts with a workplane reference.
"""
static func starts_with_workplane(item_text):
	# Check to see if there is a leading workplane entry
	var starts_with_wp = null

	var rgx = RegEx.new()
	rgx.compile("^\\.workplane\\(.*\\)\\.")
	var res = rgx.search(item_text)
	if res:
		starts_with_wp = res.to_string()

	return starts_with_wp
