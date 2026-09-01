extends "res://scripts/enemy.gd"
# Spitter — mid health/speed, keeps distance and fires a projectile.
# PLACEHOLDER projectile: reuses kiwi_shard until spitter projectile art exists.

var shoot_cooldown := 1.8
var _shoot_timer := 1.8
var preferred_range := 9.0

func _ready() -> void:
	health = 30
	speed = 2.8
	acceleration = 9.0
	enemy_kind = "enemy_spitter"
	attack_damage = 10
	loot_rolls = 1
	money_min = 4
	money_max = 9
	super._ready()

var _kite_target := Vector3.INF

func _get_desired_nav_target() -> Vector3:
	if not is_instance_valid(player):
		return super._get_desired_nav_target()
	if _kite_target == Vector3.INF:
		return player.global_position
	return _kite_target

func _physics_process(delta: float) -> void:
	_shoot_timer -= delta
	# compute kiting target for base class to consume via _get_desired_nav_target
	if is_instance_valid(player):
		var dist := global_position.distance_to(player.global_position)
		if dist < preferred_range:
			var away_dir := (global_position - player.global_position)
			away_dir.y = 0
			if away_dir.length_squared() < 0.001:
				away_dir = Vector3(1, 0, 0)
			away_dir = away_dir.normalized()
			_kite_target = global_position + away_dir * 6.0
			# clamp kite target onto nav + leash so we don't ask agent to path into void (which yeets velocity)
			var w := get_world_3d()
			if w:
				var m := w.navigation_map
				if m.is_valid():
					var c := NavigationServer3D.map_get_closest_point(m, _kite_target)
					if _kite_target.distance_squared_to(c) < 100.0:
						_kite_target = c
					else:
						_kite_target = player.global_position
					var center := _get_nav_center()
					if Vector2(_kite_target.x - center.x, _kite_target.z - center.z).length_squared() > (MAX_LEASH * 0.92) * (MAX_LEASH * 0.92):
						_kite_target = player.global_position
		else:
			_kite_target = player.global_position
		if dist <= preferred_range + 1.0 and _shoot_timer <= 0 and has_node("../.."):
			_try_shoot()
			_shoot_timer = shoot_cooldown
	else:
		_kite_target = Vector3.INF
	super._physics_process(delta)

func _try_shoot():
	if not is_inside_tree(): return
	var scene = load("res://objects/projectiles/plum_blob.tscn")
	if scene == null: return
	var p = scene.instantiate()
	if not is_instance_valid(player): return
	if "is_enemy_shot" in p: p.is_enemy_shot = true
	p.global_position = global_position + Vector3(0, 1.1, 0)
	get_tree().root.add_child(p)
	var dir: Vector3 = (player.global_position + Vector3(0, 0.8, 0) - p.global_position).normalized()
	if dir.length_squared() > 0.001:
		p.global_transform.basis = Basis.looking_at(-dir, Vector3.UP)
	p.damage = 10
	p.speed = 10.0
	if "is_enemy_shot" in p: p.is_enemy_shot = true
