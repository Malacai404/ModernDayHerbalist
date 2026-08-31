extends Node3D

var enemies: Array = []
var leaving := false
var leavetimer := 2.0

@onready var enemies_parent: Node3D = $enemies

var rng := RandomNumberGenerator.new()

var _enemy_scenes: Dictionary = {}

func _ready() -> void:
	MusicManager.play_playlist("outerworld_1")
	rng.randomize()
	_enemy_scenes = {
		"enemy": preload("res://objects/enemy.tscn"),
		"enemy_brute": preload("res://objects/enemy_brute.tscn"),
		"enemy_sprinter": preload("res://objects/enemy_sprinter.tscn"),
		"enemy_spitter": preload("res://objects/enemy_spitter.tscn"),
	}
	_spawn_wave()

func _spawn_wave() -> void:
	for c in enemies_parent.get_children():
		c.queue_free()
	enemies.clear()
	var day := 1
	if Engine.has_singleton("Daycycle") or get_node_or_null("/root/Daycycle"):
		var dc = get_node_or_null("/root/Daycycle")
		if dc and "daycount" in dc:
			day = int(dc.daycount)
			if day < 1: day = 1
	var total := clampi(3 + int(day * 1.1) + rng.randi_range(0, 2), 3, 18)
	var weights := _weights_for_day(day)
	var nav_region := get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	var fallback_center := Vector3.ZERO
	if nav_region and nav_region.navigation_mesh:
		fallback_center = nav_region.global_position
	for i in total:
		var kind := _pick_weighted(weights)
		var scene: PackedScene = _enemy_scenes.get(kind, _enemy_scenes["enemy"])
		if scene == null:
			continue
		var e: Node = scene.instantiate()
		e.add_to_group("enemy")
		var pos := _random_spawn_point(nav_region, fallback_center)
		e.transform.origin = pos
		if "player_path" in e:
			e.player_path = NodePath("../../playerCharacter")
		enemies_parent.add_child(e)
		enemies.append(e)

func _weights_for_day(day: int) -> Dictionary:
	if day <= 1:
		return {"enemy": 9, "enemy_sprinter": 2, "enemy_brute": 1, "enemy_spitter": 1}
	elif day <= 3:
		return {"enemy": 6, "enemy_sprinter": 4, "enemy_brute": 2, "enemy_spitter": 3}
	elif day <= 5:
		return {"enemy": 4, "enemy_sprinter": 3, "enemy_brute": 4, "enemy_spitter": 5}
	else:
		return {"enemy": 2, "enemy_sprinter": 3, "enemy_brute": 5, "enemy_spitter": 6}

func _pick_weighted(weights: Dictionary) -> String:
	var total := 0.0
	for v in weights.values():
		total += float(v)
	var r := rng.randf() * total
	var acc := 0.0
	for k in weights.keys():
		acc += float(weights[k])
		if r <= acc:
			return str(k)
	return str(weights.keys()[0])

func _random_spawn_point(nav_region: NavigationRegion3D, center: Vector3) -> Vector3:
	for _attempt in 12:
		var offset := Vector3(rng.randf_range(-28.0, 28.0), 0.0, rng.randf_range(-28.0, 28.0))
		var candidate := center + offset
		if nav_region:
			var closest: Vector3 = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), candidate)
			if closest.distance_to(candidate) < 5.0:
				return Vector3(closest.x, -31.4, closest.z)
		return Vector3(candidate.x, -31.4, candidate.z)
	return Vector3(rng.randf_range(-18.0, 18.0), -31.4, rng.randf_range(-18.0, 18.0))

func _process(delta: float) -> void:
	enemies = enemies.filter(func(obj): return is_instance_valid(obj))
	if enemies.is_empty():
		leaving = true
	if leaving:
		leavetimer -= delta
	if leavetimer <= 0.0:
		leavetimer = 2.0
		leaving = false
		Daycycle._daypassed()
		await Transition.blink(func():
			get_tree().change_scene_to_file("res://scenes/grow_world.tscn"))
