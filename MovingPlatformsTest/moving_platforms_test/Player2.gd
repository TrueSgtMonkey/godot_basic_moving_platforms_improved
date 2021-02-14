extends KinematicBody

onready var camera = $Spatial/Camera
var mouseSensitivity = 0.007
var jumpSpeed := 10
var isJumping := false
var velocity := Vector3()
var colliderVelocity := Vector3()
var speed := 6
var spatialHeight
var isOnMovingPlatform := false
var playerHeight
var isDucking := false
const gravity = 30

func _ready():
	spatialHeight = $Spatial.transform.origin.y
	playerHeight = $MeshInstance.mesh.get_aabb().size.y
	$MeshInstance.queue_free()

func _physics_process(delta):
	var input := Vector3()
	isJumping = false
	# Resets after ducking
	if $Spatial.transform.origin.y != spatialHeight:
		var result = rayShot(Vector3(0,100,0))
		if result.empty() || !result.empty() && (result.position - global_transform.origin).y > playerHeight:
			isDucking = false
			$Spatial.transform.origin.y = spatialHeight
			$CollisionShape.disabled = false
			$DuckingShape.disabled = true
	
	if Input.is_key_pressed(KEY_W):
		input += -$Spatial.global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input += $Spatial.global_transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input += -$Spatial.global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input += $Spatial.global_transform.basis.x
		
	if Input.is_key_pressed(KEY_CONTROL):
		isDucking = true
		$Spatial.transform.origin.y = spatialHeight / 2.0
		$CollisionShape.disabled = true
		$DuckingShape.disabled = false
		
	var colVel = colliderVelocity
		
	var desVelocity
	
	if(isDucking):
		desVelocity = input.normalized() * speed / 3.0
	else:
		desVelocity = input.normalized() * speed
		
	velocity.x = desVelocity.x
	velocity.z = desVelocity.z
	var slides = get_slide_count()
	if(!is_on_floor()):
		velocity.y -= gravity * delta
	else:
		colVel *= delta
		if colliderVelocity == Vector3() || (colliderVelocity.x != 0 || colliderVelocity.z != 0):
			velocity.y = 0
	if(Input.is_key_pressed(KEY_SPACE) && is_on_floor()):
		velocity.y = jumpSpeed
	slope(slides)
	move_and_slide(velocity + colVel, Vector3.UP, true)
	
func slope(slides : int):
	if slides:
		colliderVelocity = Vector3()
		for i in slides:
			var touched = get_slide_collision(i)
			# We need a little push to balance out movement on slopes
			if is_on_floor() && touched.normal.y < 1.0 && (velocity.x != 0.0 || velocity.z != 0.0):
				velocity.y = touched.normal.y
			if(touched.collider_velocity != Vector3() && is_on_floor()):
				colliderVelocity = touched.collider_velocity
				isOnMovingPlatform = true
			elif(touched.collider_velocity == Vector3() && is_on_floor()):
				isOnMovingPlatform = false
	else:
		# If we don't get any slides for some reason, this is the backup
		if(isOnMovingPlatform):
			getPlatformBelow()
				
func getPlatformBelow():
	var result = rayShot(Vector3(0, -10000, 0))
	if(result && result.collider is KinematicBody):
		# we will have to put the getVelocity() functions in our moving platforms
		if(result.collider.has_method("getVelocity")):
			colliderVelocity = result.collider.getVelocity()
		else:
			print("There was no getVelocity() function!")
	
func camVertMove(val, sensitivity, cVal := 1.2):
	camera.rotate_x(-val * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -cVal, cVal)
	
func makeRotate(deg : float):
	$Spatial.rotate_y(deg)

func _unhandled_input(event):
	if(event is InputEventMouseMotion):
		makeRotate(-event.relative.x * mouseSensitivity)
		camVertMove(event.relative.y, mouseSensitivity)
	
# Shortcut function so that I don't have to remember how to write this
func rayShot(vec : Vector3):
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(global_transform.origin, vec, [self])
