extends Area3D
var damage := 22
var speed := 13.0
var lifetime := 5.0
var bounces := 1
var heavy := false
var is_enemy_shot := false
var _hit := {}

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		var target_group := "player" if is_enemy_shot else "enemy"
		if b.is_in_group(target_group) and b.has_method("damage") and not _hit.has(b):
			b.damage(damage if not heavy else int(damage * 1.2))
			print("[PROJECTILE_HIT] peach_fuzz dmg=%d is_enemy_shot=%s proj=%s player=%s" % [damage, str(is_enemy_shot), str(global_position), str(b.name)])
			_hit[b] = true
		elif b.name == "floorBody" or b.is_in_group("wall"):
			if bounces > 0:
				bounces -= 1
				rotation.y += PI # reflect roughly
				# nudge off surface to avoid sticking
				position += -global_transform.basis.z.normalized() * 0.2
			else:
				queue_free()
			break
