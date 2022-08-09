import os
import sys
import re
import uuid
import json
from contextlib import ExitStack, contextmanager
from godot import exposed, export, signal, Node, ResourceLoader, Dictionary, Array, Vector3
from cadquery import cqgi
from cadquery import Vector, Color, exporters
from OCP.TopLoc import TopLoc_Location
from OCP.BRep import BRep_Tool
from OCP.BRepMesh import BRepMesh_IncrementalMesh
from OCP.TopAbs import TopAbs_Orientation
from OCP.BRepAdaptor import BRepAdaptor_Surface
from OCP.BRep import BRep_Tool


@contextmanager
def module_manager():
	""" unloads any modules loaded while the context manager is active """
	loaded_modules = set(sys.modules.keys())

	try:
		yield
	finally:
		new_modules = set(sys.modules.keys()) - loaded_modules
		for module_name in new_modules:
			del sys.modules[module_name]


@exposed
class cqgi_interface(Node):
	build_success = signal()
	build_failure = signal()

	def set_script_path(self, script_path):
		"""
		Allows a component's current directory to be added to the PYTHONPATH.
		"""
		script_path = str(script_path)
		if script_path not in sys.path:
			sys.path.append(script_path)

	def get_render_tree(self, script_text):
		"""
		Executes and builds a hierarchal tree of everything that needs to be
		rendered, including things like workplanes.
		"""

		try:
			with ExitStack() as stack:
				stack.enter_context(module_manager())
				script_text = str(script_text)

				cq_model = cqgi.parse(script_text)
				build_result = cq_model.build({})

				# Make sure the build was successful
				if not build_result.success:
					return "error~" + str(build_result.exception)

				# The highest level render tree that holds all items (components and workplanes)
				render_tree = Dictionary()

				# All of the components and workplanes that the user has requested be rendered
				render_tree["components"] = Array()

				# Step through each of the objects returned from script execution
				cnt = 0
				for result in build_result.results:
					component_id = list(result.shape.ctx.tags)[0]

					cur_comp = Dictionary()
					cur_comp["id"] = component_id
					cur_comp["workplanes"] = Array()

					# We cannot get the largest dimension if there are no solids
					if type(result.shape.val()).__name__ != "Vector" and type(result.shape.val()).__name__ != "Location":
						cur_comp["largest_dimension"] = result.shape.val().BoundingBox().DiagonalLength
					else:
						cur_comp["largest_dimension"] = 5.0

					# Break out the metadata line
					meta_line = re.findall('.*# meta.*', script_text)
					if meta_line:
						meta_data = meta_line[cnt].split("meta ")
						cnt += 1

						# Break out the color data from the metadata
						if len(meta_data) > 1:
							# Clean up and parse the metadata JSON string
							meta_data = meta_data[1].replace(" ", "")

							rgba = json.loads(meta_data)

							# Make sure the component carries the color metadata
							if "color_r" in meta_data:
								cur_comp["rgba"] = Array()
								cur_comp["rgba"].append(rgba["color_r"])
								cur_comp["rgba"].append(rgba["color_g"])
								cur_comp["rgba"].append(rgba["color_b"])
								cur_comp["rgba"].append(rgba["color_a"])

					# Figure out if we need to step back one step to get a non-workplane object
					tess_shape = result.shape.val()
					tess_edges = result.shape.edges()

					obj = None

					# See if we have a workplane, which is represented by a Vector type
					if type(result.shape.val()).__name__ == "Vector":
						# Get the origin, normal and center from the workplane
						origin_vec = Vector3(result.shape.val().x, result.shape.val().y, result.shape.val().z)
						normal_vec = Vector3(result.shape.plane.zDir.x, result.shape.plane.zDir.y, result.shape.plane.zDir.z)
						center_vec = Vector3(result.shape.plane.origin.x, result.shape.plane.origin.y, result.shape.plane.origin.z)

						# Get the appropriate size of the workplane, which is just a little larger than the underlying object
						try:
							wp_size = result.shape.end().end().largestDimension() + result.shape.end().largestDimension() * 0.1
						except:
							wp_size = 5.0

						# Start collecting the workplane info into a dictionary
						cur_wp = Dictionary()
						cur_wp["origin"] = origin_vec
						cur_wp["normal"] = normal_vec
						cur_wp["center"] = center_vec
						cur_wp["size"] = wp_size

						# Add the current workplane to the array
						cur_comp["workplanes"].append(cur_wp)

						# Add the current component, even if it only contains a workplane
						render_tree["components"].append(cur_comp)
					elif type(result.shape.val()).__name__ == "Face":
						# Grab the previous solid
						tess_shape = result.shape.end().val()
						tess_edges = result.shape.end().edges()

						# Tessellate the enclosed shape object
						obj = self.tess(tess_shape, tess_edges)
					elif type(result.shape.val()).__name__ == "Wire" or type(result.shape.val()).__name__ == "Edge":
						# Grab the current wire
						tess_shape = result.shape.val()
						tess_edges = result.shape.edges()
						obj = self.tess(tess_shape, tess_edges)

						try:
							# Find the workplane that the wire should be sitting on
							for i in range(0, 20):
								# Make sure the current object is either a solid or a compound
								if type(result.shape.end(i).val()).__name__ == "Vector":
									wp_obj = result.shape.end(i)

									# We have found what we needed
									break

							# Get the origin, normal and center from the workplane
							origin_vec = Vector3(wp_obj.val().x, wp_obj.val().y, wp_obj.val().z)
							normal_vec = Vector3(wp_obj.plane.zDir.x, wp_obj.plane.zDir.y, wp_obj.plane.zDir.z)
							center_vec = Vector3(wp_obj.plane.origin.x, wp_obj.plane.origin.y, wp_obj.plane.origin.z)

							# Get the appropriate size of the workplane, which is just a little larger than the underlying object
							try:
								wp_size = result.shape.end().end().largestDimension() + result.shape.end().largestDimension() * 0.1

								# Make sure that we are not dealing with a 2D system instead of 3D
								if wp_size <= 0.0:
									wp_size = 5.0
							except:
								wp_size = 5.0

							# Start collecting the workplane info into a dictionary
							cur_wp = Dictionary()
							cur_wp["origin"] = origin_vec
							cur_wp["normal"] = normal_vec
							cur_wp["center"] = center_vec
							cur_wp["size"] = wp_size

							# Add the current workplane to the array
							cur_comp["workplanes"].append(cur_wp)
						except Exception as err:
							print(err)

						try:
							# Grab the previous solid for context
							tess_shape = result.shape.end().end().end().val()
							tess_edges = result.shape.end().end().end().edges()

							# Tessellate the enclosed shape object
							obj_extra = self.tess(tess_shape, tess_edges)

							# Get the ID of the previous solid
							component_id_extra = list(result.shape.end().end().end().ctx.tags)[0]

							# Set up the previous solid component so that it can be displayed
							cur_comp_extra = Dictionary()
							cur_comp_extra["id"] = component_id_extra
							cur_comp_extra["workplanes"] = Array()
							cur_comp_extra["largest_dimension"] = result.shape.end().end().end().largestDimension()
							cur_comp_extra["smallest_dimension"] = obj_extra["smallest_dimension"]
							if cur_comp_extra["smallest_dimension"] == 0:
								cur_comp_extra["smallest_dimension"] = cur_comp_extra["largest_dimension"]
							cur_comp_extra["line_dimension"] = obj_extra["line_dimension"]
							cur_comp_extra["faces"] = obj_extra["faces"]
							cur_comp_extra["edges"] = obj_extra["edges"]
							cur_comp_extra["vertices"] = obj_extra["vertices"]

							# Add the current component
							render_tree["components"].append(cur_comp_extra)
						except:
							pass
					else:
						# Tessellate the enclosed shape object
						obj = self.tess(tess_shape, tess_edges)

					# If we have something other than a solid or compound, find the last solid or
					base_obj = None
					if result.shape != None and type(result.shape.val()).__name__ != "Solid" and type(result.shape.val()).__name__ != "Compound":
						try:
							for i in range(0, 20):
								# Make sure the current object is either a solid or a compound
								if type(result.shape.end(i).val()).__name__ == "Solid" or type(result.shape.end(i).val()).__name__ == "Compound":
									parent_obj = result.shape.end(i)
									tess_shape = parent_obj.val()
									tess_edges = parent_obj.edges()

									# Tessellate the enclosed shape object
									if obj == None:
										obj = self.tess(tess_shape, tess_edges)
									else:
										base_obj = self.tess(tess_shape, tess_edges)

									# We have found what we needed
									break
						except Exception as err:
							pass

					# Grab the previous solid, if there is one
#					try:
#						tess_shape = result.shape.end().end().val()
#						tess_edges = result.shape.end().end().edges()
#
#						# Tessellate the enclosed shape object
#						obj = self.tess(tess_shape, tess_edges)
#					except:
#						# We do not want to flood the user with unimportant messages
#						pass

					# Save the tessellation information, if there was a tessellatable object
					if obj != None:
						cur_comp["smallest_dimension"] = obj["smallest_dimension"]
						cur_comp["line_dimension"] = obj["line_dimension"]
						if cur_comp["smallest_dimension"] == 0:
							cur_comp["smallest_dimension"] = cur_comp["largest_dimension"]
						cur_comp["faces"] = obj["faces"]
						cur_comp["edges"] = obj["edges"]
						cur_comp["vertices"] = obj["vertices"]

						# Add the base object's geometry in addition to the main object's
						if base_obj != None:
							for bf in base_obj["faces"].keys():
								cur_comp["faces"][bf] = base_obj["faces"][bf]
							for be in base_obj["edges"]:
								cur_comp["edges"][be] = base_obj["edges"][be]
#							for bv in base_obj["vertices"]:
#								cur_comp["vertices"][bv] = base_obj["vertices"][bv]
					else:
						cur_comp["smallest_dimension"] = 1.0
						cur_comp["largest_dimension"] = 5.0
						cur_comp["faces"] = Array()
						cur_comp["edges"] = Array()
						cur_comp["vertices"] = Array()

					# Add the current component
					render_tree["components"].append(cur_comp)
		except Exception as err:
			import traceback
			traceback.print_exc()
			ret = "error~" + str(err)
			return ret

		# Handles the case of there being only adges in the component(s)
		if len(render_tree["components"]) > 0 and render_tree["components"][0]["largest_dimension"] == -1:
			render_tree["components"][0]["largest_dimension"] = render_tree["components"][0]["smallest_dimension"]

		return render_tree


	def tess(self, shape, cq_shape):
		"""
		Handles converting a CadQuery object to a tessellated/mesh version.
		"""
		line_dimension = 0
		smallest_dimension = 999999999
		workplanes = Array()
		shape_tess = Dictionary()
		faces_tess = Dictionary()
		triangles_tess = Dictionary()
		wires_tess = Dictionary()
		edges_tess = Dictionary()
		edge_segment_tess = Array()
		vertices_tess = Array()
		tolerance = 0.1
		angular_tolerance = 0.1
		vertices = []

		offset = 0

		# Protect against this being called with just a blank workplane object in the stack
		if hasattr(shape, "ShapeType"):
			# Find the min and max size of the bounding box
			min = 999999999
			max = 0
			if shape.BoundingBox().xlen > 0 and shape.BoundingBox().xlen > max:
				max = shape.BoundingBox().xlen
			if shape.BoundingBox().ylen > 0 and shape.BoundingBox().ylen > max:
				max = shape.BoundingBox().ylen
			if shape.BoundingBox().zlen > 0 and shape.BoundingBox().zlen > max:
				max = shape.BoundingBox().zlen
			if shape.BoundingBox().xlen > 0 and shape.BoundingBox().xlen < min:
				min = shape.BoundingBox().xlen
			if shape.BoundingBox().ylen > 0 and shape.BoundingBox().ylen < min:
				min = shape.BoundingBox().ylen
			if shape.BoundingBox().zlen > 0 and shape.BoundingBox().zlen < min:
				min = shape.BoundingBox().zlen

			# Use factors of 10 of the ratio of the min and max to set the edge line thickness
			if min > 0 and max > 0:
				ratio = min / max
			else:
				ratio = -1
			if ratio > 0 and ratio <= 10:
				diag = max * 0.005
			elif ratio > 10 and ratio <= 100:
				diag = max * 0.05
			else:
				diag = max * 0.5

			# Save the edge line thickness
			line_dimension = diag #shape.BoundingBox().DiagonalLength * ratio

			for face in shape.Faces():
				# Construct a unique permanent ID so that the vertices, edges
				# and triangles can be associated with this face
				perm_id = "face_" + str(uuid.uuid4())
				faces_tess[perm_id] = Dictionary()
				# Keep track of whether or not the current face is planar
				if type(BRep_Tool().Surface_s(face.wrapped)).__name__ == "Geom_Plane":
					faces_tess[perm_id]["is_planar"] = True
				else:
					faces_tess[perm_id]["is_planar"] = False

				# Construct the unique ID of the face based on its attributes
#				area = face.Area()
#				attrib_id = "face_area_" + str(area)
#				cur_face["attrib_id"] = attrib_id

				# Location information of the face to place the vertices and edges correctly
				loc = TopLoc_Location()

				# Perform the triangulation
				BRepMesh_IncrementalMesh(shape.wrapped, tolerance, True, angular_tolerance)
				face_mesh = BRep_Tool.Triangulation_s(face.wrapped, loc)

				# Save the transformation so that we can place vertices in the correct locations later
				Trsf = loc.Transformation()

				# Use the surface information to get the origin in global coordinates
				# Sometimes this fails with a generic kernel error, thus the try/except
				pln = None
				try:
					#adaptor = BRepAdaptor_Surface(face.wrapped)
					#plane = adaptor.Plane().Location()
					#pln = [plane.X(), plane.Y(), plane.Z()]
					pln = face.Center()
				except Exception as e:
					pln = [0.0, 0.0, 0.0]

				# Save data about the face for selector synthesis
				faces_tess[perm_id]["normal"] = Array()
				faces_tess[perm_id]["normal"].append(face.normalAt().x)
				faces_tess[perm_id]["normal"].append(face.normalAt().y)
				faces_tess[perm_id]["normal"].append(face.normalAt().z)
				faces_tess[perm_id]["origin"] = Array()
				faces_tess[perm_id]["origin"].append(pln.x)
				faces_tess[perm_id]["origin"].append(pln.y)
				faces_tess[perm_id]["origin"].append(pln.z)

				reverse = (
					True
					if face.wrapped.Orientation() == TopAbs_Orientation.TopAbs_REVERSED
					else False
				)

				vertices = face_mesh.Nodes()

				i = 1
				for v in vertices:
					v_new = v.Transformed(Trsf)
					vertices.SetValue(i, v_new)
					i += 1

				faces_tess[perm_id]["triangles"] = Array()

				# Step through all the triangles and add associate them with the face
				for triangle in face_mesh.Triangles():
					# Construct a permanent unique ID for this triangle
					tri_perm_id = "triangle_" + str(uuid.uuid4())

					# Get the vertices of the current triangle
					nodes = triangle.Get()

					cur_triangle = Dictionary()

					# Collect all the vertices into arrays
					first_vert = Array()
					first_vert.append(vertices.Value(nodes[0]).X())
					first_vert.append(vertices.Value(nodes[0]).Y())
					first_vert.append(vertices.Value(nodes[0]).Z())
					second_vert = Array()
					second_vert.append(vertices.Value(nodes[1]).X())
					second_vert.append(vertices.Value(nodes[1]).Y())
					second_vert.append(vertices.Value(nodes[1]).Z())
					third_vert = Array()
					third_vert.append(vertices.Value(nodes[2]).X())
					third_vert.append(vertices.Value(nodes[2]).Y())
					third_vert.append(vertices.Value(nodes[2]).Z())

					if reverse:
						cur_triangle["vertex_1"] = first_vert
						cur_triangle["vertex_2"] = third_vert
						cur_triangle["vertex_3"] = second_vert
					else:
						cur_triangle["vertex_1"] = first_vert
						cur_triangle["vertex_2"] = second_vert
						cur_triangle["vertex_3"] = third_vert

					# Save the current triangle and make sure it is associated with its parent face
					cur_triangle["parent"] = perm_id
					triangles_tess[tri_perm_id] = cur_triangle

					# Keep track of the child triangles for the current face
					faces_tess[perm_id]["triangles"].append(cur_triangle)

					offset += face_mesh.NbNodes()

			# Add CadQuery-reported edges
			for edge in cq_shape.edges().all():
				# Find the smallest edge dimension so that we can use that for the line width
				if shape.BoundingBox().xlen > 0.01 and shape.BoundingBox().xlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().xlen
				if shape.BoundingBox().ylen > 0.01 and shape.BoundingBox().ylen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().ylen
				if shape.BoundingBox().zlen > 0.01 and shape.BoundingBox().zlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().zlen

				# Construct a permanent unique ID for this triangle
				edge_perm_id = "edge_" + str(uuid.uuid4())
				edges_tess[edge_perm_id] = Dictionary()
				edges_tess[edge_perm_id]["segments"] = Array()

				# The edge type
				edge = edge.val()

				# We need to handle different kinds of edges differently
				gt = edge.geomType()

				# Save metadata about the edge that can be used for selector synthesis
				edges_tess[edge_perm_id]["type"] = gt

				if gt == "LINE":
					edges_tess[edge_perm_id]["start_vertex"] = Vector3(edge.startPoint().x, edge.startPoint().y, edge.startPoint().z)
					edges_tess[edge_perm_id]["end_vertex"] = Vector3(edge.endPoint().x, edge.endPoint().y, edge.endPoint().z)

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

					# Dictionary holding the information for the current edge segment
					cur_edge_segment = Dictionary()
					cur_edge_segment["parent"] = edge_perm_id

					# Add the start and end vertices for this edge
					cur_edge_segment["vertex_1"] = Vector3(x1, y1, z1)
					cur_edge_segment["vertex_2"] = Vector3(x2, y2, z2)

					# Save the current edge segment
					edges_tess[edge_perm_id]["segments"].append(cur_edge_segment)
					edge_segment_tess.append(cur_edge_segment)
				# If dealing with some sort of arc, discretize it into individual lines
				elif gt == "CIRCLE" or gt == "ARC" or gt == "SPLINE" or gt == "BSPLINE" or gt == "ELLIPSE":
					from OCP import GCPnts, BRepAdaptor

					# Save the start and end vertices for the circle (which should be the same)
					edges_tess[edge_perm_id]["start_vertex"] = Vector3(edge.startPoint().x, edge.startPoint().y, edge.startPoint().z)
					edges_tess[edge_perm_id]["end_vertex"] = Vector3(edge.endPoint().x, edge.endPoint().y, edge.endPoint().z)

					# Find the effective origin and normal of the circular edge
					edges_tess[edge_perm_id]["normal"] = Array()
					edges_tess[edge_perm_id]["normal"].append(cq_shape.plane.zDir.x)
					edges_tess[edge_perm_id]["normal"].append(cq_shape.plane.zDir.y)
					edges_tess[edge_perm_id]["normal"].append(cq_shape.plane.zDir.z)

					# Arc center does not apply for SPLINE and BSPLINE
					if gt == "SPLINE" and gt == "BSPLINE":
						edges_tess[edge_perm_id]["origin"] = Array()
						edges_tess[edge_perm_id]["origin"].append(edge.arcCenter().x)
						edges_tess[edge_perm_id]["origin"].append(edge.arcCenter().y)
						edges_tess[edge_perm_id]["origin"].append(edge.arcCenter().z)

					# Discretize the curve
					disc = GCPnts.GCPnts_TangentialDeflection(BRepAdaptor.BRepAdaptor_Curve(edge.wrapped), 0.5, 0.01)

					# Add each of the discretized sections to the edge list
					if disc.NbPoints() > 1:
						for i in range(2, disc.NbPoints() + 1):
							cur_edge_segment = Dictionary()
							cur_edge_segment["parent"] = edge_perm_id

							p_0 = disc.Value(i - 1)
							p_1 = disc.Value(i)

							# Add the start and end vertices for this edge
							cur_edge_segment["vertex_1"] = Vector3(p_0.X(), p_0.Y(), p_0.Z())
							cur_edge_segment["vertex_2"] = Vector3(p_1.X(), p_1.Y(), p_1.Z())

							# Save the current edge segment
							edges_tess[edge_perm_id]["segments"].append(cur_edge_segment)
							edge_segment_tess.append(cur_edge_segment)

			# Add CadQuery-reported vertices
			for vertex in cq_shape.vertices().all():
				vertex = vertex.val()

				vertex_perm_id = "vertex_" + str(uuid.uuid4())

				# Collect the vertex values into a dictionary we can save
				cur_vertex = Dictionary()
				cur_vertex["perm_id"] = vertex_perm_id
				cur_vertex["X"] = vertex.X
				cur_vertex["Y"] = vertex.Y
				cur_vertex["Z"] = vertex.Z

				vertices_tess.append(cur_vertex)

		# Find all the workplanes
		cur_wp = Dictionary()
		cur_wp["id"] = "test"
		cur_wp["normal"] = Array()
		cur_wp["normal"].append(cq_shape.plane.zDir.x)
		cur_wp["normal"].append(cq_shape.plane.zDir.y)
		cur_wp["normal"].append(cq_shape.plane.zDir.z)
		cur_wp["origin"] = Array()
		cur_wp["origin"].append(cq_shape.plane.origin.x)
		cur_wp["origin"].append(cq_shape.plane.origin.y)
		cur_wp["origin"].append(cq_shape.plane.origin.z)
		if cur_wp.size() == 0:
			cur_wp["is_base"] = True
		else:
			cur_wp["is_base"] = False
		workplanes.append(cur_wp)

		shape_tess["faces"] = faces_tess
		shape_tess["triangles"] = triangles_tess
		shape_tess["edges"] = edges_tess
		shape_tess["edge_segments"] = edge_segment_tess
		shape_tess["vertices"] = vertices_tess
		shape_tess["workplanes"] = workplanes
		shape_tess["smallest_dimension"] = smallest_dimension
		shape_tess["line_dimension"] = line_dimension

		return shape_tess


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
