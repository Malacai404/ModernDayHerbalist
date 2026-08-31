extends Node
class_name ShopController

var rng := RandomNumberGenerator.new()
@export var max_seed_stock_per_slot := 5
@export var max_fruit_stock_per_slot := 12

var seed_prices :=  [6, 8, 10, 7, 12, 9,  5, 10, 9, 14, 7, 6, 8, 18, 16, 11]
var fruit_prices := [8, 12, 14, 10, 18, 14, 7, 15, 12, 18, 10, 9, 11, 26, 22, 16]

var stock: Array = []

@onready var _shop_root: CanvasLayer = get_parent() as CanvasLayer if get_parent() is CanvasLayer else null

func _ready():
	if not ShopData.has_signal("shop_refreshed"):
		ShopData.add_user_signal("shop_refreshed")
	if not ShopData.money_changed.is_connected(_on_wallet_changed):
		ShopData.money_changed.connect(_on_wallet_changed)
	if stock.is_empty():
		refresh_stock(true)

func _on_wallet_changed(_a=null):
	_apply_to_ui()

func refresh_stock(force := false):
	if not force and not stock.is_empty():
		return
	rng.randomize()
	stock.clear()
	var seed_count = SeedData.seeds.size()
	var plant_count = SeedData.plants.size()
	var slot_count = _slot_count()
	var used := {}
	for i in slot_count:
		var is_seed: bool = rng.randf() < 0.6
		var tries := 0
		var pick_id := -1
		while tries < 40:
			tries += 1
			var cand = rng.randi_range(0, (seed_count if is_seed else plant_count) - 1)
			var key = str(is_seed) + ":" + str(cand)
			if not used.has(key):
				pick_id = cand
				used[key] = true
				break
			if tries == 20:
				is_seed = not is_seed
		if pick_id == -1:
			pick_id = rng.randi_range(0, (seed_count if is_seed else plant_count) - 1)
		var price: int
		var qty: int
		if is_seed:
			price = seed_prices[pick_id] if pick_id < seed_prices.size() else 8
			price += rng.randi_range(-1, 2)
			price = max(2, price)
			qty = rng.randi_range(2, max_seed_stock_per_slot)
		else:
			price = fruit_prices[pick_id] if pick_id < fruit_prices.size() else 10
			price += rng.randi_range(-2, 3)
			price = max(3, price)
			qty = rng.randi_range(3, max_fruit_stock_per_slot)
		stock.append({"type": "seed" if is_seed else "fruit", "id": pick_id, "price": price, "remaining": qty, "slot": i})
	_apply_to_ui()
	if ShopData.has_signal("shop_refreshed"):
		ShopData.emit_signal("shop_refreshed")

func _slot_count() -> int:
	var shop_menu = _find_shop_menu()
	if shop_menu == null: return 8
	var slots = shop_menu.get_node_or_null("shopPanel/shopSlots")
	if slots == null: return 8
	return slots.get_child_count()

func _find_shop_menu() -> Node:
	if _shop_root: return _shop_root
	var n: Node = self
	while n:
		var c = n.get_node_or_null("shopMenu")
		if c: return c
		var c2 = n.get_node_or_null("UI/CanvasLayer/shopMenu")
		if c2: return c2
		n = n.get_parent()
	return null

var _bound_buttons: Array = []

func _apply_to_ui():
	var shop_menu = _find_shop_menu()
	if shop_menu == null: return
	var slots = shop_menu.get_node_or_null("shopPanel/shopSlots")
	if slots == null: return
	for rec in _bound_buttons:
		var b: Button = rec.get("btn")
		var cb = rec.get("callable")
		if is_instance_valid(b) and b.pressed.is_connected(cb):
			b.pressed.disconnect(cb)
	_bound_buttons.clear()
	for i in range(min(slots.get_child_count(), stock.size())):
		var entry: Dictionary = stock[i]
		var panel = slots.get_child(i)
		if panel == null: continue
		var icon: TextureRect = panel.get_node_or_null("ItemIcon") as TextureRect
		var price_label: Label = panel.get_node_or_null("ItemPrice") as Label
		var btn: Button = panel.get_node_or_null("shopButton") as Button
		var res = null
		if entry["type"] == "seed":
			if entry["id"] >= 0 and entry["id"] < SeedData.seeds.size():
				res = SeedData._get_seed(entry["id"])
		else:
			if entry["id"] >= 0 and entry["id"] < SeedData.plants.size():
				res = SeedData._get_plant(entry["id"])
		panel.visible = res != null or true
		if icon:
			var res_tex = null
			if res:
				res_tex = res.get_icon() if res.has_method("get_icon") else (res.get("texture") if res.get("texture") != null else res.get("icon"))
			icon.texture = res_tex
			var res_name2 = str(entry)
			if res:
				res_name2 = res.get_display_name() if res.has_method("get_display_name") else (str(res.get("name")) if str(res.get("name")) != "" else str(res.get("item_name")))
			icon.tooltip_text = "%s — $%d" % [res_name2, int(entry.get("price", 0))]
		if price_label:
			var suffix = " (x%d)" % int(entry.get("remaining", 0)) if int(entry.get("remaining", 0)) > 1 else ""
			price_label.text = "$%d%s" % [int(entry.get("price", 0)), suffix]
			price_label.modulate = Color(1,1,1) if int(entry.get("remaining", 0)) > 0 else Color(0.6,0.6,0.6)
		if btn:
			if int(entry.get("remaining", 0)) <= 0:
				btn.disabled = true
				btn.modulate = Color(0.6, 0.6, 0.6, 1)
				panel.modulate = Color(0.75, 0.75, 0.75, 1)
			else:
				btn.disabled = false
				var can_afford = _can_afford(int(entry.get("price", 0)))
				if not can_afford:
					btn.disabled = true
					btn.modulate = Color(1, 0.65, 0.65, 1)
					panel.modulate = Color(1, 0.9, 0.9, 1)
				else:
					btn.disabled = false
					btn.modulate = Color(1,1,1,1)
					panel.modulate = Color(1,1,1,1)
			var cb = _on_slot_pressed.bind(i)
			btn.pressed.connect(cb)
			_bound_buttons.append({"btn": btn, "callable": cb})

func _can_afford(price: int) -> bool:
	return ShopData.can_afford(price)

func _spend(price: int) -> bool:
	return ShopData.try_spend(price)

func _on_slot_pressed(slot_idx: int):
	if slot_idx < 0 or slot_idx >= stock.size(): return
	var entry: Dictionary = stock[slot_idx]
	if int(entry.get("remaining", 0)) <= 0: return
	var price = int(entry.get("price", 0))
	if not _can_afford(price): return
	if not _spend(price): return
	var player = _find_player()
	if entry["type"] == "seed":
		if player and player.has_method("_collect_seed"):
			player._collect_seed(entry["id"], 1)
		else:
			var pd = get_node_or_null("/root/PlayerData")
			if pd and "seedpouch" in pd:
				_add_seed_to_pouch(pd.seedpouch, entry["id"], 1)
	else:
		if player and player.has_method("_pickup_item"):
			player._pickup_item(SeedData._get_plant(entry["id"]), 1)
		else:
			var pd2 = get_node_or_null("/root/PlayerData")
			if pd2 and "inventory" in pd2:
				var fruit = SeedData._get_plant(entry["id"])
				var placed := false
				for slot in pd2.inventory:
					if slot.get("item") != null and slot["item"].has_method("get_display_name") and slot["item"].get_display_name() == fruit.get_display_name():
						slot["count"] += 1
						placed = true
						break
					elif slot.get("item") == null and not placed:
						slot["item"] = fruit
						slot["count"] = 1
						placed = true
						break
	entry["remaining"] -= 1
	_apply_to_ui()

func _find_player() -> Node:
	var n: Node = self
	while n:
		var p = n.get_node_or_null("playerHead")
		if p: return n
		var cands = get_tree().get_nodes_in_group("player") if get_tree() else []
		if not cands.is_empty(): return cands[0]
		n = n.get_parent()
	if get_tree():
		for cand in get_tree().get_nodes_in_group("player"):
			return cand
		for cand in get_tree().root.find_children("*", "CharacterBody3D", true, false):
			if cand.has_method("_pickup_item"): return cand
	return null

func _add_seed_to_pouch(pouch: Array, seedid: int, qty: int):
	for slot in pouch:
		if slot["itemid"] == seedid:
			slot["count"] += qty
			return
	for slot in pouch:
		if slot["itemid"] == -1:
			slot["itemid"] = seedid
			slot["count"] = qty
			return
