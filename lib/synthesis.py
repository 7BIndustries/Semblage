from godot import exposed, Node
from selector_synthesis import vector_based_synth

@exposed
class synthesis(Node):
	def synthesize(self, selected_origins, selected_normals, face_origins, face_normals, selected_meta, face_meta):
		# Convert all of the Godot types to Python types
		sel_origs = []
		sel_norms = []
		face_origs = []
		face_norms = []
		for so in selected_origins:
			sel_origs.append((so.x, so.y, so.z))
		for sn in selected_normals:
			sel_norms.append((sn.x, sn.y, sn.z))
		for fo in face_origins:
			face_origs.append((fo.x, fo.y, fo.z))
		for fn in face_normals:
			face_norms.append((fn.x, fn.y, fn.z))

		# Synthesize the selector
		res = vector_based_synth.synthesize(sel_origs, sel_norms, face_origs, face_norms, selected_meta, face_meta)

		return res

	def synthesize_edge_sel(self, selected_edges, selected_edge_types, selected_edge_starts, selected_edge_ends, selected_normals):
		"""
		Takes a list of edges and tries to synthesize a selector that will work for all of them.
		"""
		# Convert the lists of Vector3 objects to lists of tuples
		sel_edge_starts = []
		sel_edge_ends = []
		sel_normals = []
		for ses in selected_edge_starts:
			sel_edge_starts.append((ses.x, ses.y, ses.z))
		for see in selected_edge_ends:
			sel_edge_ends.append((see.x, see.y, see.z))
		for sen in selected_normals:
			sel_normals.append((sen.x, sen.y, sen.z))

		# Convert the lists of GDString objects to lists of strs
		sel_edges = []
		sel_edge_types = []
		for se in selected_edges:
			sel_edges.append(str(se))
		for set in selected_edge_types:
			sel_edge_types.append(str(set))

		# Synthesize the selector
		res = vector_based_synth.synthesize_edge_selector(sel_edges, sel_edge_types, sel_edge_starts, sel_edge_ends, sel_normals)

		return res
