extends Node3D

var enemies: Array = []
var leaving := false
var leavetimer := 2.0

@onready var enemies_parent: Node3D = $enemies

var rng := RandomNumberGenerator.new()

var _enemy_scenes: Dictionary = {}

var _has_spawned := false

func _ready() -> void:
	MusicManager.play_playlist("outerworld_1")
	rng.randomize()
	_enemy_scenes = {
		"enemy": preload("res://objects/enemy.tscn"),
		"enemy_brute": preload("res://objects/enemy_brute.tscn"),
		"enemy_sprinter": preload("res://objects/enemy_sprinter.tscn"),
		"enemy_spitter": preload("res://objects/enemy_spitter.tscn"),
	}
	var world := get_world_3d()
	var nav_map := world.navigation_map if world else RID()
	if nav_map.is_valid() and NavigationServer3D.map_get_iteration_id(nav_map) == 0:
		await NavigationServer3D.map_changed
	await _spawn_wave()
	_has_spawned = true
	if enemies.is_empty():
		for i in 6:
			_spawn_one_fallback()
		# ensure fallbacks also ground
		await get_tree().physics_frame
		for en in enemies:
			if is_instance_valid(en) and en.has_method("snap_to_ground"):
				en.snap_to_ground()

func _spawn_wave() -> void:
	for c in enemies_parent.get_children():
		c.queue_free()
	enemies.clear()
	var day := 1
	var dc := get_node_or_null("/root/Daycycle")
	if dc and "daycount" in dc:
		day = int(dc.daycount)
		if day < 1: day = 1
	var total := clampi(3 + int(day * 1.1) + rng.randi_range(0, 2), 3, 18)
	var weights := _weights_for_day(day)
	var nav_region := get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	var fallback_center := Vector3.ZERO
	if nav_region:
		fallback_center = nav_region.global_position
	# spread scales with count so larger waves use wider ring
	var max_radius := lerpf(18.0, 55.0, clampf(float(total - 3) / 15.0, 0.0, 1.0))
	var min_radius := max_radius * 0.35
	var placed: Array[Vector3] = []
	# player exclusion — never spawn on top of player
	var player_node := get_node_or_null("playerCharacter") as Node3D
	var player_pos := player_node.global_position if player_node else fallback_center
	var player_exclude := 12.0  # 2D radius around player where spawning is forbidden
	# also wait one physics frame so raycasts/nav queries are valid before sampling
	# (world/navigation already awaited in _ready, this is just for direct_space_state sync)
	await get_tree().physics_frame
	for i in total:
		var kind := _pick_weighted(weights)
		var scene: PackedScene = _enemy_scenes.get(kind, _enemy_scenes["enemy"])
		if scene == null:
			continue
		var e: Node = scene.instantiate()
		e.add_to_group("enemy")
		var pos := _random_spawn_point(nav_region, fallback_center, min_radius, max_radius, placed, 4.5, player_pos, player_exclude)
		# add first so world/nav queries use correct global transform
		if "player_path" in e:
			e.player_path = NodePath("../../playerCharacter")
		enemies_parent.add_child(e)
		e.global_position = pos
		# snap to ground instantly — don't drop from sky (nav-primary, ray fallback)
		if e.has_method("snap_to_ground"):
			e.snap_to_ground()
		else:
			_snap_node_to_ground(e)
		placed.append(e.global_position)
		enemies.append(e)
	# second pass deferred snap covers case where physics server wasn't synced yet at add_child time
	await get_tree().physics_frame
	for en in enemies:
		if is_instance_valid(en) and en.has_method("snap_to_ground"):
			en.snap_to_ground()

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

func _snap_node_to_ground(node: Node3D, margin: float = 1.1) -> void:
	var world := get_world_3d()
	if world == null: world = get_tree().root.get_world_3d() if get_tree() else null
	if world == null: return
	# nav-primary: most reliable for terrain height
	var map := world.navigation_map
	if map.is_valid():
		var c: Vector3 = NavigationServer3D.map_get_closest_point(map, node.global_position)
		if c.distance_squared_to(node.global_position) < 6400.0: # 80m
			node.global_position = Vector3(node.global_position.x, c.y + margin, node.global_position.z)
			# nudge x/z toward nav if far, then ray-refine
			if Vector2(node.global_position.x - c.x, node.global_position.z - c.z).length_squared() > 9.0:
				node.global_position.x = c.x
				node.global_position.z = c.z
	var space := world.direct_space_state
	if space:
		var from := node.global_position + Vector3(0, 80.0, 0)
		var to := node.global_position + Vector3(0, -400.0, 0)
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.collision_mask = 0xFFFFFFFF
		query.hit_from_inside = true
		query.exclude = [node.get_rid()] if node is CollisionObject3D else []
		var hit: Dictionary = space.intersect_ray(query)
		if hit.has("position"):
			var hp: Vector3 = hit["position"]
			# prefer floorBody hit — if we hit a tree collider above ground, keep higher of nav vs ray but clamp
			if map.is_valid():
				var cn: Vector3 = NavigationServer3D.map_get_closest_point(map, node.global_position)
				# if ray hit is >4m above nav, it's a tree/prop — use nav height instead
				if hp.y > cn.y + 4.0:
					node.global_position = cn + Vector3(0, margin, 0)
				else:
					node.global_position = hp + Vector3(0, margin, 0)
			else:
				node.global_position = hp + Vector3(0, margin, 0)
			if "velocity" in node: node.velocity.y = 0
			return
	if map.is_valid():
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, node.global_position)
		if closest.distance_to(node.global_position) < 80.0:
			node.global_position = closest + Vector3(0, margin, 0)
			if "velocity" in node: node.velocity.y = 0

func _random_spawn_point(nav_region: NavigationRegion3D, center: Vector3, min_radius: float = 12.0, max_radius: float = 28.0, placed: Array[Vector3] = [], min_sep: float = 4.5, player_pos: Vector3 = Vector3.INF, player_exclude: float = 12.0) -> Vector3:
	if nav_region == null or not nav_region.get_navigation_map().is_valid():
		print("[SPAWN_DBG] nav_region null/invalid center=%s" % str(center))
		for _t in 64:
			var ang := rng.randf_range(0, TAU)
			var rad := rng.randf_range(min_radius, max_radius)
			var off := Vector3(cos(ang) * rad, 0, sin(ang) * rad)
			var cand := center + off
			cand.y = center.y
			if not _is_far_enough(cand, placed, min_sep): continue
			if player_pos != Vector3.INF and _dist2_xz(cand, player_pos) < player_exclude * player_exclude: continue
			return cand
		var fb2 := center + Vector3(rng.randf_range(-max_radius, max_radius), 0, rng.randf_range(-max_radius, max_radius))
		fb2.y = center.y
		return fb2
	var nav_map := nav_region.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(nav_map) == 0:
		print("[SPAWN_DBG] iteration 0 fallback center=%s player=%s" % [str(center), str(player_pos)])
		for _t in 64:
			var ang2 := rng.randf_range(0, TAU)
			var rad2 := rng.randf_range(min_radius, max_radius)
			var off2 := Vector3(cos(ang2) * rad2, 0, sin(ang2) * rad2)
			var cand2 := center + off2
			# candidate y must be near floor, not 0.2
			cand2.y = center.y
			if not _is_far_enough(cand2, placed, min_sep): continue
			if player_pos != Vector3.INF and _dist2_xz(cand2, player_pos) < player_exclude * player_exclude: continue
			print("[SPAWN_DBG] iteration0 pick cand=%s" % str(cand2))
			return cand2
		var fb := center + Vector3(rng.randf_range(-max_radius, max_radius), 0, rng.randf_range(-max_radius, max_radius))
		fb.y = center.y
		return fb
	var best: Vector3 = Vector3.ZERO
	var best_dist := INF
	var best_closest := Vector3.ZERO
	for _attempt in 80:
		var ang := rng.randf_range(0, TAU)
		var rad := rng.randf_range(min_radius, max_radius)
		var offset := Vector3(cos(ang) * rad, 0.0, sin(ang) * rad)
		var candidate := center + offset
		if not _is_far_enough(candidate, placed, min_sep):
			continue
		if player_pos != Vector3.INF and _dist2_xz(candidate, player_pos) < player_exclude * player_exclude:
			continue
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, candidate)
		var d := closest.distance_to(candidate)
		if d < 2.5:
			return Vector3(closest.x, closest.y + 0.25, closest.z)
		if d < 6.0 and d < best_dist:
			best_dist = d
			best_closest = closest
		if d < best_dist:
			best_dist = d
			best_closest = closest
	if best_dist < 8.0:
		return Vector3(best_closest.x, best_closest.y + 0.25, best_closest.z)
	# best was far off-mesh (>8) — ignore it, pick random on ring at correct y
	for _t in 32:
		var ang3 := rng.randf_range(0, TAU)
		var rad3 := rng.randf_range(min_radius, max_radius)
		var off3 := Vector3(cos(ang3) * rad3, 0.0, sin(ang3) * rad3)
		var cand3 := center + off3
		cand3.y = center.y
		if not _is_far_enough(cand3, placed, min_sep): continue
		if player_pos != Vector3.INF and _dist2_xz(cand3, player_pos) < player_exclude * player_exclude: continue
		print("[SPAWN_DBG] fallback random cand3=%s (best was far %.1f)" % [str(cand3), best_dist])
		return cand3
	var fb3 := center + Vector3(rng.randf_range(-max_radius, max_radius), 0, rng.randf_range(-max_radius, max_radius))
	fb3.y = center.y
	print("[SPAWN_DBG] final fallback fb3=%s" % str(fb3))
	return fb3

func _dist2_xz(a: Vector3, b: Vector3) -> float:
	var dx := a.x - b.x; var dz := a.z - b.z; return dx * dx + dz * dz

func _is_far_enough(cand: Vector3, placed: Array[Vector3], min_sep: float) -> bool:
	for p in placed:
		var dx := cand.x - p.x
		var dz := cand.z - p.z
		if dx * dx + dz * dz < min_sep * min_sep:
			return false
	return true

func _spawn_one_fallback() -> void:
	var kind := _pick_weighted(_weights_for_day(1))
	var scene: PackedScene = _enemy_scenes.get(kind, _enemy_scenes["enemy"])
	if scene == null: return
	var e: Node = scene.instantiate()
	e.add_to_group("enemy")
	var nav_region := get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	var center := Vector3.ZERO
	if nav_region: center = nav_region.global_position
	var player_node2 := get_node_or_null("playerCharacter") as Node3D
	var player_pos2 := player_node2.global_position if player_node2 else center
	var fallback_placed: Array[Vector3] = []
	for en in enemies:
		if is_instance_valid(en): fallback_placed.append(en.global_position)
	var pos2 := _random_spawn_point(nav_region, center, 12.0, 22.0, fallback_placed, 4.5, player_pos2, 12.0)
	e.transform.origin = pos2
	if "player_path" in e:
		e.player_path = NodePath("../../playerCharacter")
	enemies_parent.add_child(e)
	if e.has_method("snap_to_ground"):
		e.snap_to_ground()
	else:
		_snap_node_to_ground(e)
	enemies.append(e)

func _process(delta: float) -> void:
	# Always cull dead/invalid + also kill any enemy that was removed from tree without queue_free
	enemies = enemies.filter(func(obj): return is_instance_valid(obj) and is_instance_valid(obj) and obj.is_inside_tree())
	# Also include live scene children that somehow aren't in array (paranoia: leash kills remove from array but child still under parent until freed)
	var live_children := 0
	for c in enemies_parent.get_children():
		if c.is_in_group("enemy") and not c.is_queued_for_deletion():
			live_children += 1
	# Only auto-leave if we've finished spawning
	if not _has_spawned:
		return
	# Must check both tracking array AND actual scene children — tracking can desync if enemy freed elsewhere
	var truly_empty := enemies.is_empty() and live_children == 0
	# If tracking says empty but children remain, resync
	if enemies.is_empty() and live_children > 0:
		for c in enemies_parent.get_children():
			if c.is_in_group("enemy") and not c.is_queued_for_deletion():
				enemies.append(c)
		return
	if not truly_empty:
		# Someone alive — reset leaving if it was triggered by a single-frame flicker
		# (e.g. spawn race where array was briefly empty)
		leaving = false
		leavetimer = 2.0
		return
	# Truly empty for real — start/drive leavetimer
	if truly_empty:
		leaving = true
	if leaving:
		leavetimer -= delta
	if leavetimer <= 0.0:
		leavetimer = 2.0
		leaving = false
		Daycycle._daypassed()
		await Transition.blink(func():
			get_tree().change_scene_to_file("res://scenes/grow_world.tscn"))
