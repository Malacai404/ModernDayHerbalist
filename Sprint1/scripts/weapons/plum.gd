extends Item
class_name Plum
@export var texture = preload("res://textures/Grape.png")
@export var name = "Plum"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 12
@export var cooldown := 0.35
const BLOB_SCENE := preload("res://objects/projectiles/plum_blob.tscn")

func _leftclick(playerobj):
	var b = BLOB_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	tree.root.add_child(b)
	cooldown = 0.35

func _rightclick(playerobj):
	for i in 2:
		var b = BLOB_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.y = playerobj.rotation.y + (0.08 if i==0 else -0.08)
		b.rotation.x = playerobj.player_head.rotation.x
		b.damage = damage
		b.sticky = true
		tree.root.add_child(b)
	cooldown = 0.8
