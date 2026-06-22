extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale.x = randf_range(0.05, 0.1)
	scale.y = randf_range(0.05, 0.1)
	scale.z = randf_range(0.05, 0.1)
	rotation.y = randf_range(0, 360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
