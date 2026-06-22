extends CharacterBody3D
class_name enemy

var health = 30

@export var speed: float = 4.0
@export var acceleration: float = 10.0
@export var player_path: NodePath 


@onready var healthbar: Node3D = $healthbar

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

const BLOODPARTICLE = preload("uid://i3mrnq0n7eyn")

var player: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Locate the player node safely
	if has_node(player_path):
		player = get_node(player_path) as Node3D
	
	# Wait for the navigation map to sync up before requesting paths
	set_physics_process(false)
	await NavigationServer3D.map_changed
	set_physics_process(true)

func damage(hurt):
	health -= hurt

func _physics_process(delta: float) -> void:
	healthbar.update_health(health, 30)
	if health <= 0:
		var particle = BLOODPARTICLE.instantiate()
		particle.position = position
		particle.position.y += 1
		get_tree().root.add_child(particle)
		queue_free()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	if is_instance_valid(player):
		nav_agent.target_position = player.global_position
	
	
	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
		return

	
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var current_pos: Vector3 = global_position
	
	
	var direction: Vector3 = (next_path_pos - current_pos).normalized()
	direction.y = 0
	
	
	var target_velocity: Vector3 = direction * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# Face the direction the enemy is running (optional look_at logic)
	var target_look: Vector3 = global_position + direction * 1000
	look_at(Vector3(-target_look.x, global_position.y, -target_look.z), Vector3.UP)

	# Execute the movement step
	move_and_slide()
