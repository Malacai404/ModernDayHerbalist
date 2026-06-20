extends Area3D

var grape = Grape.new()

# Called when the node enters the scene tree for the first time.
func get_hover_text():
	return "[font_size=20px]Press E to collect a grape![/font_size]"
	
func activate(player):
	player._pickup_item(grape, 1)
