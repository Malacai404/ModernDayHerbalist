extends Area3D
var damage := 16
var speed := 12.0
var lifetime := 5.0
var homing_strength := 2.0

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	# gentle homing toward nearest enemy
	var target = _nearest_enemy()
	if target:
		var desired = (target.global_position - global_position).normalized()
		var cur = -global_transform.basis.z.normalized()
		var blended = cur.lerp(desired, clamp(homing_strength * delta, 0.0, 1.0)).normalized()
		# yaw to face blended dir
		look_at(global_position + blended, Vector3.UP)
		position += -global_transform.basis.z.normalized() * speed * delta
	else:
		position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		if b.is_in_group("enemy") and b.has_method("damage"):
			b.damage(damage)
			queue_free()
			break

func _nearest_enemy():
	var best = null
	var best_d := 1e9
	for n in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(n): continue
		var d = global_position.distance_squared_to(n.global_position)
		if d < best_d:
			best_d = d; best = n
	return best
