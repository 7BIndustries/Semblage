extends Camera

class_name OrbitCamera

export var ROTATIONSPEED = 0.5 * PI / 180 # rad/screenpixel
export var ZOOMSPEED = 0.15
export var PANSPEED = 0.05
export var ROTATIONENABLED = true
export var ZOOMENABLED = true
export var PANENABLED = true

var focalpoint = Vector3(0, 0, 0)


"""
Meant to be used with the mouse scroll wheel, zooms in or out one step for each
step of the wheel.
"""
func ZoomingInOut(dir):
	var Zoomdist = dir * ZOOMSPEED

	translate_object_local(Vector3(0, 0, Zoomdist))


"""
Called when the camera is told that it needs to rotate.
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


"""
Called when zooming with the mouse wheel.
"""
func _on_DocumentTabs_cam_zoom(zoom_dir):
	if ZOOMENABLED:
		ZoomingInOut(zoom_dir)


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
