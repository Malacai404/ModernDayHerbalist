extends Item
class_name Passionfruit
@export var texture = preload("res://textures/Grape.png")
@export var name = "Passionfruit"
var tree = Engine.get_main_loop() as SceneTree
@export var damage := 20
@export var cooldown := 0.8
const PULP_SCENE := preload("res://objects/projectiles/passion_pulp.tscn")
const PUDDLE_SCENE := preload("res://objects/projectiles/passion_puddle.tscn")

func _leftclick(playerobj):
	var b = PULP_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	tree.root.add_child(b)
	cooldown = 0.8

func _rightclick(playerobj):
	var b = PULP_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = int(damage * 0.7)
	# tell pulp to spawn puddle on hit — handled inside pulp script via flag
	b.spawn_puddle = true
	b.puddle_scene = PUDDLE_SCENE
	tree.root.add_child(b)
	cooldown = 1.6
