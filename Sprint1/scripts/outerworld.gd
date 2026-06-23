extends Node3D


var enemies = []

var leaving = false
var leavetimer = 2

@onready var enemies_parent = $enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_playlist("outerworld_1")
	for jit in enemies_parent.get_children():
		if jit.is_in_group("enemy"):
			enemies.append(jit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enemies = enemies.filter(func(obj): return is_instance_valid(obj))
	if enemies == []:
		leaving = true
	if leaving == true:
		leavetimer -= delta
	if leavetimer <= 0:
		leavetimer = 2 
		leaving = false
		Daycycle._daypassed()
		await Transition.blink(func():
			get_tree().change_scene_to_file("res://scenes/grow_world.tscn"))
