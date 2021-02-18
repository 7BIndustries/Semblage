extends Node

class_name Security

"""
Checks if there imports other than cadquery.
"""
static func CheckImports(script_text):
	var imports = []

	var rgx = RegEx.new()

	# Center X and Y locations
	rgx.compile("import.*")
	var res = rgx.search_all(script_text)
	if res:
		for imp in res:
			if imp.get_string() != "import cadquery as cq" and imp.get_string() != "import cadquery":
				imports.append(imp.get_string())

	return imports


"""
Checks if a script contains the semblage comment
at the beginning.
"""
static func IsSemblageFile(script_text):
	if script_text.begins_with("# Semblage v"):
		return true
	else:
		return false
