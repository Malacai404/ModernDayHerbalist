extends Area3D

var lifetime = 4

var largescatter = false

@export var damage = 15
@export var speed: float = 15
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_randomize_direction()

func _randomize_direction():
	if(largescatter):
		rotation_degrees.y += randf_range(-15,15)
		rotation_degrees.x += randf_range(-3,6)
	else:
		rotation_degrees.y += randf_range(-3,3)
		rotation_degrees.x += randf_range(-3,6)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var direction = -global_transform.basis.z.normalized()
	position += direction * speed * delta
	for i in get_overlapping_bodies():
		print(i)
		if i.is_in_group("enemy"):
			if i.has_method("damage"):
				i.damage(damage)
			queue_free()
