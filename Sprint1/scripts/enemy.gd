extends CharacterBody3D
class_name enemy

var max_health := 30
var health := 30

@export var speed: float = 4.0
@export var acceleration: float = 10.0
@export var player_path: NodePath

@onready var healthbar: Node3D = $healthbar

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

const BLOODPARTICLE = preload("uid://i3mrnq0n7eyn")

const _TINT_BY_KIND: Dictionary = {
	"enemy": Color(0.92, 0.86, 0.72),
	"enemy_brute": Color(0.82, 0.22, 0.18),
	"enemy_sprinter": Color(0.32, 0.86, 0.42),
	"enemy_spitter": Color(0.62, 0.52, 0.96),
}

func _tint_by_kind(kind: String) -> void:
	if kind == "enemy":
		return
	var tint: Color = _TINT_BY_KIND.get(kind, Color(1, 1, 1))
	for child_name in ["Cube", "Sphere", "MeshInstance3D"]:
		var mi := get_node_or_null(child_name) as MeshInstance3D
		if mi == null:
			continue
		var src := mi.get_active_material(0) as StandardMaterial3D
		if src == null and mi.mesh:
			src = mi.mesh.surface_get_material(0) as StandardMaterial3D
		var mat := StandardMaterial3D.new()
		if src:
			mat.albedo_texture = src.albedo_texture
			mat.roughness = src.roughness
			mat.metallic = src.metallic
			mat.normal_enabled = src.normal_enabled
			mat.normal_texture = src.normal_texture
		mat.albedo_color = tint
		mi.material_override = mat
	for c in get_children():
		if c is MeshInstance3D and c.material_override == null:
			var src2 := c.get_active_material(0) as StandardMaterial3D
			var mat2 := StandardMaterial3D.new()
			if src2: mat2.albedo_texture = src2.albedo_texture
			mat2.albedo_color = tint
			c.material_override = mat2

var player: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const DESPAWN_Y := -200.0
const MAX_LEASH := 75.0
var _airborne_time := 0.0
var _ground_snap_retries := 0
var _grounded := false
# --- DEBUG (lean) ---
const _DBG_INTERVAL := 0.5
var _dbg_t := 0.0
func _dbg(msg: String) -> void:
	print("[ENEMY_DBG %s#%d pos=%s vel=%s on_floor=%s] %s" % [enemy_kind, get_instance_id(), str(global_position).substr(0,28), str(velocity).substr(0,22), str(is_on_floor()), msg])

func _get_desired_nav_target() -> Vector3:
	if is_instance_valid(player):
		return player.global_position
	return global_position

func _get_nav_center() -> Vector3:
	if get_tree() and get_tree().current_scene:
		var reg := get_tree().current_scene.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
		if reg:
			return reg.global_position
	return Vector3.ZERO

func _get_nav_ground_y(world_pos: Vector3) -> float:
	var w: World3D = get_world_3d()
	if w == null and get_tree() and get_tree().root:
		w = get_tree().root.get_world_3d()
	if w == null and get_tree() and get_tree().current_scene:
		w = get_tree().current_scene.get_world_3d()
	if w == null: return INF
	var m := w.navigation_map
	if not m.is_valid(): return INF
	var c := NavigationServer3D.map_get_closest_point(m, world_pos)
	if c.distance_squared_to(world_pos) > 10000.0: return INF
	return c.y

func snap_to_ground(margin: float = 2.0) -> bool:
	# LAST GOOD SNAPPING — now just lifts to avoid sinking. Don't go too high or airborne logic resets.
	# Capsule half-height is ~0.3-0.4 scaled, so margin 1.1 puts feet at floor+~0.7 visible.
	var before := global_position
	var w: World3D = get_world_3d()
	if w == null and get_tree() and get_tree().root:
		w = get_tree().root.get_world_3d()
	if w == null and get_tree() and get_tree().current_scene:
		w = get_tree().current_scene.get_world_3d()
	if w == null:
		return false
	var m := w.navigation_map
	var nav_c := Vector3.ZERO
	var nav_y := INF
	var nav_ok := false
	if m.is_valid():
		nav_c = NavigationServer3D.map_get_closest_point(m, global_position)
		if nav_c.distance_squared_to(global_position) < 10000.0:
			nav_y = nav_c.y
			nav_ok = true
	var floor_y := -38.44
	if get_tree() and get_tree().current_scene:
		var reg := get_tree().current_scene.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
		if reg:
			floor_y = reg.global_position.y
	var space := w.direct_space_state
	var hit_y := INF
	var hit_ok := false
	if space:
		var from := global_position + Vector3(0, 60.0, 0)
		var to := global_position + Vector3(0, -200.0, 0)
		var q := PhysicsRayQueryParameters3D.create(from, to)
		q.collide_with_bodies = true
		q.collide_with_areas = false
		q.collision_mask = 0xFFFFFFFF
		q.hit_from_inside = true
		q.exclude = [get_rid()]
		var hit := space.intersect_ray(q)
		if hit.has("position"):
			var hp: Vector3 = hit["position"]
			if hp.y > floor_y + 5.0 and nav_ok and hp.y > nav_y + 3.5:
				pass
			else:
				hit_y = hp.y
				hit_ok = true
	var snapped := false
	var target_y := INF
	var target_xz := Vector2(global_position.x, global_position.z)
	var nav_trustworthy := nav_ok and absf(nav_y - floor_y) < 12.0
	var hit_trustworthy := hit_ok and absf(hit_y - floor_y) < 8.0
	if hit_trustworthy:
		target_y = hit_y + margin
		snapped = true
	elif nav_trustworthy:
		target_y = nav_y + margin
		target_xz = Vector2(nav_c.x, nav_c.z) if Vector2(global_position.x - nav_c.x, global_position.z - nav_c.z).length_squared() > 9.0 else target_xz
		snapped = true
	elif hit_ok and absf(hit_y - floor_y) < 12.0:
		target_y = hit_y + margin
		snapped = true
	else:
		target_y = floor_y + margin
		if nav_ok:
			target_xz = Vector2(nav_c.x, nav_c.z) if Vector2(global_position.x - nav_c.x, global_position.z - nav_c.z).length_squared() > 1.0 else target_xz
		snapped = true
	if snapped:
		if before.y < floor_y + 2.0 and (target_y > before.y + 0.8):
			global_position = Vector3(target_xz.x, floor_y + margin, target_xz.y)
		else:
			global_position = Vector3(target_xz.x, target_y, target_xz.y)
		velocity = Vector3.ZERO
		_grounded = true
	return snapped

func _ready() -> void:
	max_health = health
	if has_node(player_path):
		player = get_node(player_path) as Node3D
	if player == null:
		var cands := get_tree().get_nodes_in_group("player") if get_tree() else []
		if not cands.is_empty():
			player = cands[0] as Node3D
	if healthbar:
		healthbar.update_health(health, max_health)
	_tint_by_kind(enemy_kind)
	call_deferred("_tint_by_kind", enemy_kind)
	# Enemies must be grounded BEFORE physics starts — otherwise outerworld's
	# immediate snap_to_ground runs before nav/physics is ready and fails.
	# Disable movement while airborne; retry snap each frame until on_floor.
	_airborne_time = 0.0
	_ground_snap_retries = 0
	velocity = Vector3.ZERO
	set_physics_process(false)
	if is_inside_tree() and get_world_3d() and NavigationServer3D.map_get_iteration_id(get_world_3d().navigation_map) == 0:
		await NavigationServer3D.map_changed
	else:
		await get_tree().process_frame
	_dbg("READY spawn pos before snap=%s world_map_valid=%s iteration=%s" % [str(global_position), str(get_world_3d().navigation_map.is_valid() if get_world_3d() else false), str(NavigationServer3D.map_get_iteration_id(get_world_3d().navigation_map) if get_world_3d() and get_world_3d().navigation_map.is_valid() else -1)])
	# Ground now that world/nav is ready
	var s1 := snap_to_ground()
	_dbg("READY snap1 ok=%s pos=%s" % [str(s1), str(global_position)])
	await get_tree().physics_frame
	var s2 := snap_to_ground()
	_dbg("READY snap2 ok=%s pos=%s on_floor_next_frame=%s" % [str(s2), str(global_position), str(is_on_floor())])
	# Force physics sync so is_on_floor() becomes true immediately
	await get_tree().physics_frame
	move_and_slide()
	_dbg("READY after extra move_and_slide on_floor=%s pos=%s" % [str(is_on_floor()), str(global_position)])
	if player == null:
		var cands2 := get_tree().get_nodes_in_group("player") if get_tree() else []
		if not cands2.is_empty():
			player = cands2[0] as Node3D
	if nav_agent and get_world_3d():
		var m := get_world_3d().navigation_map
		if m.is_valid(): nav_agent.set_navigation_map(m)
	set_physics_process(true)

func damage(hurt):
	health -= hurt

var _is_dead := false
@export var loot_rolls: int = 1
@export var enemy_kind: String = "enemy"
@export var money_min: int = 2
@export var money_max: int = 6
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
var _attack_timer := 0.0
@onready var _attack_area: Area3D = get_node_or_null("AttackArea") as Area3D

func _die():
	if _is_dead: return
	_is_dead = true
	_spawn_loot()
	var particle = BLOODPARTICLE.instantiate()
	particle.position = position
	particle.position.y += 1
	get_tree().root.add_child(particle)
	queue_free()

const _LootTable := preload("res://scripts/loot_table.gd")

func _spawn_loot():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if money_max >= money_min:
		var base_money = rng.randi_range(money_min, money_max)
		if base_money > 0:
			ShopData.add_money(base_money)
			_notify_loot("money", 0, base_money)
	var loot = null
	if _LootTable:
		loot = _LootTable.default_for(enemy_kind)
	elif ClassDB.class_exists("LootTable"):
		loot = LootTable.default_for(enemy_kind)
	if loot:
		for i in maxi(0, loot_rolls):
			var pick: Dictionary = {}
			if loot.has_method("pick_one"):
				pick = loot.pick_one(rng)
			if pick.is_empty():
				continue
			_grant_pick(pick)
	else:
		if rng.randf() < 0.25 and SeedData.seeds.size() > 0:
			var sid = rng.randi_range(0, SeedData.seeds.size() - 1)
			_grant_pick({"kind":"seed","id":sid,"rolled":1})

func _grant_pick(pick: Dictionary):
	var kind = str(pick.get("kind","money"))
	var id = int(pick.get("id",0))
	var cnt = int(pick.get("rolled", pick.get("count", 1)))
	if kind == "money":
		ShopData.add_money(cnt)
		_notify_loot("money", 0, cnt)
	elif kind == "seed":
		var p = _find_player_for_loot()
		if p and p.has_method("_collect_seed"):
			p._collect_seed(id, cnt)
		else:
			_add_seed_to_pouch_fallback(id, cnt)
		_notify_loot("seed", id, cnt)
	elif kind == "fruit":
		var p2 = _find_player_for_loot()
		if p2 and p2.has_method("_pickup_item"):
			p2._pickup_item(SeedData._get_plant(id), cnt)
		_notify_loot("fruit", id, cnt)

func _find_player_for_loot() -> Node:
	var tree = get_tree()
	if tree == null: return null
	var cands = tree.get_nodes_in_group("player")
	if not cands.is_empty(): return cands[0]
	for n in tree.root.find_children("*", "CharacterBody3D", true, false):
		if n.has_method("_pickup_item"): return n
	return null

func _add_seed_to_pouch_fallback(seedid: int, qty: int):
	var pd = get_node_or_null("/root/PlayerData")
	if pd == null: return
	var pouch = pd.get("seedpouch")
	if pouch == null: return
	for slot in pouch:
		if int(slot.get("itemid", -1)) == seedid:
			slot["count"] = int(slot["count"]) + qty
			return
	for slot in pouch:
		if int(slot.get("itemid", -1)) == -1:
			slot["itemid"] = seedid
			slot["count"] = qty
			return

func _notify_loot(kind: String, id: int, amount: int):
	if amount <= 0: return
	var tree = get_tree()
	if tree == null: return
	var p = _find_player_for_loot()
	if p and p.has_method("_pickup_item"):
		var container = p.get_node_or_null("UI/CanvasLayer/ItemAdditionContainer")
		if container and container.has_method("_item_collected"):
			var label := ""
			if kind == "money":
				label = "Coins"
			elif kind == "seed":
				var s = SeedData._get_seed(clamp(id, 0, max(0, SeedData.seeds.size() - 1)))
				label = (str(s.name) if s and "name" in s and str(s.name) != "" else "Seed x%d" % id)
			elif kind == "fruit":
				var f = SeedData._get_plant(clamp(id, 0, max(0, SeedData.plants.size() - 1)))
				if f:
					label = f.get_display_name() if f.has_method("get_display_name") else str(f.get("name") if f.get("name") != null else "Fruit")
				else:
					label = "Fruit"
			else:
				label = kind
			container._item_collected(label, amount)
			return
	print("[loot] %s x%d (id %d)" % [kind, amount, id])



func _try_attack() -> void:
	if _attack_timer > 0.0: return
	# Log attack checks so we can see if range check is too generous
	if is_instance_valid(player) and _attack_timer <= 0.0:
		var d_to_player := global_position.distance_to(player.global_position)
		if d_to_player < 3.0:
			print("[ENEMY_ATTACK_CHECK] %s dist=%.1f area_overlaps=%d timer=%.2f pos=%s player=%s" % [enemy_kind, d_to_player, _attack_area.get_overlapping_bodies().size() if _attack_area else -1, _attack_timer, str(global_position), str(player.global_position)])
	if _attack_area == null: return
	var bodies := _attack_area.get_overlapping_bodies()
	for b in bodies:
		if b.has_method("damage") and b.is_in_group("player"):
			# Real Area contact — verify it's actually close, not a stale overlap list
			var real_dist := b.global_position.distance_to(global_position)
			if real_dist > 3.0:
				print("[ENEMY_HIT_REJECTED_STALE] %s bodies=%s real_dist=%.1f" % [enemy_kind, str(bodies.size()), real_dist])
				continue
			var hp_before: int = int(b.health) if "health" in b else -1
			b.damage(attack_damage)
			var hp_after: int = int(b.health) if "health" in b else -1
			print("[ENEMY_HIT] %s -> player dmg=%d hp %d->%d player_pos=%s enemy_pos=%s" % [enemy_kind, attack_damage, hp_before, hp_after, str(b.global_position), str(global_position)])
			_attack_timer = attack_cooldown
			return
		if b is player:
			var hp2_before: int = int(b.health) if "health" in b else -1
			b.damage(attack_damage)
			var hp2_after: int = int(b.health) if "health" in b else -1
			print("[ENEMY_HIT] %s -> player(direct) dmg=%d hp %d->%d player_pos=%s enemy_pos=%s" % [enemy_kind, attack_damage, hp2_before, hp2_after, str(b.global_position), str(global_position)])
			_attack_timer = attack_cooldown
			return
	# Also check player global distance as fallback — MUST be tight and only if already near floor contact
	# Old 4.5 was half the arena and hit through walls. Keep it barely larger than AttackArea capsule.
	if is_instance_valid(player) and player.has_method("damage"):
		if global_position.distance_to(player.global_position) < 1.9:
			var hp3_before: int = int(player.health) if "health" in player else -1
			player.damage(attack_damage)
			var hp3_after: int = int(player.health) if "health" in player else -1
			print("[ENEMY_HIT] %s -> player(distance fallback dist=%.1f) dmg=%d hp %d->%d player_pos=%s enemy_pos=%s" % [enemy_kind, global_position.distance_to(player.global_position), attack_damage, hp3_before, hp3_after, str(player.global_position), str(global_position)])
			_attack_timer = attack_cooldown

func _physics_process(delta: float) -> void:
	var center_dbg := _get_nav_center()
	# periodic heartbeat so you can see which enemies are alive/moving
	_dbg_t += delta
	if _dbg_t >= _DBG_INTERVAL:
		_dbg_t = 0.0
		var d2c := Vector2(global_position.x - center_dbg.x, global_position.z - center_dbg.z).length()
		_dbg("TICK dist_to_center=%.1f speed=%.1f nav_target=%s reachable=%s finished=%s" % [d2c, Vector2(velocity.x, velocity.z).length(), str(nav_agent.target_position) if nav_agent else "null", str(nav_agent.is_target_reachable()) if nav_agent else "?", str(nav_agent.is_navigation_finished()) if nav_agent else "?"])
	if global_position.y < DESPAWN_Y:
		_dbg("KILL y<DESPAWN y=%.1f" % global_position.y)
		queue_free()
		return
	if healthbar: healthbar.update_health(health, max_health)
	if health <= 0:
		_die()
		return

	# Leash + sanitize: if somehow flung far off-map, kill instead of skating forever.
	var center := _get_nav_center()
	var leash2 := Vector2(global_position.x - center.x, global_position.z - center.z).length_squared()
	if leash2 > (MAX_LEASH * MAX_LEASH):
		_dbg("KILL LEASH pre-move leash=%.1f > %.1f pos=%s vel=%s center=%s target=%s" % [sqrt(leash2), MAX_LEASH, str(global_position), str(velocity), str(center), str(nav_agent.target_position) if nav_agent else "null"])
		queue_free()
		return
	# NaN/InF sanitize — can happen from bad nav normals.
	if not (global_position.x == global_position.x and global_position.z == global_position.z):
		_dbg("KILL NAN pos=%s vel=%s" % [str(global_position), str(velocity)])
		queue_free()
		return

	if not is_on_floor():
		var floor_y_check := -38.44
		if get_tree() and get_tree().current_scene:
			var reg_air2 := get_tree().current_scene.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
			if reg_air2: floor_y_check = reg_air2.global_position.y
		# If we're close to floor, don't snap mid-fall — let physics land us. Only snap if clearly above floor.
		if absf(global_position.y - (floor_y_check + 1.1)) < 1.2:
			# Near floor but is_on_floor false for one tick — just count as grounded, no snap
			_airborne_time = 0.0
			_ground_snap_retries = 0
			velocity.y = max(velocity.y, 0.0)
			# fall through to grounded branch
		else:
			velocity.x = 0
			velocity.z = 0
			velocity.y -= gravity * delta
			_airborne_time += delta
			if _airborne_time > 0.22 and _ground_snap_retries < 4:
				_ground_snap_retries += 1
				snap_to_ground()
			var before_air := global_position
			move_and_slide()
			if before_air.distance_squared_to(global_position) > 9.0:
				_dbg("AIRBORNE JUMP before=%s after=%s vel=%s" % [str(before_air), str(global_position), str(velocity)])
				if global_position.y < -40.0:
					snap_to_ground()
			if global_position.y < DESPAWN_Y:
				_dbg("KILL airborne y<DESPAWN y=%.1f" % global_position.y)
				queue_free()
			if get_slide_collision_count() > 0:
				for i in get_slide_collision_count():
					var col := get_slide_collision(i)
					_dbg("AIRBORNE collision normal=%s vel=%s" % [str(col.get_normal()), str(velocity)])
					if col.get_normal().y < 0.3 and velocity.length_squared() > 25.0:
						velocity.x *= 0.2
						velocity.z *= 0.2
			return
	else:
		_airborne_time = 0.0
		_ground_snap_retries = 0

	_attack_timer -= delta
	_try_attack()

	if not is_instance_valid(player):
		var cands3 := get_tree().get_nodes_in_group("player") if get_tree() else []
		if not cands3.is_empty(): player = cands3[0] as Node3D
	# Clamp nav target to within nav mesh — prevents agent trying to path to unreachable off-map point which can yeet velocity.
	if is_instance_valid(player):
		var desired_raw := _get_desired_nav_target()
		var desired := desired_raw
		var w2 := get_world_3d()
		var m2 := w2.navigation_map if w2 else RID()
		if m2.is_valid():
			var closest2 := NavigationServer3D.map_get_closest_point(m2, desired)
			var off := desired.distance_squared_to(closest2)
			if off > 16.0:
				_dbg("NAV_CLAMP off=%.1f raw=%s closest=%s -> clamped" % [sqrt(off), str(desired), str(closest2)])
				desired = closest2
			var to_center2 := Vector2(desired.x - center.x, desired.z - center.z)
			var len2 := to_center2.length_squared()
			if len2 > (MAX_LEASH * 0.92) * (MAX_LEASH * 0.92):
				_dbg("NAV_LEASH len=%.1f raw=%s -> clamped to leash" % [sqrt(len2), str(desired)])
				desired = Vector3(center.x, desired.y, center.z) + Vector3(to_center2.x, 0, to_center2.y).normalized() * (MAX_LEASH * 0.9)
				desired.y = closest2.y
		if desired_raw.distance_squared_to(desired) > 1.0:
			_dbg("NAV_TARGET raw=%s final=%s" % [str(desired_raw), str(desired)])
		nav_agent.target_position = desired
	var direction: Vector3 = Vector3.ZERO
	var nav_map := get_world_3d().navigation_map if get_world_3d() else RID()
	var map_ready := nav_map.is_valid() and NavigationServer3D.map_get_iteration_id(nav_map) != 0
	var try_nav := map_ready and is_instance_valid(player) and nav_agent.is_target_reachable() and not nav_agent.is_navigation_finished()
	if try_nav:
		var nav_pos := nav_agent.get_next_path_position()
		var nav_dist := nav_pos.distance_to(global_position)
		if nav_dist > 12.0:
			_dbg("NAV_SPIKE next=%s dist=%.1f self=%s player=%s reachable=%s finished=%s map_ready=%s" % [str(nav_pos), nav_dist, str(global_position), str(player.global_position) if is_instance_valid(player) else "null", str(nav_agent.is_target_reachable()), str(nav_agent.is_navigation_finished()), str(map_ready)])
		direction = nav_pos - global_position
		direction.y = 0
		if direction.length_squared() > 0.001:
			direction = direction.normalized()
			if nav_dist > 12.0:
				_dbg("NAV_SPIKE fallback to direct player")
				if is_instance_valid(player):
					var direct := player.global_position - global_position
					direct.y = 0
					if direct.length_squared() > 0.001:
						direction = direct.normalized()
					else:
						direction = Vector3.ZERO
		elif is_instance_valid(player):
			direction = Vector3.ZERO
			_dbg("NAV_ZERO_DIR nav_pos=%s self=%s" % [str(nav_pos), str(global_position)])
	elif is_instance_valid(player):
		direction = player.global_position - global_position
		direction.y = 0
		if direction.length_squared() > 0.001: direction = direction.normalized()
		else:
			_dbg("DIRECT_ZERO player=%s self=%s" % [str(player.global_position), str(global_position)])
		if not map_ready:
			_dbg("DIRECT_FALLBACK map_ready=%s reachable=%s finished=%s" % [str(map_ready), str(nav_agent.is_target_reachable()) if nav_agent else "?", str(nav_agent.is_navigation_finished()) if nav_agent else "?"])
	if direction != Vector3.ZERO:
		var target_velocity: Vector3 = direction * speed
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)
		rotation.x = 0.0
		rotation.z = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	# Clamp speed so physics bumps can't amplify infinitely.
	var horiz := Vector2(velocity.x, velocity.z).length()
	if horiz > speed * 1.6:
		_dbg("SPEED_CLAMP horiz=%.1f > %.1f vel=%s dir=%s" % [horiz, speed*1.6, str(velocity), str(direction)])
		var s := (speed * 1.6) / horiz
		velocity.x *= s
		velocity.z *= s
	velocity.y = 0
	var before_move := global_position
	move_and_slide()
	var moved := before_move.distance_to(global_position)
	if moved > 2.0:
		_dbg("LARGE_MOVE delta=%.1f before=%s after=%s vel=%s dir=%s collisions=%d" % [moved, str(before_move), str(global_position), str(velocity), str(direction), get_slide_collision_count()])
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if absf(global_position.x) > 60.0 or absf(global_position.z) > 60.0:
			_dbg("COLLISION n=%s pos=%s" % [str(c.get_normal()), str(c.get_position())])
	# Post-move leash: if we ended up far off, kill or snap back.
	if Vector2(global_position.x - center.x, global_position.z - center.z).length_squared() > (MAX_LEASH * MAX_LEASH):
		_dbg("KILL LEASH post-move leash=%.1f pos=%s vel=%s before=%s" % [Vector2(global_position.x-center.x, global_position.z-center.z).length(), str(global_position), str(velocity), str(before_move)])
		queue_free()
