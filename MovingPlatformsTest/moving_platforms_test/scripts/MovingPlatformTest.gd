extends KinematicBody

export (float) var time = 5.0
export (float) var delayTime = 1.5

var places = []

# our timers
var timer : Timer
var timeUp : bool
var delay : Timer
var delayUp : bool

# our actual speed based on a basic physics formula
var actualVelocity := Vector3()
var stop = false
var isMoving = true
var velocity

#just for debugging
func getVelocity():
	return actualVelocity

func _ready():
	timer = createTimer(time, "timeUp")
	delay = createTimer(delayTime, "delayUp")
	timeUp = true
	delayUp = true
	add_child(timer)
	add_child(delay)
	velocity = ($Place.global_transform.origin - global_transform.origin) / time
	
	for node in $Place.get_children():
		node.queue_free()
	
	places.append(global_transform.origin)
	places.append($Place.global_transform.origin)

func timeUp():
	timeUp = true
	
func delayUp():
	delayUp = true

func createTimer(wait_time : float, funcTarget : String):
	var timer = Timer.new()
	#making a new timer through code instead of in node tree
	timer.set_one_shot(true)
	timer.set_wait_time(wait_time)
	timer.connect("timeout", self, funcTarget)
	return timer
	
# This moving platform only works for two stops, so you will have to try another
# method if you want to have multiple stops (which would be cool)
func _physics_process(delta):
	var pos1 = global_transform.origin
	# We are departing from one of our positions
	if timeUp && delayUp && stop == false:
		timer.start()
		timeUp = false
		stop = true
		isMoving = true
		velocity *= -1
	# We have come back to a position and are delaying
	elif timeUp && delayUp && stop == true:
		delay.start()
		delayUp = false
		stop = false
		isMoving = false
		
		var place1 = (global_transform.origin - places[0]).length()
		var place2 = (global_transform.origin - places[1]).length()
		if(place1 < place2):
			global_transform.origin = places[0]
		else:
			global_transform.origin = places[1]

	if(isMoving):
		global_transform.origin -= velocity * delta
		
	var pos2 = global_transform.origin
	actualVelocity = (pos2 - pos1) / delta
