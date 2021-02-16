extends Node

class_name Common

"""
If the option button has matching text in an item, sets that to be the
selected item.
"""
static func set_option_btn_by_text(opt_btn, name):
	for i in range(0, opt_btn.get_item_count()):
		var txt = opt_btn.get_item_text(i)

		# If the item matches, set it to be the selected id
		if txt == name:
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
	var cur_item = tree.get_root().get_children()

	# To keep track of where we are in the order of child nodes
	var i = 0
	var selected_index = 0
	var tree_nodes = []

	# Search the tree and update the matchine entry in the tree
	while true:
		if cur_item == null or selected == null:
			break
		else:
			# If we have a text match, update the matching TreeItem's text
			if cur_item.get_text(0) == selected.get_text(0):
				selected_index = i - 1

				# Insert the selected item before the current one unless
				# it cannot go any higher
				if selected_index > 0:
					tree_nodes.insert(selected_index, cur_item.get_text(0))
				else:
					tree_nodes.append(cur_item.get_text(0))
			else:
				tree_nodes.append(cur_item.get_text(0))

			# Get the next item while deleting the current one
			var cur_item_temp = cur_item
			cur_item = cur_item.get_next()
			cur_item_temp.free()

		i += 1

	# Add all of the nodes back to the tree in the new order
	for node in tree_nodes:
		add_item_to_tree(node, tree, tree.get_root())


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
