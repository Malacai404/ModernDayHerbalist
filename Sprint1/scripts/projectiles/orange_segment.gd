extends Area3D
var damage := 18
var speed := 14.0
var lifetime := 4.0
var split := false
var _has_split := false

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0: queue_free()
	position += -global_transform.basis.z.normalized() * speed * delta
	for b in get_overlapping_bodies():
		if b.is_in_group("enemy") and b.has_method("damage"):
			b.damage(damage)
			if split and not _has_split:
				_has_split = true
				_do_split()
			queue_free()
			break

func _do_split():
	var scene = load("res://objects/projectiles/orange_segment.tscn")
	for s in [-1, 1]:
		var c = scene.instantiate()
		c.global_position = global_position
		c.rotation.y = rotation.y + s * 0.18
		c.rotation.x = rotation.x
		c.damage = int(damage * 0.55)
		c.split = false
		c.speed = speed * 0.9
		get_tree().root.add_child(c)
