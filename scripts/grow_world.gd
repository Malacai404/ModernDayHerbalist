extends Node3D

signal scene_change
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_playlist("grow_world")
	print("LoadingPots")
	PotData._load_pots()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
