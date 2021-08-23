extends Reference

class_name FileSystem

"""
Used to write the component text to a temporary file
so that the result can be displayed.
"""
static func save_component(path, component_text):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(component_text)
	file.close()


"""
Used to clear a file after a successful execution.
"""
static func clear_file(path):
	save_component(path, "")


"""
Loads the text of a file into a string to be manipulated by the GUI.
"""
static func load_file_text(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()

	return text
