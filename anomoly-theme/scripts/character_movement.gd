extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

@export var SENSE = 0.005
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var speed
const SPRINT_SPEED = 8.0
const WALK_SPEED = 5.0
@export var BOB_FREQ := 2.0
@export var BOB_AMP := 0.08
var BASE_FOV 
var FOV_CHANGE = 1.5
var t_bob := 0.0

func _ready() -> void:
	BASE_FOV = camera_3d.fov
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x =lerp(velocity.x ,direction.x*speed,delta *7.0)
			velocity.z =lerp(velocity.z ,direction.z*speed,delta *7.0)
			
	else:
		velocity.x =lerp(velocity.x ,direction.x*speed,delta *2.0)
		velocity.z =lerp(velocity.z ,direction.z*speed,delta *2.0)
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(),0.5, SPRINT_SPEED *2)
	var target_fov =BASE_FOV + FOV_CHANGE * velocity_clamped
	camera_3d.fov= lerp(camera_3d.fov,target_fov,delta*8.0)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSE)
		camera_3d.rotate_x(-event.relative.y * SENSE)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x,deg_to_rad(-40),deg_to_rad(60))

func _headbob(time):
	var pos = Vector3.ZERO
	
	pos.y = sin(time * BOB_FREQ)*BOB_AMP
	pos.x = cos(time* BOB_FREQ / 2)*BOB_AMP
	return pos
