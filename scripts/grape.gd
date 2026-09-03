extends Item
class_name Grape

@export var texture = preload("res://textures/Grape.png")
@export var name = "Grape"
@export var damage := 20
@export var cooldown := 0.5
const SCATTERSHOT = preload("uid://cei5s5chmm0f5")
func _init():
	description = "A burst-firing vine fruit."
	left_click_desc = "Left Click: scattershot — single explosive volley"
	right_click_desc = "Right Click: mega volley — 15 projectiles at once"






# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = SCATTERSHOT.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.damage = 15
	bullet.largescatter = false
	Engine.get_main_loop().root.add_child(bullet)
	cooldown = 0.5
func _rightclick(playerobj):
	for i in range(15):
		var bullet = SCATTERSHOT.instantiate()
		bullet.position = playerobj.position
		bullet.rotation.x = playerobj.player_head.rotation.x
		bullet.rotation.y = playerobj.rotation.y
		bullet.largescatter = true
		bullet.damage = 10
		Engine.get_main_loop().root.add_child(bullet)
	cooldown = 4
