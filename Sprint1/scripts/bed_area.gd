extends Area3D


# Called when the node enters the scene tree for the first time.
func get_hover_text():
	return "[font_size=30px]Press E to go to sleep[/font_size]"

func activate(playerobj):
	PlayerData.inventory = playerobj.inventory
	PlayerData.selected_slot = playerobj.selected_slot
	PlayerData.seedpouch = playerobj.seedpouch
	PotData._save_pots()
	await Transition.blink(func():
		if(Daycycle.daycount < 20):
			get_tree().change_scene_to_file("res://scenes/outerworld.tscn")
		elif(Daycycle.daycount >= 20):
			get_tree().change_scene_to_file("res://scenes/bossarena.tscn"))
