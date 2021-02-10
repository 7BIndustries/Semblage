extends Node

class_name Settings

const dev_mode = false
const path_sep = "/"
const cq_cli_name = "cq-cli/cq-cli"

"""
Returns the path to the cq-cli utility.
"""
static func get_cq_cli_path():
	var cq_cli_path = null

	# If we are in development mode, we use different paths
	if dev_mode:
		cq_cli_path = "/home/jwright/Downloads/repos/jmwright/cq-cli/cq-cli.py"
	else:
		# Get the path to the executable and use it to build the path to cq-cli
		var exe_path = OS.get_executable_path()
		var exe_name = exe_path.split(path_sep)[-1]
		cq_cli_path = exe_path.replace(exe_name, cq_cli_name)

	return cq_cli_path
