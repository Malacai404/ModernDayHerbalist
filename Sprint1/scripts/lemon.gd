extends Item
class_name Lemon
var tree = Engine.get_main_loop() as SceneTree
@export var texture = preload("res://textures/lemon.png")
@export var name = "Lemon"
@export var damage := 20
@export var cooldown := 0.5
const SCATTERSHOT = preload("uid://cei5s5chmm0f5")



# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = SCATTERSHOT.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.damage = 15
	bullet.largescatter = false
	tree.root.add_child(bullet)
	cooldown = 0.5
func _rightclick(playerobj):
	for i in range(15):
		var bullet = SCATTERSHOT.instantiate()
		bullet.position = playerobj.position
		bullet.rotation.x = playerobj.player_head.rotation.x
		bullet.rotation.y = playerobj.rotation.y
		bullet.largescatter = true
		bullet.damage = 10
		tree.root.add_child(bullet)
	cooldown = 4
