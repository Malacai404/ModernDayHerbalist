extends Area3D
# Lingering DoT puddle left by passionfruit
var damage := 6
var lifetime := 5.0
var tick := 0.5
var _timer := 0.0
var _cd := {}

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	for k in _cd.keys():
		_cd[k] -= delta
		if _cd[k] <= 0: _cd.erase(k)
	_timer -= delta
	if _timer <= 0:
		_timer = tick
		for b in get_overlapping_bodies():
			if not b.is_in_group("enemy") or not b.has_method("damage"): continue
			if _cd.has(b): continue
			b.damage(damage)
			_cd[b] = tick * 0.9
