extends Item
class_name Strawberry
@export var texture = preload("res://textures/strawberry.png")
@export var name = "Strawberry"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 10
@export var cooldown := 0.22
const DART_SCENE := preload("res://objects/projectiles/strawberry_dart.tscn")

func _leftclick(playerobj):
	var b = DART_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	tree.root.add_child(b)
	cooldown = 0.22

func _rightclick(playerobj):
	for i in 6:
		var b = DART_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.x = playerobj.player_head.rotation.x + randf_range(-0.06, 0.06)
		b.rotation.y = playerobj.rotation.y + randf_range(-0.12, 0.12)
		b.damage = 7
		tree.root.add_child(b)
	cooldown = 0.9
