import sys
from godot import exposed, Node, Array
from pkgutil import iter_modules
from importlib import import_module

@exposed
class discovery(Node):
	def discover(self, package_dir):
		mods = Array()

		package_dir = str(package_dir)

		for (loader, module_name, is_pkg) in iter_modules([package_dir]):
			if is_pkg:
				if module_name == "checks":
					continue
#				print(module_name)
				for (loader2, module_name2, is_pkg2) in iter_modules([package_dir + "/" + module_name]):
#					print("  " + module_name2)

					sys.path.append(package_dir)

					# spec=importlib.util.spec_from_file_location(module_name2, package_dir + "/" + module_name + "/" + module_name2 + ".py")
					# module = importlib.util.module_from_spec(spec)

					# module = import_module("{}.{}".format(__name__, module_name))
					module = import_module(module_name + "." + module_name2)
					for attribute_name in dir(module):
						if attribute_name.startswith("build_"):
							mods.append(module_name + "." + module_name2 + "." + attribute_name)
#							print(module_name + "." + module_name2 + "." + attribute_name)
						# attribute = getattr(module, attribute_name)

		return mods
