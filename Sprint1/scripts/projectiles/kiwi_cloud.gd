extends Area3D
# Aura AoE: lingers, ticks damage on enemies inside
var damage := 8
var lifetime := 4.0
var tick := 0.4
var is_enemy_shot := false
var _timer := 0.0
var _hit_cd := {} # body -> cd

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	_timer -= delta
	for k in _hit_cd.keys():
		_hit_cd[k] -= delta
		if _hit_cd[k] <= 0: _hit_cd.erase(k)
	if _timer <= 0:
		_timer = tick
		for b in get_overlapping_bodies():
			if is_enemy_shot:
				if not b.is_in_group("player") or not b.has_method("damage"): continue
			else:
				if not b.is_in_group("enemy") or not b.has_method("damage"): continue
			if _hit_cd.has(b): continue
			b.damage(damage)
			print("[PROJECTILE_HIT] kiwi_cloud dmg=%d is_enemy_shot=%s proj=%s player=%s" % [damage, str(is_enemy_shot), str(global_position), str(b.name)])
			_hit_cd[b] = tick * 0.9
