extends Area3D

var damage = 20
@export var hit_interval := 1.0

var hit_targets := {}

func _process(delta: float) -> void:
	# Update cooldowns
	for body in hit_targets.keys():
		hit_targets[body] -= delta

		if hit_targets[body] <= 0:
			hit_targets.erase(body)

	# Damage overlapping enemies
	for body in get_overlapping_bodies():
		if !body.is_in_group("enemy"):
			continue

		if !body.has_method("damage"):
			continue

		if hit_targets.has(body):
			continue

		body.damage(damage)
		hit_targets[body] = hit_interval

func _delete():
	queue_free()
