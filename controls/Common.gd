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
