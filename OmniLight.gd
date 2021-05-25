extends OmniLight

export var ROTATIONSPEED = 0.5 * PI / 180 #rad/screenpixel
export var PANSPEED = 0.05
export var ROTATIONENABLED = true
export var PANENABLED = true

var focalpoint = Vector3(0, 0, 0)


"""
Called when the user requests the 3D view to be panned.
"""
func _on_DocumentTabs_cam_pan(last_pos2d, act_pos2d):
	if PANENABLED:
		# Calculate new camera transformation
		var focalpose = global_transform
		focalpose.origin = focalpoint
#		var VFocalP2Cam = (focalpose.inverse() * global_transform).origin
		
		translate_object_local(Vector3((last_pos2d[0] - act_pos2d[0]) * PANSPEED, -(last_pos2d[1] - act_pos2d[1]) * PANSPEED, 0))


"""
Called when the light is told that it needs to rotate.
"""
func _on_DocumentTabs_cam_rotate(last_pos2d, act_pos2d):
	if ROTATIONENABLED:
		# Calculate new camera transformation
		var focalpose = global_transform
		focalpose.origin = focalpoint
		var VFocalP2Cam = (focalpose.inverse() * global_transform).origin
	
		global_transform = focalpose * \
					Transform.IDENTITY.rotated(Vector3(1, 0, 0), (last_pos2d[1] - act_pos2d[1]) * ROTATIONSPEED) * \
					Transform.IDENTITY.rotated(Vector3(0, 1, 0), (last_pos2d[0] - act_pos2d[0]) * ROTATIONSPEED) * \
					Transform.IDENTITY.translated(VFocalP2Cam)
