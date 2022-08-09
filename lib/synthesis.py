from godot import exposed, Node
from selector_synthesis import vector_based_synth

@exposed
class synthesis(Node):
	def synthesize(self, selector_type, selected_origins, selected_normals, selected_meta, face_origins, face_normals, face_meta):
		# Convert all of the Godot types to Python types
		sel_origs = []
		sel_norms = []
		sel_meta = []
		face_origs = []
		face_norms = []
		f_meta = []

		for so in selected_origins:
			sel_origs.append((so.x, so.y, so.z))
		for sn in selected_normals:
			sel_norms.append((sn.x, sn.y, sn.z))
		for fo in face_origins:
			face_origs.append((fo.x, fo.y, fo.z))
		for fn in face_normals:
			face_norms.append((fn.x, fn.y, fn.z))
		for sm in selected_meta:
			for sm_inner in sm.keys():
				sel_meta_temp = {}
				sel_meta_temp[str(sm_inner)] = bool(sm[sm_inner])
				sel_meta.append(sel_meta_temp)
		for fm in face_meta:
			for fm_inner in fm.keys():
				face_meta_temp = {}
				face_meta_temp[str(fm_inner)] = bool(fm[fm_inner])
				f_meta.append(face_meta_temp)

		# Synthesize the selector
		res = vector_based_synth.synthesize(str(selector_type), selected_origin=sel_origs, selected_normal=sel_norms, selected_meta=sel_meta, face_origins=face_origs, face_normals=face_norms, face_meta=f_meta)

		return res

	def synthesize_edge_sel(self, selector_type, selected_edges, selected_edge_types, selected_edge_starts, selected_edge_ends, selected_normals, other_edge_starts, other_edge_ends, other_normals, other_edge_meta):
		"""
		Takes a list of edges and tries to synthesize a selector that will work for all of them.
		"""
		# Convert the lists of Vector3 objects to lists of tuples
		sel_edge_starts = []
		sel_edge_ends = []
		sel_normals = []
		other_starts = []
		other_ends = []
		other_meta = []
		other_norms = []
		for ses in selected_edge_starts:
			sel_edge_starts.append((ses.x, ses.y, ses.z))
		for see in selected_edge_ends:
			sel_edge_ends.append((see.x, see.y, see.z))
		for sen in selected_normals:
			if sen != None:
				sel_normals.append((sen.x, sen.y, sen.z))
		for os in other_edge_starts:
			other_starts.append((os.x, os.y, os.z))
		for oe in other_edge_ends:
			other_ends.append((oe.x, oe.y, oe.z))
		for on in other_normals:
			other_norms.append((on.x, on.y, on.z))

		# Convert the lists of GDString objects to lists of strs
		sel_edges = []
		sel_edge_types = []
		for se in selected_edges:
			sel_edges.append(str(se))
		for set in selected_edge_types:
			sel_edge_types.append(str(set))

		# Handle dicts of metadata
		for om in other_edge_meta:
			for om_inner in om.keys():
				other_meta_temp = {}
				other_meta_temp[str(om_inner)] = bool(om[om_inner])
				other_meta.append(other_meta_temp)

		# Workaround for mismatch in size between start and normal arrays
		if len(other_edge_starts) != len(other_norms):
			for i in range(len(other_norms), len(other_edge_starts)):
				other_norms.append((0, 0, 0))

		# Synthesize the selector
		res = vector_based_synth.synthesize(str(selector_type), selected_edges=sel_edges, selected_edge_types=sel_edge_types, selected_edge_starts=sel_edge_starts, selected_edge_ends=sel_edge_ends, selected_edge_normals=sel_normals, other_edge_starts=other_starts, other_edge_ends=other_ends, other_edge_meta=other_meta, other_normals=other_norms)

		return res
