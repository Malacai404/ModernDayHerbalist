extends Area3D
var damage := 20
var speed := 13.0
var lifetime := 4.5
var spawn_puddle := false
var puddle_scene: PackedScene = null

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		if b.is_in_group("enemy") and b.has_method("damage"):
			b.damage(damage)
			if spawn_puddle and puddle_scene:
				var p = puddle_scene.instantiate()
				p.global_position = b.global_position
				p.global_position.y = global_position.y - 0.9
				get_tree().root.add_child(p)
			queue_free()
			break
		elif b.name == "floorBody" and spawn_puddle and puddle_scene:
			var p = puddle_scene.instantiate()
			p.global_position = global_position
			get_tree().root.add_child(p)
			queue_free()
			break
