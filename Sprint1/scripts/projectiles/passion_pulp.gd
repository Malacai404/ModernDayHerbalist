extends Area3D
var damage := 20
var speed := 13.0
var lifetime := 4.5
var spawn_puddle := false
var puddle_scene: PackedScene = null
var is_enemy_shot := false

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		var target_group := "player" if is_enemy_shot else "enemy"
		if b.is_in_group(target_group) and b.has_method("damage"):
			b.damage(damage)
			if spawn_puddle and puddle_scene:
				var p = puddle_scene.instantiate()
				p.global_position = b.global_position
				p.global_position.y = global_position.y - 0.9
				if "is_enemy_shot" in p: p.is_enemy_shot = is_enemy_shot
				get_tree().root.add_child(p)
			queue_free()
			break
		elif b.name == "floorBody" and spawn_puddle and puddle_scene:
			var p = puddle_scene.instantiate()
			p.global_position = global_position
			if "is_enemy_shot" in p: p.is_enemy_shot = is_enemy_shot
			get_tree().root.add_child(p)
			queue_free()
			break
