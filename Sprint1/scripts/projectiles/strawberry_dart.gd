extends Area3D
var damage := 10
var speed := 20.0
var lifetime := 2.8

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		if b.is_in_group("enemy") and b.has_method("damage"):
			b.damage(damage)
			queue_free()
			break
