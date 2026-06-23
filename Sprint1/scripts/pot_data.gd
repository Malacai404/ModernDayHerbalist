extends Node3D


var pots = []
var pot_ids = [0,1,2,3,4]
var growth_stages = [-1, -1, 0, 0, 0]
var growth_times = [1,1,1,1,1]
var plantids = [-1,-1,-1,-1,-1]



func upgd(potid: int, growth_stage: int):
	growth_stages[potid] = growth_stage
	print("Growth stage updated:")
	print(growth_stage)
	print(growth_stages)


func upgtd(potid: int, growth_time: int):
	growth_times[potid] = growth_time
	print("Growth growth_time updated:")
	print(growth_time)
	print(growth_times)
	
func uppi(potid: int, plantid: int):
	plantids[potid] = plantid
	print("Plant id updated:")
	print(plantid)
	print(plantids)

func _ready():
	if has_pot_host():
		pots = get_tree().current_scene.get_node("pot_host").get_children()
		var b = 0
		for i in pots:
			print("Loading pot data.")
			print("Pot Id:" + str(i.pot_id))
			print("Growth times:" + str(growth_times[b]))
			print("Growth growthstage:", str(growth_stages[b]))
			i.growthtime = growth_times[b]
			i.growthstage = growth_stages[b]
			i.plantid = plantids[b]
			b += 1

func _load_pots():
	if has_pot_host():
		pots = get_tree().current_scene.get_node("pot_host").get_children()
		for i in pots:
			var id = i.pot_id
			i.growthtime = growth_times[id]
			i.growthstage = growth_stages[id]
			i.plantid = plantids[id]

func has_pot_host() -> bool:
	return get_tree().current_scene.get_node_or_null("pot_host") != null
