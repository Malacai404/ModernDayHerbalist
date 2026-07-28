extends Area3D

var speed = 20
var rate_of_change = 10
var damage = 15

@export var hit_cooldown := 0.5

var hit_targets := {}

func _process(delta: float) -> void:
	# Update hit cooldowns
	for body in hit_targets.keys():
		hit_targets[body] -= delta
		if hit_targets[body] <= 0:
			hit_targets.erase(body)

	# Move the banana
	speed -= delta * rate_of_change
	var direction = -global_transform.basis.z.normalized()
	position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("enemy"):
		return

	if !body.has_method("damage"):
		return

	if hit_targets.has(body):
		return

	body.damage(damage)
	hit_targets[body] = hit_cooldown
