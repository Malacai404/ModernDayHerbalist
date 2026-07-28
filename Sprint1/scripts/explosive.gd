extends Area3D

@export var speed: float = 25.0
@export var app_gravity: float = 9.0


const EXPLOSION = preload("uid://if44dxx3w5u6")

var velocity: Vector3
var damage := 30
var fall: bool
func _ready():
	velocity = -global_transform.basis.z * speed

func _physics_process(delta):
	if fall == true:
		velocity.y -= app_gravity * delta

	global_position += velocity * delta

	for body in get_overlapping_bodies():
		if body.name == "floorBody" or body.is_in_group("enemy"):
			print("explode")
			explode()

func explode():
	var explodeobj = EXPLOSION.instantiate()
	explodeobj.position = global_position
	explodeobj.damage = damage
	get_tree().root.add_child(explodeobj)
	queue_free()
