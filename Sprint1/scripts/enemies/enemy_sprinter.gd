extends "res://scripts/enemy.gd"
# Sprinter — fragile, very fast, dodges by strafe (TODO: strafe logic)
func _ready() -> void:
	health = 14
	speed = 3.0
	acceleration = 16.0
	enemy_kind = "enemy_sprinter"
	attack_damage = 8
	attack_cooldown = 0.6
	loot_rolls = 2
	money_min = 1
	money_max = 3
	super._ready()

func _physics_process(delta: float) -> void:
	# lightly weave: add small lateral offset to target
	if is_instance_valid(player) and nav_agent:
		var base = player.global_position
		var weave = sin(Time.get_ticks_msec() * 0.005) * 1.6
		nav_agent.target_position = base + Vector3(weave, 0, 0)
	super._physics_process(delta)
