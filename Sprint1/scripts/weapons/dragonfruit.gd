extends Item
class_name Dragonfruit
@export var texture = preload("res://textures/pineapple.png")
@export var name = "Dragonfruit"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 16
@export var cooldown := 0.65
const ORB_SCENE := preload("res://objects/projectiles/dragon_orb.tscn")

func _leftclick(playerobj):
	var b = ORB_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.homing_strength = 2.0
	tree.root.add_child(b)
	cooldown = 0.65

func _rightclick(playerobj):
	for i in 3:
		var b = ORB_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.x = playerobj.player_head.rotation.x + randf_range(-0.07, 0.07)
		b.rotation.y = playerobj.rotation.y + randf_range(-0.1, 0.1)
		b.damage = 12
		b.homing_strength = 3.5
		tree.root.add_child(b)
	cooldown = 2.2
