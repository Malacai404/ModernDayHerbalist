extends CanvasLayer

var pot_id = 0

var is_grow_world = true


var seed_pouch = []

var pots = []

@onready var player_character = $"../../.."


@onready var slots = $background/MarginContainer/GridContainer.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	is_grow_world = has_pot_host()
	if is_grow_world == true:
		pots = get_tree().current_scene.get_node("pot_host").get_children()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _set_pot(seed_slot: Control):
	var slot_index = slots.find(seed_slot)
	if slot_index == -1:
		return

	var pouch_entry = seed_pouch[slot_index]
	if pouch_entry["itemid"] == -1 or pouch_entry["count"] <= 0:
		return

	pots[pot_id]._plant(pouch_entry["itemid"])

	pouch_entry["count"] -= 1
	if pouch_entry["count"] <= 0:
		pouch_entry["itemid"] = -1
		pouch_entry["count"] = 0
	player_character.seedpouch = seed_pouch

	_close_seed_slots()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _open_seed_slots(pot_temp: int):
	var b = 0
	for i in slots:
		if seed_pouch[b]["itemid"] != -1:
			i.set_item(SeedData._get_seed(seed_pouch[b]["itemid"]), seed_pouch[b]["count"])
		else:
			i.set_item(null, 0)
		b += 1
	pot_id = pot_temp
	visible = true
	
func _close_seed_slots():
	pot_id = -1
	
	visible = false

func has_pot_host() -> bool:
	return get_tree().current_scene.get_node_or_null("pot_host") != null
