extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func activate(playerobj):
	playerobj._phone_active()

func get_hover_text():
	return "[font_size=20px]Press E to call![/font_size]"
	
