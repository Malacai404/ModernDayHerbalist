extends "res://scripts/enemy.gd"
# Spitter — mid health/speed, keeps distance and fires a projectile.
# PLACEHOLDER projectile: reuses kiwi_shard until spitter projectile art exists.

var shoot_cooldown := 1.8
var _shoot_timer := 1.8
var preferred_range := 9.0

func _ready() -> void:
	health = 30
	speed = 3.8
	acceleration = 9.0
	enemy_kind = "enemy_spitter"
	loot_rolls = 1
	money_min = 4
	money_max = 9
	super._ready()

func _physics_process(delta: float) -> void:
	_shoot_timer -= delta
	# kite: if too close, keep target slightly behind self
	if is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < preferred_range:
			# nav away-ish: set target to opposite dir
			var away = (global_position - player.global_position).normalized() * 6.0
			nav_agent.target_position = global_position + away
		else:
			nav_agent.target_position = player.global_position
		if dist <= preferred_range + 1.0 and _shoot_timer <= 0 and has_node("../.."):
			_try_shoot()
			_shoot_timer = shoot_cooldown
	super._physics_process(delta)

func _try_shoot():
	var scene = load("res://objects/projectiles/plum_blob.tscn")
	if scene == null: return
	var p = scene.instantiate()
	p.global_position = global_position + Vector3(0, 1.1, 0)
	# aim at player
	if is_instance_valid(player):
		p.look_at(player.global_position + Vector3(0, 0.8, 0), Vector3.UP)
		# Area3D forward is -Z, look_at faces -Z toward target if we rotate 180? keep simple: set rotation toward target
		var dir = (player.global_position - p.global_position).normalized()
		p.global_transform.basis = Basis.looking_at(-dir, Vector3.UP)
	p.damage = 10
	p.speed = 10.0
	get_tree().root.add_child(p)
