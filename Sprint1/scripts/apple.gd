extends Item
class_name apple
var tree = Engine.get_main_loop() as SceneTree
@export var texture = preload("res://textures/apple.png")
@export var name = "Apple"
@export var damage := 20
@export var cooldown := 0.5
const bullet_scene = preload("res://objects/explosive.tscn")



# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = bullet_scene.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.damage = 20
	
	bullet.fall = true
	print("Bullet_fall " + str(bullet.fall))
	tree.root.add_child(bullet)
	cooldown = 1
func _rightclick(playerobj):
	var bullet = bullet_scene.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.damage = 40
	bullet.fall = false
	print("Bullet_fall " + str(bullet.fall))
	tree.root.add_child(bullet)
	cooldown = 1
