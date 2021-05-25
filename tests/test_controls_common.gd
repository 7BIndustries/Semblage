extends "res://addons/gut/test.gd"

var common = load("res://controls/Common.gd")

func option_button_setup():
	# Create an option button and add a couple of items to it
	var opt_btn = OptionButton.new()
	opt_btn.add_item("Test1")
	opt_btn.add_item("Test2")

	# Make sure Test1 is selected
	opt_btn.select(0)

	return opt_btn

"""
Tests the common controls code that sets an option button's selected
item based on a provided string, asuming it matches.
"""
func test_set_option_btn_by_text():
	# Create an option button and add a couple of items to it
	var opt_btn = option_button_setup()

	# Call the common method that should set the drop down based on a given string
	common.set_option_btn_by_text(opt_btn, "Test2")

	# Make sure the correct thing was selected
	var sel_text = opt_btn.get_item_text(opt_btn.get_selected_id())
	assert_eq(sel_text, "Test2")

	# Clean up
	opt_btn.free()

"""
Tests what happens when a string that does not match is passed to the
common controls code that sets an option button's selected item based
on the provided text.
"""
func test_set_option_btn_by_text_no_match():
	# Create an option button and add a couple of items to it
	var opt_btn = option_button_setup()

	# Call the common method that should set the drop down based on a given string
	common.set_option_btn_by_text(opt_btn, "Test3")

	# Make sure the correct thing was selected, which is the default
	var sel_text = opt_btn.get_item_text(opt_btn.get_selected_id())
	assert_eq(sel_text, "Test1")

	# Clean up
	opt_btn.free()
