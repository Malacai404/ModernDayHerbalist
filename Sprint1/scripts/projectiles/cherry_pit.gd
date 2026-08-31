extends Area3D
# Cherry Pit — rapid low-damage peashooter projectile
# PLACEHOLDER sprite/mesh: reuse SphereMesh until art is ready

var lifetime := 3.0
var damage := 8
var speed := 18.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var dir := -global_transform.basis.z.normalized()
	position += dir * speed * delta
	for b in get_overlapping_bodies():
		if b.is_in_group("enemy") and b.has_method("damage"):
			b.damage(damage)
			queue_free()
			break
