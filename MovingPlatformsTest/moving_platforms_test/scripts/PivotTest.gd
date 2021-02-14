extends Spatial

export (float) var rotSpeed = 1.0
export (float) var zDist = 2.0
export (float) var runTime = 2.0
export (bool) var hasDelay = false
export (bool) var delay = false

var velocity := Vector3()
var child : KinematicBody

var myTimer : Timer

func _ready():
	for i in get_children():
		if i is KinematicBody:
			child = i
	child.transform.origin.z = zDist
	
	myTimer = Timer.new()
	myTimer.wait_time = runTime
	myTimer.autostart = hasDelay
	
	var shis = myTimer.connect("timeout", self, "startDelay")

func _physics_process(delta):
	var pos1 = child.global_transform.origin
	
	# if hasDelay is true, then this if condition solely depends on delay
	# if delay is true in that case, then the body will not rotate around the
	# pivot
	
	if(!delay || !hasDelay):
		rotate_y(rotSpeed * delta)
		
	var pos2 = child.global_transform.origin
	velocity = (pos2 - pos1) / delta
	
func startDelay():
	delay = !delay
	
func getVelocity():
	return velocity
