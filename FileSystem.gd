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


"""
Determines the parent directory given a path string.
"""
static func find_parent_dir(path):
	var path_parts = path.split('/')

	# Remove the directory/file from the end of the path
	var par_path = path.replace(path_parts[-1], '')

	return par_path


"""
Extracts the destination file/directory from a given path.
"""
static func find_end_of_path(path):
	var path_parts = path.split('/')

	return path_parts[-1]
