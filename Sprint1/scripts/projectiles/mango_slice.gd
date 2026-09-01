extends Area3D
var damage := 28
var speed := 14.0
var lifetime := 4.0
var pierce := false
var arc := false
var is_enemy_shot := false
var _hit := {}
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	lifetime -= delta
	if lifetime <= 0: queue_free()
	var dir = -global_transform.basis.z.normalized()
	if arc:
		position += dir * speed * delta
		position.y += sin(_t * 6.0) * 0.02
	else:
		position += dir * speed * delta
	for b in get_overlapping_bodies():
		if is_enemy_shot:
			if not b.is_in_group("player") or not b.has_method("damage"): continue
		else:
			if not b.is_in_group("enemy") or not b.has_method("damage"): continue
		if _hit.has(b): continue
		b.damage(damage)
		_hit[b] = true
		if not pierce:
			queue_free()
			break
