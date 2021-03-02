extends KinematicBody

onready var collision_standing = $CollisionStanding
onready var collision_ducking = $CollisionDucking
onready var camera_rotation = $CameraRotation
onready var camera = $CameraRotation/Camera

var mouse_sensitivity := 0.007
var velocity := Vector3()
var speed := 6
var jump_speed := 10
var gravity := 30
var camera_height
var player_standing_height
var is_ducking := false
var snap := Vector3()


func _ready():
	camera_height = camera_rotation.transform.origin.y
	player_standing_height = collision_standing.shape.radius * 2 + collision_standing.shape.height


func _unhandled_input(event):
	if(event is InputEventMouseMotion):
		camera_rotation.rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	# Input
	var input := Vector3()
	
	if Input.is_key_pressed(KEY_W):
		input += -camera_rotation.global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input += camera_rotation.global_transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input += -camera_rotation.global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input += camera_rotation.global_transform.basis.x
	
	# Ducking
	if Input.is_key_pressed(KEY_CONTROL):
		is_ducking = true
		camera_rotation.transform.origin.y = camera_height / 2.0
		collision_standing.disabled = true
		collision_ducking.disabled = false
	else:
		if camera_rotation.transform.origin.y != camera_height:
			var result = ray_shot(Vector3(0,100,0))
			if result.empty() or !result.empty() and (result.position - global_transform.origin).y > player_standing_height:
				is_ducking = false
				camera_rotation.transform.origin.y = camera_height
				collision_standing.disabled = false
				collision_ducking.disabled = true
	
	
	# X Z Velocity
	var desired_velocity
	
	if(is_ducking):
		desired_velocity = input.normalized() * speed / 3.0
	else:
		desired_velocity = input.normalized() * speed
	
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	
	# Y velocity
	velocity.y -= gravity * delta
	if is_on_floor():
		snap = Vector3(0, -1, 0)
		if Input.is_key_pressed(KEY_SPACE):
			snap = Vector3()
			velocity.y = jump_speed
	
	# Apply Velocity
	velocity += get_floor_velocity() * delta
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true)


func ray_shot(vec : Vector3):
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(global_transform.origin, vec, [self])
