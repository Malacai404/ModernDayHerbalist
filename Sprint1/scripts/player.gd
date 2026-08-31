extends CharacterBody3D
class_name player

const jump_force = 4.5
const room_speed = 3.5
const world_speed = 7.5

var max_health := 100
var health := 100
var _dead := false
var _hurt_iframe := 0.0

var mouse_sensitivity = 0.005
var current_speed = 5.0

var vertical_limit_deg = 60

var interact_delay = 0
const interact_delay_saved = 0.3
var has_interacted = false

var bed_dialogue = false

var in_settings_menu = false
var in_seed_menu = false
var in_phone_menu = false

var in_outerworld = false

@onready var cooldown_circle: TextureProgressBar = $UI/CanvasLayer/CrosshairContainer/CooldownCircle

var selected_slot := 0

@onready var phone_menu = $UI/CanvasLayer/PhoneMenu

@onready var player_mesh = $playerMesh
@onready var player_collision = $playerCollision
@onready var player_head = $playerHead
@onready var item_addition_container: VBoxContainer = $UI/CanvasLayer/ItemAdditionContainer

@onready var seedslots = $UI/CanvasLayer/SeedMenu/background/MarginContainer/GridContainer.get_children()

@onready var look_cast = $playerHead/lookCast
@onready var item_slot_1: Control = $UI/CanvasLayer/ItemSlots/ItemSlot_1
@onready var item_slot_2: Control = $UI/CanvasLayer/ItemSlots/ItemSlot_2
@onready var item_slot_3: Control = $UI/CanvasLayer/ItemSlots/ItemSlot_3
@onready var item_slot_4: Control = $UI/CanvasLayer/ItemSlots/ItemSlot_4
@onready var item_slot_5: Control = $UI/CanvasLayer/ItemSlots/ItemSlot_5

@onready var sens_slider: HSlider = $UI/CanvasLayer/Settings/Sens/SensSlider
@onready var volume_slider: HSlider = $UI/CanvasLayer/Settings/Sens2/VolumeSlider

@onready var seed_menu = $UI/CanvasLayer/SeedMenu
@onready var shop_menu: CanvasLayer = $UI/CanvasLayer/shopMenu

var attack_cooldown = 0
var attack_cooldown_save = 0.5

@onready var hovertext: RichTextLabel = $UI/CanvasLayer/Hovertext

@onready var shop_animator: AnimationPlayer = $UI/CanvasLayer/shopMenu/shopAnimator

@onready var item_slots = [item_slot_1, item_slot_2, item_slot_3, item_slot_4, item_slot_5]

var inventory = [
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0}
]

var seedpouch = [
	{"itemid": 0, "count": 10},
	{"itemid": 1, "count": 5},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0}
]
func damage(amount: int) -> void:
	if _dead: return
	if _hurt_iframe > 0.0: return
	health = max(0, health - amount)
	_hurt_iframe = 0.5
	print("player hurt: ", amount, " hp=", health)
	if health <= 0:
		_kill()

func _kill():
	if _dead: return
	_dead = true
	print("You died!")
	await Transition.blink(func():
		PlayerData.inventory = inventory
		PlayerData.seedpouch = seedpouch
		PlayerData.selected_slot = selected_slot
		health = max_health
		_dead = false
		get_tree().change_scene_to_file("res://scenes/grow_world.tscn"))

func _ready():
	add_to_group("player")
	shop_menu.visible = false
	volume_slider.value = SettingsData.volume_settings
	sens_slider.value = SettingsData.sens_settings  * 10
	inventory = PlayerData.inventory
	seedpouch = PlayerData.seedpouch
	selected_slot = PlayerData.selected_slot
	update_slot_highlight()
	_handle_inventory()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if _in_menu():
		return
	if event.is_action_pressed("slot1"):
		select_slot(0)
	elif(event.is_action_pressed("slot2")):
		select_slot(1)
	elif(event.is_action_pressed("slot3")):
		select_slot(2)
	elif(event.is_action_pressed("slot4")):
		select_slot(3)
	elif(event.is_action_pressed("slot5")):
		select_slot(4)

func _open_seedslots(pot_id: int):
	if(seed_menu.visible == true):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		seed_menu._close_seed_slots()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		seed_menu.seed_pouch = seedpouch
		seed_menu._open_seed_slots(pot_id)

func select_slot(index: int):
	selected_slot = index
	update_slot_highlight()

func update_slot_highlight():
	for i in range(item_slots.size()):
		if i == selected_slot:
			item_slots[i].select()
		else:
			item_slots[i].deselect()

func _handle_inventory():
	for i in range(item_slots.size()):
		var slot = item_slots[i]
		slot.set_item(
			inventory[i]["item"],
			inventory[i]["count"]
		)

func _unhandled_input(event):
	if _in_menu():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		player_head.rotate_x(-event.relative.y * mouse_sensitivity)
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(-vertical_limit_deg), deg_to_rad(vertical_limit_deg))
		player_head.rotation.y = 0.0
		player_head.rotation.z = 0.0
		rotation.z = 0.0
		orthonormalize()
		get_viewport().set_input_as_handled()

func _phone_active():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	phone_menu._phone_pickup()

func use_selected_item_right_click():
	if attack_cooldown <= 0:
		var slot = inventory[selected_slot]
		if slot["item"] != null:
			slot["item"]._rightclick(self)
			slot["count"] -= 1
			attack_cooldown = slot["item"].cooldown
			attack_cooldown_save = slot["item"].cooldown
			if slot["count"] <= 0:
				slot["item"] = null
				slot["count"] = 0
			_handle_inventory()
func use_selected_item_left_click():
	if attack_cooldown <= 0:
		var slot = inventory[selected_slot]
		if slot["item"] != null:
			slot["item"]._leftclick(self)
			slot["count"] -= 1
			attack_cooldown = slot["item"].cooldown
			attack_cooldown_save = slot["item"].cooldown
			if slot["count"] <= 0:
				slot["item"] = null
				slot["count"] = 0
			_handle_inventory()

func _manage_input():
	if Input.is_action_pressed("leftclick"):
		use_selected_item_left_click()
	if Input.is_action_pressed("rightclick"):
		use_selected_item_right_click()

func _close_shop():
	ShopData.close_shop()
func _manage_shop_state():
	if ShopData.shop_open == true and shop_menu.visible == false:
		shop_menu.visible = true
		shop_animator.play("shop_in")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var ctrl = shop_menu.get_node_or_null("ShopController") as ShopController
		if ctrl == null:
			ctrl = get_node_or_null("UI/CanvasLayer/shopMenu/ShopController") as ShopController
		if ctrl: ctrl.refresh_stock(true)
		_update_wallet_label()
	elif ShopData.shop_open == false and shop_menu.visible == true:
		shop_animator.play("shop_out")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var _wallet_connected := false

func _update_wallet_label():
	var lbl = shop_menu.get_node_or_null("shopPanel/walletLabel") as Label
	if lbl: lbl.text = "Wallet: $%d" % ShopData.money
	if not _wallet_connected:
		ShopData.money_changed.connect(_on_money_changed)
		_wallet_connected = true
	var ctrl = shop_menu.get_node_or_null("ShopController") as ShopController
	if ctrl: ctrl._apply_to_ui()

func _on_money_changed(_new_amount: int):
	var lbl = shop_menu.get_node_or_null("shopPanel/walletLabel") as Label
	if lbl: lbl.text = "Wallet: $%d" % ShopData.money
	var ctrl2 = shop_menu.get_node_or_null("ShopController") as ShopController
	if ctrl2: ctrl2._apply_to_ui()

func _manage_menu_state():
	if Input.is_action_just_pressed("menu") and in_seed_menu == false:
		$UI/CanvasLayer/Settings.visible = !$UI/CanvasLayer/Settings.visible
		in_settings_menu = !in_settings_menu
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("Interact") and in_seed_menu == true:
		seed_menu._close_seed_slots()
		interact_delay = interact_delay_saved
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _manage_settings():
	SettingsData.volume_settings = volume_slider.value
	SettingsData.sens_settings = sens_slider.value / 10
	mouse_sensitivity = sens_slider.value / 10

func _in_menu():
	if in_settings_menu or in_seed_menu or in_phone_menu or ShopData.shop_open == true:
		return true
	else:
		return false
func _physics_process(delta):
	_manage_shop_state()
	_manage_settings()
	_manage_menu_state()

	attack_cooldown -= delta
	interact_delay -= delta
	if _hurt_iframe > 0.0:
		_hurt_iframe -= delta

	if _in_menu():
		return
	_manage_input()
	if(attack_cooldown > 0):
		var ratio =  attack_cooldown/attack_cooldown_save
		cooldown_circle.value = ratio * 100
	else:
		cooldown_circle.value = 0
	if look_cast.is_colliding():
		var collider = look_cast.get_collider()
		if collider and collider.has_method("get_hover_text"):
			if Input.is_action_just_pressed("Interact") and interact_delay <= 0:
				collider.activate($".")
				interact_delay = interact_delay_saved
			hovertext.text = str(collider.get_hover_text())
			hovertext.show()
		else:
			hovertext.hide()
	else:
		hovertext.hide()

	if in_outerworld == false:

		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force

		var input_dir = Input.get_vector("left", "right", "forward", "back")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	move_and_slide()

func _pickup_item(item: Item, num: int):
	item_addition_container._item_collected(item.get_display_name() if item.has_method("get_display_name") else str(item.get("name") or item.get("item_name")), num)
	for slot in inventory:
		if slot["item"] != null and item != null:
			if (slot["item"].get_display_name() if slot["item"].has_method("get_display_name") else str(slot["item"].get("name") or slot["item"].get("item_name"))) == (item.get_display_name() if item.has_method("get_display_name") else str(item.get("name") or item.get("item_name"))):

				if(slot["count"] < 99):
					slot["item"] = item
					slot["count"] += num
					_handle_inventory()
					return

	for slot in inventory:
		if slot["item"] == null:
			if(slot["count"] < 99):
				slot["item"] = item
				slot["count"] += num
				_handle_inventory()
				return

func _collect_seed(seedid: int, num: int):
	print("Found at:", find_seed_index(seedid))
	item_addition_container._item_collected(SeedData._get_seed(seedid).name, num)

	var slot_index = find_seed_index(seedid)

	if slot_index != -1:
		seedpouch[slot_index]["count"] += num
		if seedpouch[slot_index]["count"] > 99:
			seedpouch[slot_index]["count"] = 99

	else:
		var empty_index = find_empty_seed_slot()

		if empty_index != -1:
			seedpouch[empty_index]["itemid"] = seedid
			seedpouch[empty_index]["count"] = num
		else:
			print("No space for seed!")

	_enforce_single_seed_slots()

	seed_menu.seed_pouch = seedpouch

func _enforce_single_seed_slots():
	var seen = {}

	for i in range(seedpouch.size()):
		var id = seedpouch[i]["itemid"]

		if id == -1:
			continue

		if seen.has(id):
			seedpouch[i]["itemid"] = -1
			seedpouch[i]["count"] = 0
		else:
			seen[id] = i

func find_seed_index(target_itemid: int) -> int:
	for i in range(seedpouch.size()):
		if seedpouch[i]["itemid"] == target_itemid:
			return i
	return -1
func find_empty_seed_slot() -> int:
	for i in range(seedpouch.size()):
		if seedpouch[i]["itemid"] == -1:
			return i
	return -1
