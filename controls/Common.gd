extends Reference

class_name Common

"""
If the option button has matching text in an item, set that to be the
selected item.
"""
static func set_option_btn_by_text(opt_btn, name):
	for i in range(0, opt_btn.get_item_count()):
		var txt = opt_btn.get_item_text(i)

		# If the item matches, set it to be the selected id
		if txt == name:
			opt_btn.select(i)


"""
If the option button has partially matching text in an item, set that to be the
selected item.
"""
static func set_option_btn_by_partial_text(opt_btn, name):
	for i in range(0, opt_btn.get_item_count()):
		var txt = opt_btn.get_item_text(i)

		# If the item matches, set it to be the selected id
		if txt.find(name) > 0:
			opt_btn.select(i)

"""
Loads an option button up with an array of items.
"""
static func load_option_button(option_btn, items):
	for item in items:
		option_btn.add_item(item)


"""
Adds a single item to the object tree.
"""
static func add_item_to_tree(new_object, tree, tree_root):
	if new_object and not _check_tree_item_exists(tree, new_object):
		var new_obj_item = tree.create_item(tree_root)
		new_obj_item.set_text(0, new_object)

"""
Adds an item with multiple columns to the object tree.
"""
static func add_columns_to_tree(cols, tree, tree_root):
	# Create the tree item that will be added
	var new_obj_item = tree.create_item(tree_root)

	# Loop through and add data to all the columns
	var i = 0
	for col in cols:
		new_obj_item.set_text(i, col)
		i += 1


"""
Searches the tree for a tree item with matching text and returns it
if it exists.
"""
static func get_tree_item_by_text(tree, text):
	var cur_item = tree.get_root().get_children()
	var res = null

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			# If we have a text match, update the matching TreeItem's text
			if cur_item.get_text(0) == text:
				res = cur_item
				break

			cur_item = cur_item.get_next()

	return res


"""
Lets the caller confirm if an item already exists in a tree.
"""
static func _check_tree_item_exists(tree, text):
	var cur_item = tree.get_root().get_children()

	# Search the tree to see if there is a match
	if cur_item == null:
		return false
	else:
		# If we have a text match, tell the caller that there was a matching item
		if cur_item.get_text(0) == text:
			return true


"""
Updates a matching item in the given tree with a new entry during an edit.
"""
static func update_tree_item(tree, old_text, new_text):
	var cur_item = tree.get_root().get_children()

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			# If we have a text match, update the matching TreeItem's text
			if cur_item.get_text(0) == old_text:
				cur_item.set_text(0, new_text)
				break

			cur_item = cur_item.get_next()


"""
Collects pairs from a tree so they can be inserted into a template.
"""
static func collect_pairs(tree):
	var pairs = ""

	var cur_item = tree.get_root().get_children()

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			pairs += "(" + cur_item.get_text(0) + "," + cur_item.get_text(1) + "),"

			cur_item = cur_item.get_next()

	return pairs


"""
Used to move an item up the order of items in the tree.
"""
static func move_tree_item_up(tree, selected):
	var i = 0
	var up_index = -1
	var up_item = null
	var items = []
	var cur_item = tree.get_root().get_children()

	# Get all the items in the tree so that we can reorder them
	while true:
		if cur_item == null or selected == null:
			break
		else:
			# Make sure the selected item gets re-inserted before the current item
			if cur_item.get_text(0) == selected.get_text(0) and i > 0:
				up_index = i - 1
				up_item = cur_item.get_text(0)
			else:
				items.append(cur_item.get_text(0))

		# Remove the item since we have a copy of it to re-insert
		tree.get_root().remove_child(cur_item)

		# Move to the next item
		i += 1
		cur_item = cur_item.get_next()

	i = 0
	# Add all of the nodes back, inserting the one that we need to move up
	for item in items:
		# Insert the selected item up one index from where it was
		if up_index == i:
			add_item_to_tree(up_item, tree, tree.get_root())

		add_item_to_tree(item, tree, tree.get_root())

		i += 1


"""
Activates a tree item based on its text.
"""
static func activate_tree_item(tree, item_text):
	var cur_item = tree.get_root().get_children()

	# Step through all of the items in the tree
	while true:
		if cur_item == null or item_text == null:
			break
		else:
			# See if the current entry contains the text to change
			if ".tag(\"" + item_text + "\")" in cur_item.get_text(0):
				cur_item.select(0)

		cur_item = cur_item.get_next()


"""
Allows a specific tree item to be selected based on its text.
"""
static func select_tree_item_by_text(tree, item_text):
	var cur_item = tree.get_root().get_children()

	# Step through all of the items in the tree
	while true:
		if cur_item == null or item_text == null:
			break
		else:
			# See if the current entry contains the text to change
			if item_text == cur_item.get_text(0):
				cur_item.deselect(0)
				cur_item.select(0)

		cur_item = cur_item.get_next()


"""
Used to move an item down the order of items in the tree.
"""
static func move_tree_item_down(tree, selected):
	var cur_item = tree.get_root().get_children()

	# To keep track of where we are in the order of child nodes
	var i = 0
	var selected_index = -1
	var tree_nodes = []

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null:
			break
		else:
			# If we have a text match, update the matching TreeItem's text
			if selected != null and cur_item.get_text(0) == selected.get_text(0):
				selected_index = i + 1

			# Insert the selected item after the current one unless
			# it cannot go any lower
			if i == selected_index:
				tree_nodes.append(cur_item.get_text(0))
				tree_nodes.append(selected.get_text(0))
			elif cur_item.get_text(0) != selected.get_text(0):
				tree_nodes.append(cur_item.get_text(0))

			# Get the next item while deleting the current one
			var cur_item_temp = cur_item
			cur_item = cur_item.get_next()

			# If this is not the selected item, remove it
			if cur_item_temp.get_text(0) != selected.get_text(0):
				cur_item_temp.free()

		i += 1

	# Do not remove the node if it has been moved down as far as it will go
	if selected_index != tree_nodes.size() + 1:
		# Remove the selected node
		selected.free()

	# Add all of the nodes back to the tree in the new order
	for node in tree_nodes:
		add_item_to_tree(node, tree, tree.get_root())
