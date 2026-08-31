extends Item
class_name Mango
@export var texture = preload("res://textures/mango.png")
@export var name = "Mango"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 28
@export var cooldown := 0.7
const SLICE_SCENE := preload("res://objects/projectiles/mango_slice.tscn")

func _leftclick(playerobj):
	var b = SLICE_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.pierce = true
	tree.root.add_child(b)
	cooldown = 0.7

func _rightclick(playerobj):
	var b = SLICE_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = int(damage * 0.6)
	b.pierce = true
	b.arc = true
	tree.root.add_child(b)
	cooldown = 1.1
