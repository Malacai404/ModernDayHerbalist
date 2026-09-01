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
var _airborne_time := 0.0
var _ground_snap_retries := 0

func snap_to_ground(margin: float = 1.05) -> void:
	# MUST be callable from outerworld even before enemy is fully inside tree/physics.
	# Nav is primary (works instantly after map baked), ray is optional refine.
	var world: World3D = get_world_3d()
	if world == null and get_tree() and get_tree().root:
		world = get_tree().root.get_world_3d()
	if world == null and get_tree() and get_tree().current_scene:
		world = get_tree().current_scene.get_world_3d()
	if world == null:
		return
	var map := world.navigation_map
	var nav_closest := Vector3.ZERO
	var nav_y := INF
	var nav_valid := false
	if map.is_valid():
		# Use map_get_closest_point even if iteration_id == 0 it still returns something after _ready await,
		# but guard anyway.
		nav_closest = NavigationServer3D.map_get_closest_point(map, global_position)
		# If point is within 100m horizontally, nav is usable (covers whole outerworld ~150x150)
		if nav_closest.distance_squared_to(global_position) < 10000.0:
			nav_y = nav_closest.y
			nav_valid = true
	if nav_valid:
		# Place feet on nav surface. Enemy origin is ~1m above feet due to capsule offset/scale,
		# so margin ~1.0-1.1 puts feet just above ground.
		var target := Vector3(global_position.x, nav_y + margin, global_position.z)
		var flat2 := Vector2(target.x - nav_closest.x, target.z - nav_closest.z).length_squared()
		if flat2 > 9.0:
			target.x = nav_closest.x
			target.z = nav_closest.z
			target.y = nav_y + margin
		global_position = target
		velocity = Vector3.ZERO
	else:
		# Absolute last resort — outerworld floor is at NavigationRegion3D.global_position.y (~ -38.45)
		var fallback_y := -38.45
		if get_tree() and get_tree().current_scene:
			var reg := get_tree().current_scene.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
			if reg:
				fallback_y = reg.global_position.y
		global_position = Vector3(global_position.x, fallback_y + margin, global_position.z)
		velocity = Vector3.ZERO
		return
	# Optional ray refine — only adopt hit if it's close to nav_y (avoids tree trunk hits high above ground)
	var space := world.direct_space_state
	if space:
		var from := global_position + Vector3(0, 40.0, 0)
		var to := global_position + Vector3(0, -120.0, 0)
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.collision_mask = 0xFFFFFFFF
		query.hit_from_inside = true
		query.exclude = [get_rid()]
		var hit: Dictionary = space.intersect_ray(query)
		if hit.has("position"):
			var hp: Vector3 = hit["position"]
			# Ignore tree/prop hits more than 3.5m above nav surface
			if hp.y > nav_y + 3.5:
				pass
			elif absf(hp.y - nav_y) < 5.0:
				global_position = hp + Vector3(0, margin, 0)
				velocity = Vector3.ZERO

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
	# Ground now that world/nav is ready and physics_server has synced add_child
	snap_to_ground(1.05)
	# One more try next physics frame to catch deferred collisions
	await get_tree().physics_frame
	snap_to_ground(1.05)
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
	if _attack_area == null: return
	var bodies := _attack_area.get_overlapping_bodies()
	for b in bodies:
		if b.has_method("damage") and b.is_in_group("player"):
			b.damage(attack_damage)
			_attack_timer = attack_cooldown
			return
		if b is player:
			b.damage(attack_damage)
			_attack_timer = attack_cooldown
			return
	# Also check player global distance as fallback if area not overlapping yet
	if is_instance_valid(player) and player.has_method("damage"):
		if global_position.distance_to(player.global_position) < 4.5:
			player.damage(attack_damage)
			_attack_timer = attack_cooldown

func _physics_process(delta: float) -> void:
	if global_position.y < DESPAWN_Y:
		queue_free()
		return
	if healthbar: healthbar.update_health(health, max_health)
	if health <= 0:
		_die()
		return

	# While airborne, freeze horizontal movement — only gravity.
	# Retry snap a few times in case initial snap missed due to timing.
	if not is_on_floor():
		velocity.x = 0
		velocity.z = 0
		velocity.y -= gravity * delta
		_airborne_time += delta
		if _airborne_time > 0.15 and _ground_snap_retries < 6:
			_ground_snap_retries += 1
			snap_to_ground(1.05)
		move_and_slide()
		if global_position.y < DESPAWN_Y:
			queue_free()
		return
	else:
		_airborne_time = 0.0
		_ground_snap_retries = 0

	_attack_timer -= delta
	_try_attack()

	if not is_instance_valid(player):
		var cands3 := get_tree().get_nodes_in_group("player") if get_tree() else []
		if not cands3.is_empty(): player = cands3[0] as Node3D
	if is_instance_valid(player):
		nav_agent.target_position = player.global_position
	var direction: Vector3 = Vector3.ZERO
	var nav_map := get_world_3d().navigation_map if get_world_3d() else RID()
	var map_ready := nav_map.is_valid() and NavigationServer3D.map_get_iteration_id(nav_map) != 0
	var try_nav := map_ready and is_instance_valid(player) and nav_agent.is_target_reachable() and not nav_agent.is_navigation_finished()
	if try_nav:
		var nav_pos := nav_agent.get_next_path_position()
		direction = nav_pos - global_position
		direction.y = 0
		if direction.length_squared() > 0.001: direction = direction.normalized()
	elif is_instance_valid(player):
		direction = player.global_position - global_position
		direction.y = 0
		if direction.length_squared() > 0.001: direction = direction.normalized()
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
	velocity.y = 0 # keep glued to ground while on_floor
	move_and_slide()
