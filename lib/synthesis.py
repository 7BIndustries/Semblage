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
