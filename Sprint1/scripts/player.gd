extends CharacterBody3D

const jump_force = 4.5
const room_speed = 3.5
const world_speed = 7.5

var mouse_sensitivity = 0.005
var current_speed = 5.0

var vertical_limit_deg = 45


@onready var player_mesh = $playerMesh
@onready var player_collision = $playerCollision
@onready var player_head = $playerHead

func _kill():
	print("You died!")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Rotate the camera and head based on mouse movement
	if event is InputEventMouseMotion:
		# Horizontal rotation (turn the player)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Vertical rotation (tilt the camera)
		player_head.rotate_x(-event.relative.y * mouse_sensitivity)
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(-vertical_limit_deg), deg_to_rad(vertical_limit_deg))



func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	move_and_slide()
