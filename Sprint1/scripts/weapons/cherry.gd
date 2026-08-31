extends Item
class_name Cherry
@export var texture = preload("res://textures/cherry.png")
@export var name = "Cherry"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 8
@export var cooldown := 0.15
const PIT_SCENE := preload("res://objects/projectiles/cherry_pit.tscn")

func _leftclick(playerobj):
	var b = PIT_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	tree.root.add_child(b)
	cooldown = 0.15

func _rightclick(playerobj):
	for i in 5:
		var b = PIT_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.x = playerobj.player_head.rotation.x + randf_range(-0.05, 0.05)
		b.rotation.y = playerobj.rotation.y + randf_range(-0.08, 0.08)
		b.damage = 6
		b.speed = 20.0
		tree.root.add_child(b)
	cooldown = 0.45
