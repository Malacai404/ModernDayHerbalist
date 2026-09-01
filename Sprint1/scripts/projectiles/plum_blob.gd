extends Area3D
var damage := 12
var is_enemy_shot := false
var speed := 15.0
var lifetime := 3.5
var sticky := false
var _stuck_target = null
var _stuck_time := 0.0

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	if _stuck_target and is_instance_valid(_stuck_target):
		_stuck_time -= delta
		global_position = _stuck_target.global_position + Vector3(0, 0.8, 0)
		if _stuck_time <= 0:
			if _stuck_target.has_method("damage"): _stuck_target.damage(int(damage * 0.5))
			queue_free()
		return
	if _stuck_target == null:
		position += -global_transform.basis.z.normalized() * speed * delta
		for b in get_overlapping_bodies():
			if is_enemy_shot:
				if b.is_in_group("player") and b.has_method("damage"):
					b.damage(damage)
					if sticky:
						_stuck_target = b
						_stuck_time = 1.2
						lifetime = 2.0
					else:
						queue_free()
					break
			else:
				if b.is_in_group("enemy") and b.has_method("damage"):
					b.damage(damage)
					if sticky:
						_stuck_target = b
						_stuck_time = 1.2
						lifetime = 2.0
					else:
						queue_free()
					break
