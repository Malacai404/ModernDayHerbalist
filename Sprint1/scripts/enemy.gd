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
	var col: Color = _TINT_BY_KIND.get(kind, Color(1, 1, 1))
	for child_name in ["Cube", "Sphere", "MeshInstance3D"]:
		var mi := get_node_or_null(child_name) as MeshInstance3D
		if mi == null:
			continue
		var mat := StandardMaterial3D.new()
		mat.albedo_color = col
		mat.roughness = 0.62
		mi.material_override = mat
	for c in get_children():
		if c is MeshInstance3D and c.material_override == null:
			var mat2 := StandardMaterial3D.new()
			mat2.albedo_color = col
			c.material_override = mat2

var player: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	max_health = health
	if has_node(player_path):
		player = get_node(player_path) as Node3D

	if healthbar:
		healthbar.update_health(health, max_health)
	_tint_by_kind(enemy_kind)
	set_physics_process(false)
	await NavigationServer3D.map_changed
	set_physics_process(true)

func damage(hurt):
	health -= hurt

var _is_dead := false
@export var loot_rolls: int = 1
@export var enemy_kind: String = "enemy"
@export var money_min: int = 2
@export var money_max: int = 6

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

func _physics_process(delta: float) -> void:
	if healthbar: healthbar.update_health(health, max_health)
	if health <= 0:
		_die()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_instance_valid(player):
		nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
		return

	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var current_pos: Vector3 = global_position

	var direction: Vector3 = (next_path_pos - current_pos).normalized()
	direction.y = 0

	var target_velocity: Vector3 = direction * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if direction.length_squared() > 0.001:
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)
		rotation.x = 0.0
		rotation.z = 0.0

	move_and_slide()
