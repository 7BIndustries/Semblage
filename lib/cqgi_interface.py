import os
import sys
import re
from godot import exposed, export, signal, Node, ResourceLoader, Dictionary, Array, Vector3
from cadquery import cqgi
from cadquery import Vector, Color, exporters


@exposed
class cqgi_interface(Node):
	build_success = signal()
	build_failure = signal()


	def get_render_tree(self, script_text):
		"""
		Executes and builds a hierarchal tree of everything that needs to be
		rendered, including things like workplanes.
		"""

		try:
			cq_model = cqgi.parse(str(script_text))
			build_result = cq_model.build({})

			# Make sure the build was successful
			if not build_result.success:
				return "error~" + str(build_result.exception)

			# The highest level render tree that holds all items (components and workplanes)
			render_tree = Dictionary()

			# All of the components and workplanes that the user has requested be rendered
			render_tree["components"] = Array()

			# For reference as the ability to select entities is implemented
	#		# Tessellate and store the object
	#		cur_comp["faces"] = Array() # Each face has references to the triangles that make it up
	#		cur_comp["wires"] = Array() # Each wire has references to the edges that make it up
	#		cur_comp["triangles"] = Array() # Each triangle has a reference to the face it belongs to
	#		cur_comp["edges"] = Array() # Each edge has a reference to the wire and/or triangle it belongs to
	#		cur_comp["edge_segments"] = Array() # Each edge segment has a reference to the edge(s) it belongs to
	#		cur_comp["vertices"] = Array() # Each vertex has a reference to the edge(s) or edge_segment(s) it belongs to

			for result in build_result.results:
				component_id = list(result.shape.ctx.tags)[0]

				cur_comp = Dictionary()
				cur_comp["id"] = component_id
				cur_comp["workplanes"] = Array()
				cur_comp["largest_dimension"] = 0

				# Figure out if we need to step back one step to get a non-workplane object
				tess_shape = result.shape.val()
				tess_edges = result.shape.edges()
				if len(result.shape.all()) == 0:
					is_base_wp = False

					# Work-around to find out if this is a base workplane
					try:
						 result.shape.end().end()
					except ValueError:
						is_base_wp = True

					# Get the origin, normal and center from the workplane
					origin_vec = Vector3(result.shape.val().x, result.shape.val().y, result.shape.val().z)
					normal_vec = Vector3(result.shape.plane.zDir.x, result.shape.plane.zDir.y, result.shape.plane.zDir.z)
					center_vec = Vector3(result.shape.plane.origin.x, result.shape.plane.origin.y, result.shape.plane.origin.z)

					# Get the appropriate size of the workplane, which is just a little larger than the underlying object
					try:
						wp_size = result.shape.end().largestDimension() + result.shape.end().largestDimension() * 0.1
					except:
						wp_size = 5

					# Start collecting the workplane info into a dictionary
					cur_wp = Dictionary()
					cur_wp["is_base"] = is_base_wp
					cur_wp["origin"] = origin_vec
					cur_wp["normal"] = normal_vec
					cur_wp["center"] = center_vec
					cur_wp["size"] = wp_size

					# Add the current workplane to the array
					cur_comp["workplanes"].append(cur_wp)

					# See if we can grab the previous shape
					try:
						tess_shape = result.shape.end().end().val()
					except:
						tess_shape = result.shape.val()
				# We have an object and we want to see if there is a previous workplane to display
				else:
					# See if we can grab the previous workplane
					try:
						prev_wp = result.shape.end()
					except:
						prev_wp = result.shape

					is_base_wp = False

					# See if we have a workplane
					if type(prev_wp.val()) is Vector:
						# Work-around to find out if this is a base workplane
						try:
							 prev_wp.end().end()
						except ValueError:
							is_base_wp = True

						# If it is not a base workplane we can set it up to be displayed
						if not is_base_wp:
							# Get the origin, normal and center from the workplane
							origin_vec = Vector3(prev_wp.val().x, prev_wp.val().y, prev_wp.val().z)
							normal_vec = Vector3(prev_wp.plane.zDir.x, prev_wp.plane.zDir.y, prev_wp.plane.zDir.z)
							center_vec = Vector3(prev_wp.plane.origin.x, prev_wp.plane.origin.y, prev_wp.plane.origin.z)
							wp_size = result.shape.largestDimension() + prev_wp.largestDimension() * 0.1

							# Compensate for offset workplanes not fitting into the view
							if origin_vec.x > cur_comp["largest_dimension"]:
								cur_comp["largest_dimension"] = origin_vec.x * 2
							if origin_vec.y > cur_comp["largest_dimension"]:
								cur_comp["largest_dimension"] = origin_vec.y * 2
							if origin_vec.z > cur_comp["largest_dimension"]:
								cur_comp["largest_dimension"] = origin_vec.z * 2

							# Start collecting the workplane info into a dictionary
							cur_wp = Dictionary()
							cur_wp["is_base"] = is_base_wp
							cur_wp["origin"] = origin_vec
							cur_wp["normal"] = normal_vec
							cur_wp["center"] = center_vec
							cur_wp["size"] = wp_size

							# Add the current workplane to the array
							cur_comp["workplanes"].append(cur_wp)

				# Tessellate the enclosed shape object
				smallest_dimension, largest_dimension,\
					vertices, edges, triangles, num_of_vertices,\
					num_of_edges, num_of_triangles = \
					self.tessellate(tess_shape, tess_edges)

				# Save the tessellation information
				cur_comp["smallest_dimension"] = smallest_dimension
				if cur_comp["smallest_dimension"] == 0:
					cur_comp["smallest_dimension"] = cur_comp["largest_dimension"]
				if largest_dimension > cur_comp["largest_dimension"]:
					cur_comp["largest_dimension"] = largest_dimension
				cur_comp["vertices"] = vertices
				cur_comp["edges"] = edges
				cur_comp["triangles"] = triangles
				cur_comp["num_of_vertices"] = num_of_vertices
				cur_comp["num_of_edges"] = num_of_edges
				cur_comp["num_of_triangles"] = num_of_triangles

				# Add the current component
				render_tree["components"].append(cur_comp)
		except Exception as err:
			ret = "error~" + str(err)
			return ret

		return render_tree


	"""
	Turns a shape into faces, edges and vertices.
	"""
	def tessellate(self, shape, shape_edges):
		loc = None
		largest_dimension = 0
		smallest_dimension = 999999999
		vertices = Array()
		triangles = Array()
		edges = Array()
		num_of_vertices = 0
		num_of_edges = 0
		num_of_triangles = 0

		# Protect against this being called with just a blank workplane object in the stack
		if hasattr(shape, "ShapeType"):
			tess = shape.tessellate(0.001)

			# Use the location, if there is one
			if loc is not None:
				loc_x = loc.X()
				loc_y = loc.Y()
				loc_z = loc.Z()
			else:
				loc_x = 0.0
				loc_y = 0.0
				loc_z = 0.0

			# Add vertices
			for v in tess[0]:
				vertices.append(v.x + loc_x)
				vertices.append(v.y + loc_y)
				vertices.append(v.z + loc_z)
				#vertices.append(Vector3(v.x + loc_x, v.y + loc_y, v.z + loc_z))
				num_of_vertices += 1

			# Add triangles
			for ixs in tess[1]:
				triangles.append(ixs[0])
				triangles.append(ixs[1])
				triangles.append(ixs[2])
				#triangles.append(Vector3(*ixs))
				num_of_triangles += 1

			# Add CadQuery-reported vertices
#			for vert in shape.Vertices():
#				mesher.addCQVertex(vert.X, vert.Y, vert.Z)

			# Add CadQuery-reported edges
			for edge in shape_edges.edges().all():#shape.Edges():
				edge = edge.val()
				gt = edge.geomType()

				# Find out if the shape is larger than the largest bounding box we have recorded so far
				if shape.BoundingBox().DiagonalLength > largest_dimension:
					largest_dimension = shape.BoundingBox().DiagonalLength

				# Handle objects that may not be at the origin
				if shape.BoundingBox().xmax > largest_dimension:
					largest_dimension = shape.BoundingBox().xmax
				if shape.BoundingBox().ymax > largest_dimension:
					largest_dimension = shape.BoundingBox().ymax
				if shape.BoundingBox().zmax > largest_dimension:
					largest_dimension = shape.BoundingBox().zmax

				# Find the smallest dimension so that we can use that for the line width
				if shape.BoundingBox().xlen > 0.01 and shape.BoundingBox().xlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().xlen
				if shape.BoundingBox().ylen > 0.01 and shape.BoundingBox().ylen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().ylen
				if shape.BoundingBox().zlen > 0.01 and shape.BoundingBox().zlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().zlen

				# If dealing with some sort of arc, discretize it into individual lines
				if gt == "CIRCLE" or gt == "ARC" or gt == "SPLINE" or gt == "BSPLINE" or gt == "ELLIPSE":
					from OCP import GCPnts, BRepAdaptor

					# Discretize the curve
					disc = GCPnts.GCPnts_TangentialDeflection(BRepAdaptor.BRepAdaptor_Curve(edge.wrapped), 0.5, 0.01)

					# Add each of the discretized sections to the edge list
					if disc.NbPoints() > 1:
						for i in range(2, disc.NbPoints() + 1):
							p_0 = disc.Value(i - 1)
							p_1 = disc.Value(i)

							# Add the start and end vertices for this edge
							# mesher.addCQEdge
							edge = Array()
							edge.append(Vector3(p_0.X(), p_0.Y(), p_0.Z()))
							edge.append(Vector3(p_1.X(), p_1.Y(), p_1.Z()))
							edges.append(edge)
							num_of_edges += 1
				else:
					# Handle simple lines by collecting their beginning and end points
					i = 0
					x1 = 0
					x2 = 0
					y1 = 0
					y2 = 0
					z1 = 0
					z2 = 0
					for vert in edge.Vertices():
						if i == 0:
							x1 = vert.X
							y1 = vert.Y
							z1 = vert.Z
						else:
							x2 = vert.X
							y2 = vert.Y
							z2 = vert.Z

						i += 1

					# mesher.addCQEdge
					edge = Array()
					edge.append(Vector3(x1, y1, z1))
					edge.append(Vector3(x2, y2, z2))
					edges.append(edge)
					num_of_edges += 1

		return (smallest_dimension, largest_dimension, vertices, edges, triangles, num_of_vertices, num_of_edges, num_of_triangles)

	def execute(self, script_text):
		"""
		Executes/builds the given script text and returns the
		CQGI build result.
		"""

		# Add the Python library and package paths
		# if sys.platform.startswith('linux'):
		# 	sys.path.insert(0, 'addons/pythonscript/x11-64/lib')
		# elif sys.platform.startswith('darwin'):
		# 	sys.path.insert(0, 'addons/pythonscript/osx-64/lib')
		# elif sys.platform.startswith('win32'):
		# 	sys.path.insert(0, 'addons/pythonscript/windows-64/lib')

		cq_model = cqgi.parse(str(script_text))
		build_result = cq_model.build({})

		return build_result


	def opts_string_to_dict(self, opts_str):
		output_opts = {}

		# Convert the string of options into a output_opts dictionary
		groups = opts_str.split(';')
		for group in groups:
			opt_parts = group.split(':')
			# Protect against a trailing semi-colon
			if len(opt_parts) == 2:
				op1 = opt_parts[1]

				# Handle the option data types properly
				if op1 == "True" or op1 == "False":
					op = opt_parts[1] == "True"
				elif op1[:1] == "(":
					op = tuple(map(float, opt_parts[1].replace("(", "").replace(")", "").split(',')))
				elif "." in op1:
					op = float(opt_parts[1])
				else:
					op = int(opt_parts[1])

				output_opts[opt_parts[0]] = op

		return output_opts


	def export(self, script_text, export_type, user_dir_path, opts=None):
		"""
		Allows the caller to export a component.
		"""

		# Add the Python library and package paths
		# if sys.platform.startswith('linux'):
		# 	sys.path.insert(0, 'addons/pythonscript/x11-64/lib')
		# elif sys.platform.startswith('darwin'):
		# 	sys.path.insert(0, 'addons/pythonscript/osx-64/lib')
		# elif sys.platform.startswith('win32'):
		# 	sys.path.insert(0, 'addons/pythonscript/windows-64/lib')

		ret = ""

		# Convert the options string to something useable by the exporter
		if opts != None:
			opts = self.opts_string_to_dict(str(opts))

		# Temporary path that the file is being exported to	
		export_path = os.path.join(str(user_dir_path), "temp_file")

		# Build/execute the script and get the CQGI build result back
		try:
			build_result = self.execute(script_text)
		except Exception as err:
			ret = "error~" + err
			return ret

		# Whether or not the export succeeded
		success = False

		# Convert the Godot string to a Python string
		export_type = str(export_type)

		# Handle the case of the build not being successful, otherwise pass the codec the build result
		if not build_result.success:
			ret = "error~" + str(build_result.exception)
		else:
			if export_type == "stl":
				for result in build_result.results:
					try:
						# Export the STL to the temporary location in the user data directory
						success = result.shape.val().exportStl(export_path, 1e-3, 0.1)
					except Exception as err:
						ret = "error~There was an error exporting to STL: " + err
						return ret
			elif export_type == "step":
				for result in build_result.results:
					try:
						# Export the STEP to the temporary location in the user data directory
						success = result.shape.val().exportStep(export_path)
					except Exception as err:
						ret = "error~There was an error exporting to STEP: " + err
						return ret
			elif export_type == "dxf":
				for result in build_result.results:
					try:
						# Export the DXF to the temporary location in the user data directory
						exporters.export(result.shape, export_path, exporters.ExportTypes.DXF)
					except Exception as err:
						ret = "error~There was an error exporting to DXF.  If you are slicing a DXF\ninto sections, make sure your slices do not extend past the\nbounds of the component."
						return ret

					# Export the SVG to the temporary location in the user data directory
					success = True
			elif export_type == "svg":
					# Export the SVG to the temporary location in the user data directory
					success = True

					# The file needs the svg extension or Godot will not load it
					export_path += ".svg"

					# Step through all of the results and export them
					# Right now this process assumes a single object was created
					for result in build_result.results:
						try:
							exporters.export(result.shape, export_path, exporters.ExportTypes.SVG, opt=opts)
						except Exception as err:
							ret = "error~There was an error exporting to SVG. If you are slicing an SVG\ninto sections, make sure your slices do not extend past the\nbounds of the component."
							return ret
			else:
				# Fake out the next check so that we can return a custom error
				success = True
				ret = "error~The export file extension of " + export_type + " was not recognized."

			# Return exported path on success, otherwise let the user know the export failed
			if success:
				ret = export_path
			else:
				ret = "error~The file could not be exported."

		return ret


	def build(self, script_text):
		"""
		Called by Godot to build and return the tessellated result of the script.
		"""

		try:
			# Execute the script and get the build result
			build_result = self.execute(script_text)

			# Handle the case of the build not being successful, otherwise pass the codec the build result
			if not build_result.success:
				component_json = "error~" + str(build_result.exception)
			else:
				components = []
				# Display all the results that the caller
				for result in build_result.results:
					component = []
					component.append(result.shape.val())
					component.append(result.shape.largestDimension())
					component.append(None)
					component.append(None)
					component.append(999999999)

					components.append(component)

				component_json = convert_components(components)
		except Exception as err:
			component_json = "error~" + str(err)

		return component_json
