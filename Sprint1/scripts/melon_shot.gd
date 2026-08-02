extends Area3D

var lifetime = 5.0
var damage = 10
var speed = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var direction = -global_transform.basis.z.normalized()
	position += direction * speed * delta
	for i in get_overlapping_bodies():
		if i.is_in_group("enemy"):
			if i.has_method("damage"):
				i.damage(damage)
			queue_free()
