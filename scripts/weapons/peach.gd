extends Item
class_name Peach

@export var texture = preload("res://textures/peach.png")
@export var name = "Peach"

@export var damage := 22
@export var cooldown := 0.6
const FUZZ_SCENE := preload("res://objects/projectiles/peach_fuzz.tscn")
func _init():
	description = "Fuzzy peach — bouncing fuzz balls."
	left_click_desc = "Left Click: fuzz — 1 bounce"
	right_click_desc = "Right Click: heavy fuzz — 3 bounces, heavy"



func _leftclick(playerobj):
	var b = FUZZ_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.bounces = 1
	Engine.get_main_loop().root.add_child(b)
	cooldown = 0.6

func _rightclick(playerobj):
	var b = FUZZ_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = int(damage * 1.6)
	b.bounces = 3
	b.heavy = true
	Engine.get_main_loop().root.add_child(b)
	cooldown = 1.4
