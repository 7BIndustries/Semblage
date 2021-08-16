tool
extends EditorPlugin

class Exporter extends EditorExportPlugin:
	var include_dirs = ["lib", "addons"]
	var include_files = []
	var output_root_dir

	"""
	Called by Godot when the export is started.
	"""
	func _export_begin(features, is_debug, path, flags):
		output_root_dir = path.get_base_dir()

		# Figure out which OS we are exporting for
		if path.find(".x86_64") > 0:
			print("Linux Export")
			self._export_dirs_linux(path)
		elif path.find(".exe") > 0:
			print("Windows Export")
			self._export_dirs_windows(path)
		else:
			print("MacOS Export")
			self._export_dirs_macos(path)


	"""
	Exports copies of any CadQuery related directories to the export location.
	"""
	func _export_dirs_linux(path):
		var replace_str = "/Semblage.x86_64"

		var dir = Directory.new()
		for d in include_dirs:
			var export_to_path = path.replace(replace_str, "") + "/" + d
			var export_from_path = ProjectSettings.globalize_path("res://") + d

			_copy_recursive(export_from_path, export_to_path)

		# Export the launcher script to make Semblage easier to launch
		var export_from_path = ProjectSettings.globalize_path("res://") + "scripts/Semblage_Linux.sh"
		var export_to_path = path.replace(replace_str, "") + "/Semblage"
		dir.copy(export_from_path, export_to_path)

		# Make sure the launcher is set to be executable
		OS.execute("chmod", ["+x", export_to_path])


	"""
	Exports copies of any CadQuery related directories to the export location.
	"""
	func _export_dirs_windows(path):
		var replace_str = "/Semblage.exe"

		var export_from_path = ProjectSettings.globalize_path("res://")
		var export_to_path = path.replace(replace_str, "")

		# Make the addons and lib directories so that we can copy data into them
#		var dir = Directory.new()
#		dir.make_dir_recursive(export_to_path + "/addons/pythonscript")
#		dir.make_dir(export_to_path + "/lib")

		_copy_recursive(export_from_path, export_to_path)

#		# Copy the PythonScript files over
#		_copy_recursive(export_from_path + "/addons/pythonscript/windows-64", export_to_path + "/addons/pythonscript/windows-64")
		_copy_recursive(export_from_path + "cq-cli-Windows/", export_to_path + "/addons/pythonscript/windows-64/DLLs")

	func _export_dirs_macos(path):
		var replace_str = "/Semblage.zip"

		var export_from_path = ProjectSettings.globalize_path("res://")
		var export_to_path = path.replace(replace_str, "")

	"""
	Allows us to copy directories via Godot's filesystem interface.
	"""
	func _copy_recursive(export_from_path, export_to_path):
		var dir = Directory.new()

		# Make sure the to location has the directory
		if not dir.dir_exists(export_to_path):
			dir.make_dir_recursive(export_to_path)

		# Open the from directory
		var error = dir.open(export_from_path)
		if error == OK:
			# Walk through the contents of the from directory
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					_copy_recursive(export_from_path + "/" + file_name, export_to_path + "/" + file_name)
				else:
					dir.copy(export_from_path + "/" + file_name, export_to_path + "/" + file_name)
				file_name = dir.get_next()
		else:
			print("Error copying " + export_from_path + " to " + export_to_path)


	"""
	Called by Godot during the export process.
	"""
	func _export_files(path, type, features):
		print("Export Files")


var _exporter = Exporter.new()

func _enter_tree():
	add_export_plugin(_exporter)


func _exit_tree():
	remove_export_plugin(_exporter)
