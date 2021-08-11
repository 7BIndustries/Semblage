import os
import sys
from godot import exposed, export, signal, Node, ResourceLoader, MeshInstance, CubeMesh, SpatialMaterial

semb_json_template = (
"""
{
"metadata": {
"format": "cadquery-custom",
"formatVersion": 1.0,
"generatedBy": "semblage-server"
},
"components": %(components)s
}
""")

component_template = (
"""
{
"id": -1,
"vertexCount": %(nVertices)d,
"triangleCount": %(nTriangles)d,
"normalCount": 0,
"colorCount": 0,
"uvCount": 0,
"materials": 1,
"largestDim": %(largestDim)d,
"smallestDim": %(smallestDim)d,
"vertices": %(vertices)s,
"triangles": %(triangles)s,
"normals": [],
"uvs": [],
"color": %(color)s,
"cqVertices": %(cqVertices)s,
"cqEdges": %(cqEdges)s,
"cqFaces": %(cqFaces)s
}
""")

cq_vertex_template = (
"""
{
	"id": -1,
	"x": -1,
	"y": -1,
	"z": -1
}
"""
)

cq_edge_template = (
"""
{
	"id": -1,
	"type": "line",
	"start": "None",
	"end": "None",
	"center": "None",
	"radius": "None" 
}
""")

cq_face_template = (
"""
{
	"id": -1,
	"vertices": [],
	"edges": []
}
""")


class JsonMesh(object):
	def __init__(self):
		self.components = []
		self.vertices = []
		self.triangles = []
		self.nVertices = 0
		self.nTriangles = 0
		self.cqVertices = []
		self.cqEdges = []
		self.cqFaces = []
		self.largestDim = -1
		self.smallestDim = 99999999
		self.color = [] # rgba
	

	def addVertex(self, x, y, z):
		self.nVertices += 1
		self.vertices.extend([x, y, z])

	"""
	Add triangle composed of the three provided vertex indices
	"""
	def addTriangle(self, i, j, k):
		self.nTriangles += 1
		self.triangles.extend([int(i), int(j), int(k)])

	"""
	Adds the largest dimension for the current component
	"""
	def addLargestDim(self, dimension):
		self.largestDim = dimension

	"""
	Adds the smallest dimension for the current component
	"""
	def addSmallestDim(self, dimension):
		self.smallestDim = dimension

	"""
	Adds the red, green blue alpha colors to the JSON mesh.
	"""
	def addColor(self, r, g, b, a):
		self.color = [r, g, b, a]

	"""
	Adds a CadQuery vertex representation.
	"""
	def addCQVertex(self, x, y, z):
		self.cqVertices.append([x, y, z])

	"""
	Adds a CadQuery edge representation.
	"""
	def addCQEdge(self, x1, y1, z1, x2, y2, z2):
		self.cqEdges.append([x1, y1, z1, x2, y2, z2])

	"""
	Separates the current set of vertices, triangles, etc into a separate component.
	"""
	def addComponent(self):
		template = component_template % {
			"vertices": str(self.vertices),
			"triangles": str(self.triangles),
			"nVertices": self.nVertices,
			"nTriangles": self.nTriangles,
			"cqVertices": str(self.cqVertices),
			"cqEdges": str(self.cqEdges),
			"cqFaces": str(self.cqFaces),
			"largestDim": self.largestDim,
			"smallestDim": self.smallestDim,
			"color": self.color
		}

		self.components.append(template)

		# Reset for the next component
		self.vertices = []
		self.triangles = []
		self.nVertices = 0
		self.nTriangles = 0
		self.cqVertices = []
		self.cqEdges = []
		self.cqFaces = []
		self.largestDim = -1
		self.smallestDim = 99999999


	"""
	Get a json model from this model.
	For now we'll forget about colors, vertex normals, and all that stuff
	"""
	def toJson(self):
		return_json = semb_json_template % {
			"components": str(self.components),
		}
		return_json = return_json.replace("'", "")
		return_json = return_json.replace("\\n", "")

		return return_json


def convert_components(components):
	"""
	Converts a list of components into Semblage JSON.
	"""
	from cadquery import Color

	mesher = JsonMesh()

	for component in components:
		# Extract the aspects of the component
		shape = component[0]
		largest_dimension = component[1]
		color = component[2]
		loc = component[3]
		smallest_dimension = component[4]

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
				mesher.addVertex(v.x + loc_x, v.y + loc_y, v.z + loc_z)
		
			# Add triangles
			for ixs in tess[1]:
				mesher.addTriangle(*ixs)
		
			# Add CadQuery-reported vertices
			for vert in shape.Vertices():
				mesher.addCQVertex(vert.X, vert.Y, vert.Z)

			# Add CadQuery-reported edges
			for edge in shape.Edges():
				gt = edge.geomType()

				# Find out if the shape is larger than the largest bounding box we have recorded so far
				if shape.BoundingBox().DiagonalLength > largest_dimension:
					largest_dimension = shape.BoundingBox().DiagonalLength

				# Find the smallest dimension so that we can use that for the line width
				if shape.BoundingBox().xlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().xlen
				if shape.BoundingBox().ylen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().ylen
				if shape.BoundingBox().zlen < smallest_dimension:
					smallest_dimension = shape.BoundingBox().zlen

				# If dealing with some sort of arc, discretize it into individual lines
				if gt == "CIRCLE" or gt == "ARC" or gt == "SPLINE" or gt == "ELLIPSE":
					from OCP import GCPnts, BRepAdaptor

					# Discretize the curve
					disc = GCPnts.GCPnts_TangentialDeflection(BRepAdaptor.BRepAdaptor_Curve(edge.wrapped), 0.5, 0.01)

					# Add each of the discretized sections to the edge list
					if disc.NbPoints() > 1:
						for i in range(2, disc.NbPoints() + 1):
							p_0 = disc.Value(i - 1)
							p_1 = disc.Value(i)

							# Add the start and end vertices for this edge
							mesher.addCQEdge(p_0.X(), p_0.Y(), p_0.Z(), p_1.X(), p_1.Y(), p_1.Z())
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

					mesher.addCQEdge(x1, y1, z1, x2, y2, z2)

			# Make sure that the largest dimension is represented accurately for camera positioning
			mesher.addLargestDim(largest_dimension)
			mesher.addSmallestDim(smallest_dimension)
		
			# Make sure that the color is set correctly for the current component
			if color is None: color = Color(1.0, 0.36, 0.05, 1.0)
			mesher.addColor(color.wrapped.GetRGB().Red(), color.wrapped.GetRGB().Green(), color.wrapped.GetRGB().Blue(), color.wrapped.Alpha())
		
			# Snapshot the current vertices and triangles as a component
			mesher.addComponent()

	return mesher.toJson()


@exposed
class cqgi_interface(Node):
	build_success = signal()
	build_failure = signal()

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
	
		from cadquery import cqgi
		
		component_json = ""

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

		from cadquery import exporters

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

#		self.call("emit_signal", "build_success", result)

		return component_json


	# def build_direct(self, script_text):
	# 	print("HERE")
	# 	vp = self.get_tree().get_root().get_children()[1].get_node("GUI/VBoxContainer/WorkArea/DocumentTabs/VPMarginContainer/ThreeDViewContainer/ThreeDViewport")
	# 	print(vp.get_children())
