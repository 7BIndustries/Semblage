extends Camera

class_name OrbitCamera

export var ROTATIONSPEED = 0.5 * PI/180 #rad/screenpixel
export var DEFAULTPANDIST = 10
export var ZOOMSPEED = 0.15
export var ROTATIONENABLED = true
export var ZOOMENABLED = true
export var PANENABLED = true

var RAYLENGTH = 100000
var focalpoint = Vector3(0,0,0)
var actpandist = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#Add needed Child Objects (Not Visible in the Scene-Tree)
	var newRayCast = RayCast.new()
	newRayCast.name = "RayCast"
	add_child(newRayCast)
	newRayCast.set_owner(self)


"""
Meant to be used with the mouse scroll wheel, zooms in or out one step for each
step of the wheel.
"""
func ZoomingInOut(dir):
	var Zoomdist = dir * ZOOMSPEED

	translate_object_local(Vector3(0,0,Zoomdist))


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
					Transform.IDENTITY.rotated(Vector3(1,0,0), (last_pos2d[1]-act_pos2d[1])*ROTATIONSPEED) * \
					Transform.IDENTITY.rotated(Vector3(0,1,0), (last_pos2d[0]-act_pos2d[0])*ROTATIONSPEED) * \
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
		if last_pos2d == Vector2(0,0):
			#Orient RayCast 
			var RayCastPose = global_transform.inverse()
			RayCastPose.origin = Vector3(0,0,0)
			$RayCast.transform = RayCastPose
			$RayCast.force_update_transform()
	
			#Get 3d-Focalpoint for t-1
			var raynormal = project_ray_normal(act_pos2d) 
			$RayCast.cast_to = raynormal * RAYLENGTH
			$RayCast.force_raycast_update()
			if $RayCast.is_colliding():
				focalpoint = $RayCast.get_collision_point()
			else:
				focalpoint = global_transform.origin + raynormal.normalized() * DEFAULTPANDIST
	
			#Distnace/Vectorlength from Camorigin to Focalpoint
			actpandist = (focalpoint - global_transform.origin).length()
		else:
			#Calc new Cam origin
			var focalpose = global_transform
			focalpose.origin = focalpoint
			var raynormal = project_ray_normal(act_pos2d) #Ray in Global Csys
			var raynormal_refCam = global_transform.basis.inverse() * raynormal
			global_transform.origin = focalpose * -Transform.IDENTITY.translated(raynormal_refCam.normalized() * actpandist).origin
