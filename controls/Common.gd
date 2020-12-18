extends Node

class_name Common

"""
If the option button has matching text in an item, sets that to be the
selected item.
"""
func set_option_btn_by_text(opt_btn, name):
	for i in range(0, opt_btn.get_item_count()):
		var txt = opt_btn.get_item_text(i)

		# If the item matches, set it to be the selected id
		if txt == name:
			opt_btn.select(i)


"""
Loads an option button up with an array of items.
"""
func load_option_button(option_btn, items):
	for item in items:
		option_btn.add_item(item)
