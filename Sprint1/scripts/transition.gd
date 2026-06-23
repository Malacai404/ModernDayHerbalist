extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal scene_change

var busy = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func blink(action: Callable):
	if busy:
		return

	busy = true

	$AnimationPlayer.play("close_eyes")
	await $AnimationPlayer.animation_finished

	emit_signal("scene_change")
	action.call()

	await get_tree().process_frame

	$AnimationPlayer.play("open_eyes")
	await $AnimationPlayer.animation_finished

	busy = false

# Example of transition call
#await Transition.blink(func():
#    get_tree().change_scene_to_file("res://levels/level2.tscn")
#)
