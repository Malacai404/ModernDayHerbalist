extends Item
class_name Coconut

@export var texture = preload("res://textures/coconut.png")
@export var name = "Coconut"

@export var damage := 45
@export var cooldown := 1.2
const BALL_SCENE := preload("res://objects/projectiles/coconut_ball.tscn")
func _init():
	description = "Heavy coconut — bounces or slams."
	left_click_desc = "Left Click: coconut ball — 2 bounces"
	right_click_desc = "Right Click: slam — no bounce, heavy damage"



func _leftclick(playerobj):
	var b = BALL_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.bounces = 2
	Engine.get_main_loop().root.add_child(b)
	cooldown = 1.2

func _rightclick(playerobj):
	var b = BALL_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x - 0.25
	b.rotation.y = playerobj.rotation.y
	b.damage = int(damage * 1.3)
	b.bounces = 0
	b.slam = true
	Engine.get_main_loop().root.add_child(b)
	cooldown = 1.8
