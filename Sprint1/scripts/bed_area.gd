extends Area3D


# Called when the node enters the scene tree for the first time.
func get_hover_text():
	return "[font_size=30px]Press E to go to sleep[/font_size]"

func activate(playerobj):
	PlayerData.inventory = playerobj.inventory
	PlayerData.selected_slot = playerobj.selected_slot
	PlayerData.seedpouch = playerobj.seedpouch
	PlayerData.save_state()
	PotData._save_pots()
	var boss_threshold := Daycycle.MAX_BEATEN_DAYS if "MAX_BEATEN_DAYS" in Daycycle else 15
	await Transition.blink(func():
		if Daycycle.beaten_days < boss_threshold:
			get_tree().change_scene_to_file("res://scenes/outerworld.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/bossarena.tscn"))
