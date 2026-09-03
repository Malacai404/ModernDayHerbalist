extends Node3D

const SAVE_PATH := "user://potdata_save.cfg"

var pots = []
var pot_ids = [0,1,2,3,4]
var growth_stages = [-1, -1, 0, 1, 0]
var growth_times = [1,1,1,1,1]
var plantids = [8,7,1,5,6]

func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("pots", "growth_stages", growth_stages)
	config.set_value("pots", "growth_times", growth_times)
	config.set_value("pots", "plantids", plantids)
	config.save(SAVE_PATH)

func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	var saved_growth_stages = config.get_value("pots", "growth_stages", growth_stages)
	var saved_growth_times = config.get_value("pots", "growth_times", growth_times)
	var saved_plantids = config.get_value("pots", "plantids", plantids)
	if saved_growth_stages is Array:
		growth_stages = saved_growth_stages
	if saved_growth_times is Array:
		growth_times = saved_growth_times
	if saved_plantids is Array:
		plantids = saved_plantids

func upgd(potid: int, growth_stage: int):
	growth_stages[potid] = growth_stage
	save_state()

func upgtd(potid: int, growth_time: int):
	growth_times[potid] = growth_time
	save_state()
	
func uppi(potid: int, plantid: int):
	plantids[potid] = plantid
	save_state()

func _ready():
	load_state()
	if has_pot_host():
		pots = get_tree().current_scene.get_node("pot_host").get_children()
		var b = 0
		for i in pots:
			i.growthtime = growth_times[b]
			i.growthstage = growth_stages[b]
			i.plantid = plantids[b]
			b += 1

func _save_pots():
	if has_pot_host():
		pots = get_tree().current_scene.get_node("pot_host").get_children()
		for i in pots:
			var id = i.pot_id
			growth_times[id] = i.growthtime
			growth_stages[id] = i.growthstage
			plantids[id] = i.plantid
	save_state()

func _load_pots():
	load_state()
	if has_pot_host():
		pots = get_tree().current_scene.get_node("pot_host").get_children()
		for i in pots:
			var id = i.pot_id
			i.growthtime = growth_times[id]
			i.growthstage = growth_stages[id]
			i.plantid = plantids[id]

func has_pot_host() -> bool:
	return get_tree().current_scene.get_node_or_null("pot_host") != null
