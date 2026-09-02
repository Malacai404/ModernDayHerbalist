extends Area3D

# Sells the player's currently selected held inventory slot when the player
# presses the Interact action while inside this area.

var player_in_area: Node = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))



func get_hover_text():
	return "[font_size=20px]Press E to sell items in hand[/font_size]"

func activate(playerobj):
	pass

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = body

func _on_body_exited(body: Node) -> void:
	if body == player_in_area:
		player_in_area = null

func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("Interact"):
		_try_sell_held_item(player_in_area)

func _try_sell_held_item(player_node: Node) -> void:
	if not player_node: return
	if not ("inventory" in player_node and "selected_slot" in player_node):
		return
	var slot_idx = int(player_node.selected_slot)
	if slot_idx < 0 or slot_idx >= player_node.inventory.size():
		return
	var slot = player_node.inventory[slot_idx]
	if slot == null or slot.get("item") == null or int(slot.get("count",0)) <= 0:
		return

	var item = slot["item"]
	var count = int(slot["count"])
	var display_name = item.get_display_name() if item.has_method("get_display_name") else str(item.get("name") or item.get("item_name"))

	# Determine sell price per unit by matching against SeedData plants
	var unit_price = 1
	for i in range(SeedData.plants.size()):
		var cand = SeedData._get_plant(i)
		if cand.get_display_name() == display_name:
			unit_price = ShopData.get_plant_price(i)
			break

	var total = unit_price * count
	ShopData.add_money(total)

	# show green pickup effect for sold items (display coin total)
	if player_node.item_addition_container and player_node.item_addition_container.has_method("_item_collected"):
		player_node.item_addition_container._item_collected("Coins", total, Color(0,1,0,1))

	# remove the item from player's slot
	slot["item"] = null
	slot["count"] = 0
	if player_node.has_method("_handle_inventory"):
		player_node._handle_inventory()
