extends Item
class_name Passionfruit

@export var texture = preload("res://textures/passionfruit.png")
@export var name = "Passionfruit"

@export var damage := 20
@export var cooldown := 0.8
const PULP_SCENE := preload("res://objects/projectiles/passion_pulp.tscn")
const PUDDLE_SCENE := preload("res://objects/projectiles/passion_puddle.tscn")
func _init():
	description = "Tangy pulp that leaves a lingering puddle."
	left_click_desc = "Left Click: passion pulp projectile"
	right_click_desc = "Right Click: pulp that spawns damage puddle on hit"



func _leftclick(playerobj):
	var b = PULP_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	Engine.get_main_loop().root.add_child(b)
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
	Engine.get_main_loop().root.add_child(b)
	cooldown = 1.6
