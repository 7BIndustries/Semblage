extends Node

class_name Settings

# Used when testing and adding new features to cq-cli
const cq_cli_dev_mode = false


"""
Returns the path to the cq-cli utility.
"""
static func get_cq_cli_path():
	var path_sep = "/"
	var cq_cli_name = "cq-cli/cq-cli"

	# Set the Windows path to cq-cli
	if OS.get_name() == "Windows":
		# If in dev mode, run cq-cli with the system Python
		if cq_cli_dev_mode:
			cq_cli_name = "cq-cli\\cq-cli.py"
		else:
			cq_cli_name = "cq-cli\\cq-cli.exe"

		# Save the path separators for the system
		path_sep = "\\"
	else:
		# If in dev mode, run cq-cli with the system Python
		if cq_cli_dev_mode:
			cq_cli_name = "cq-cli/cq-cli.py"

	var path = OS.get_executable_path()
	var exe_name = path.split(path_sep)[-1]
	path = path.replace(exe_name, cq_cli_name)

	return path
