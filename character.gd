extends CharacterBody3D

@export var max_velocity_ground := 4
@export var max_velocity_air := 1
@export var max_acceleration := 10 * max_velocity_ground
@export var jump_velocity := 2.5
@export var look_sens := 0.4
@export var max_roll_angle := 2
@export var roll_speed := 5
@export var sprint_velocity := 0.6
@export var stop_speed := 1
@export var friction := 6 
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
# Get the gravity from the project settings to be synced with RigidBody nodes.

var direction : Vector2
var wish_jump : bool
var sprint := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	input_dir()
	movement(delta)
	camera_tilt(delta)

func _camera_rotation(event: InputEvent):
	rotate_y(deg_to_rad(-event.relative.x * look_sens))
	$Neck.rotate_x((deg_to_rad(-event.relative.y * look_sens)))
	$Neck.rotation_degrees.x = clamp(($Neck.rotation_degrees.x), -90, 90)

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("mouse_left"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_rotation(event)

func camera_tilt(delta):
	var target_roll := -direction.x * max_roll_angle
	rotation_degrees.z = lerp(rotation_degrees.z, target_roll, roll_speed * delta)

func input_dir():
	direction = Input.get_vector("left", "right", "forward", "backward")
	
	wish_jump = Input.is_action_just_pressed("jump")
	sprint = Input.is_action_pressed("sprint")

func movement(delta):
	var wish_dir := (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()
	
	if is_on_floor():
		if wish_jump:
			velocity.y = jump_velocity
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		else:
			if sprint:
				velocity.x *= sprint_velocity
				velocity.z *= sprint_velocity
			
			velocity = update_velocity_ground(wish_dir, delta)
	else:
		velocity.y -= gravity * delta
		velocity = update_velocity_air(wish_dir, delta)
	move_and_slide()

func acceleration(wish_dir: Vector3, max_speed: float, delta):
	var current_speed := velocity.dot(wish_dir)
	var add_speed = clamp(max_speed - current_speed, 0, max_acceleration * delta)
	
	return velocity + add_speed * wish_dir

func update_velocity_ground(wish_dir: Vector3, delta):
	var speed := velocity.length()
	
	if speed != 0:
		var control : float = max(stop_speed, speed)
		var drop : float = control * friction * delta
		
		velocity *= max(speed-drop, 0) / speed
	
	return acceleration(wish_dir, max_velocity_ground, delta)

func update_velocity_air(wish_dir: Vector3, delta):
	return acceleration(wish_dir, max_velocity_air, delta)
