extends KinematicBody


var velocity


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getVelocity():
	velocity = get_parent().getVelocity()
	return velocity
