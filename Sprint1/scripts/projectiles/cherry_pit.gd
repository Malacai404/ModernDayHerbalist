extends Area3D
# Cherry Pit — rapid low-damage peashooter projectile
# PLACEHOLDER sprite/mesh: reuse SphereMesh until art is ready

var lifetime := 3.0
var damage := 8
var speed := 18.0
var is_enemy_shot := false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var dir := -global_transform.basis.z.normalized()
	position += dir * speed * delta
	for b in get_overlapping_bodies():
		if is_enemy_shot:
			if b.is_in_group("player") and b.has_method("damage"):
				b.damage(damage)
				queue_free()
				break
		else:
			if b.is_in_group("enemy") and b.has_method("damage"):
				b.damage(damage)
				queue_free()
				break
