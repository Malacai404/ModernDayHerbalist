extends CharacterBody3D
class_name player


const jump_force = 4.5
const room_speed = 3.5
const world_speed = 7.5

var mouse_sensitivity = 0.005
var current_speed = 5.0

var vertical_limit_deg = 60

var bed_dialogue = false

var in_outerworld = false

@onready var cooldown_circle: TextureProgressBar = $UI/CanvasLayer/CrosshairContainer/CooldownCircle

var selected_slot := 0

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


var attack_cooldown = 0.5
var attack_cooldown_save = 0.5

@onready var hovertext: RichTextLabel = $UI/CanvasLayer/Hovertext


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
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0}
]
func _kill():
	print("You died!")

func _ready():
	volume_slider.value = SettingsData.volume_settings
	sens_slider.value = SettingsData.sens_settings  * 10
	inventory = PlayerData.inventory
	seedpouch = PlayerData.seedpouch
	selected_slot = PlayerData.selected_slot
	update_slot_highlight()
	_handle_inventory()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event.is_action_pressed("leftclick"):
		use_selected_item_left_click()
	if event.is_action_pressed("rightclick"):
		use_selected_item_right_click()
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
	# Rotate the camera and head based on mouse movement
	if event is InputEventMouseMotion:
		# Horizontal rotation (turn the player)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Vertical rotation (tilt the camera)
		player_head.rotate_x(-event.relative.y * mouse_sensitivity)
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(-vertical_limit_deg), deg_to_rad(vertical_limit_deg))


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
	
func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		$UI/CanvasLayer/Settings.visible = !$UI/CanvasLayer/Settings.visible
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	SettingsData.volume_settings = volume_slider.value
	SettingsData.sens_settings = sens_slider.value / 10
	mouse_sensitivity = sens_slider.value / 10
	attack_cooldown -= delta
	if(attack_cooldown > 0):
		var ratio =  attack_cooldown/attack_cooldown_save
		cooldown_circle.value = ratio * 100
	else:
		cooldown_circle.value = 0
	if look_cast.is_colliding():
		var collider = look_cast.get_collider()
		if collider and collider.has_method("get_hover_text"):
			if Input.is_action_just_pressed("Interact"):
				collider.activate($".")
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
	item_addition_container._item_collected(item.name, num)
	for slot in inventory:
		if slot["item"] != null and item != null:
			if slot["item"].name == item.name:
			
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
	item_addition_container._item_collected(SeedData._get_seed(seedid).name, num)
	var b = find_seed_index(seedid)
	if b != -1:
		seedpouch[b]["count"] += num
	else:
		b = find_seed_index(-1)
		seedpouch[b]["count"] += num
func find_seed_index(target_itemid: int) -> int:
	for i in range(seedpouch.size()):
		if seedpouch[i]["itemid"] == target_itemid:
			return i
	return -1
