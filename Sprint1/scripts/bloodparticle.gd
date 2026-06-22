extends GPUParticles3D
var time = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.6, 1.4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time -= delta
	if time <= 0:
		queue_free()
