extends CharacterBody3D


@export var max_velocity := 4
@export var acceleration := 0.8
@export var friction := 0.6
@export var max_sprint := 8
@export var jump_velocity := 3
@export var look_sens := 0.4
@export var max_roll_angle := 2
@export var roll_speed := 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _camera_rotation(event: InputEvent):
	rotate_y(deg_to_rad(-event.relative.x * look_sens))
	$Neck.rotate_x((deg_to_rad(-event.relative.y * look_sens)))
	$Neck.rotation_degrees.x = clamp(($Neck.rotation_degrees.x), -90, 90)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = move_toward(velocity.x, direction.x * max_sprint, acceleration)
			velocity.z = move_toward(velocity.z, direction.z * max_sprint, acceleration)
		else:
			velocity.x = move_toward(velocity.x, direction.x * max_velocity, acceleration)
			velocity.z = move_toward(velocity.z, direction.z * max_velocity, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)
	var target_roll := -input_dir.x * max_roll_angle
	rotation_degrees.z = lerp(rotation_degrees.z, target_roll, roll_speed * delta)
	move_and_slide()

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("mouse_left"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_rotation(event)
