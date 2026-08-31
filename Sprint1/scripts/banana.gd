extends Item
class_name Banana
var tree = Engine.get_main_loop() as SceneTree
@export var texture = preload("res://textures/banana.png")
@export var name = "Banana"
@export var damage := 20
@export var cooldown := 0.5
const boomerang = preload("res://objects/projectiles/boomerang.tscn")


# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = boomerang.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.speed = 20
	bullet.rate_of_change = 20
	tree.root.add_child(bullet)
	cooldown = 1
func _rightclick(playerobj):
	var bullet = boomerang.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.speed = 40
	bullet.rate_of_change = 40
	tree.root.add_child(bullet)
	cooldown = 1
