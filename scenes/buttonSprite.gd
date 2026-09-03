extends AnimatedSprite2D

var frame_save = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _selected():
	frame_save = frame
	play("selected")
	frame = frame_save
	
func _unselected():
	frame_save = frame
	play("unselected")
	frame = frame_save
