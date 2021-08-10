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

		self._export_dirs(path)


	"""
	Exports copies of any CadQuery related directories to the export location.
	"""
	func _export_dirs(path):
		var dir = Directory.new()
		for d in include_dirs:
			var export_from_path = ProjectSettings.globalize_path("res://") + d
			var export_to_path = path.replace("/Semblage.x86_64", "") + "/" + d
			_copy_recursive(export_from_path, export_to_path)


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
