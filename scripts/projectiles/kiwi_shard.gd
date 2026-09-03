extends Area3D
var damage := 14
var speed := 16.0
var lifetime := 3.5
var is_enemy_shot := false

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		if is_enemy_shot:
			if b.is_in_group("player") and b.has_method("damage"):
				b.damage(damage)
				print("[PROJECTILE_HIT] kiwi_shard dmg=%d is_enemy_shot=%s proj=%s player=%s" % [damage, str(is_enemy_shot), str(global_position), str(b.name)])
				queue_free()
				break
		else:
			if b.is_in_group("enemy") and b.has_method("damage"):
				b.damage(damage)
				print("[PROJECTILE_HIT] kiwi_shard dmg=%d is_enemy_shot=%s proj=%s player=%s" % [damage, str(is_enemy_shot), str(global_position), str(b.name)])
				queue_free()
				break
