extends Item
class_name Banana

@export var texture = preload("res://textures/banana.png")
@export var name = "Banana"
@export var damage := 20
@export var cooldown := 0.5
const boomerang = preload("res://objects/projectiles/boomerang.tscn")
func _init():
	description = "A curved boomerang fruit that returns."
	left_click_desc = "Left Click: boomerang (slow return)"
	right_click_desc = "Right Click: boomerang (fast return)"





# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = boomerang.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.speed = 20
	bullet.rate_of_change = 20
	Engine.get_main_loop().root.add_child(bullet)
	cooldown = 1
func _rightclick(playerobj):
	var bullet = boomerang.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.speed = 40
	bullet.rate_of_change = 40
	Engine.get_main_loop().root.add_child(bullet)
	cooldown = 1
