extends Area3D
var damage := 45
var speed := 11.0
var lifetime := 6.0
var bounces := 2
var slam := false # if true: on floor hit do radial burst, then disappear
var is_enemy_shot := false
var _hit := {}

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		var target_group := "player" if is_enemy_shot else "enemy"
		if b.is_in_group(target_group) and b.has_method("damage") and not _hit.has(b):
			b.damage(damage)
			_hit[b] = true
			if not slam and bounces == 0:
				queue_free()
				break
		elif b.name == "floorBody" or b.is_in_group("wall"):
			if slam:
				_slam_burst()
				queue_free()
				break
			if bounces > 0:
				bounces -= 1
				rotation.y += PI
				position += -global_transform.basis.z.normalized() * 0.25
			else:
				queue_free()
			break

func _slam_burst():
	var burst_radius := 4.5
	var burst_damage := int(damage * 0.6)
	var target_group := "player" if is_enemy_shot else "enemy"
	for n in get_tree().get_nodes_in_group(target_group):
		if not is_instance_valid(n): continue
		if global_position.distance_to(n.global_position) <= burst_radius:
			if n.has_method("damage"): n.damage(burst_damage)
