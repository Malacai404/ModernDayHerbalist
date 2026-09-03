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

func _get_desired_nav_target() -> Vector3:
	var base := super._get_desired_nav_target()
	if not is_instance_valid(player) or not is_instance_valid(nav_agent):
		return base
	var weave := sin(Time.get_ticks_msec() * 0.005) * 1.6
	var with_weave := base + Vector3(weave, 0, 0)
	# clamp weave target back onto nav so agent doesn't try to path off-mesh (which can cause huge next_point)
	var w := get_world_3d()
	if w:
		var m := w.navigation_map
		if m.is_valid():
			var c := NavigationServer3D.map_get_closest_point(m, with_weave)
			if with_weave.distance_squared_to(c) < 36.0:
				return c
	return with_weave

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
