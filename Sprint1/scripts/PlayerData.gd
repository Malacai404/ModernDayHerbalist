extends Node

const SAVE_PATH := "user://playerdata_save.cfg"

var selected_slot:= 0

var inventory = [
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0}
]
var seedpouch = [
	{"itemid": 0, "count": 5},
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

func _ready() -> void:
	load_state()

func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "selected_slot", selected_slot)
	config.set_value("player", "inventory", inventory)
	config.set_value("player", "seedpouch", seedpouch)
	config.save(SAVE_PATH)

func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	selected_slot = int(config.get_value("player", "selected_slot", 0))
	var saved_inventory = config.get_value("player", "inventory", inventory)
	if saved_inventory is Array:
		inventory = saved_inventory
	var saved_seedpouch = config.get_value("player", "seedpouch", seedpouch)
	if saved_seedpouch is Array:
		seedpouch = saved_seedpouch

func _process(delta: float) -> void:
	pass
