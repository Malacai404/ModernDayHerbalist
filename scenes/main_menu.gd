extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_playlist("grow_world")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _start():
	await Transition.blink(func():
		get_tree().change_scene_to_file("res://scenes/grow_world.tscn"))
	
func _quit():
	get_tree().quit()
	
func _settings():
	$Settings2.visible = true
	
func _closesettings():
	$Settings2.visible = false
