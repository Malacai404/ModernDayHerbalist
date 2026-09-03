extends Item
class_name Dragonfruit

@export var texture = preload("res://textures/dragonfruit.png")
@export var name = "Dragonfruit"

@export var damage := 16
@export var cooldown := 0.65
const ORB_SCENE := preload("res://objects/projectiles/dragon_orb.tscn")
func _init():
	description = "Exotic homing orbs."
	left_click_desc = "Left Click: homing dragon orb"
	right_click_desc = "Right Click: 3 homing orbs (strong homing)"



func _leftclick(playerobj):
	var b = ORB_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.homing_strength = 2.0
	Engine.get_main_loop().root.add_child(b)
	cooldown = 0.65

func _rightclick(playerobj):
	for i in 3:
		var b = ORB_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.x = playerobj.player_head.rotation.x + randf_range(-0.07, 0.07)
		b.rotation.y = playerobj.rotation.y + randf_range(-0.1, 0.1)
		b.damage = 12
		b.homing_strength = 3.5
		Engine.get_main_loop().root.add_child(b)
	cooldown = 2.2
