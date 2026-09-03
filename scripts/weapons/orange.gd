extends Item
class_name Orange

@export var texture = preload("res://textures/orange.png")
@export var name = "Orange"

@export var damage := 18
@export var cooldown := 0.55
const SEGMENT_SCENE := preload("res://objects/projectiles/orange_segment.tscn")
func _init():
	description = "Segmented orange — splits on impact."
	left_click_desc = "Left Click: orange segment"
	right_click_desc = "Right Click: splitting segment"



func _leftclick(playerobj):
	var b = SEGMENT_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	b.split = false
	Engine.get_main_loop().root.add_child(b)
	cooldown = 0.55

func _rightclick(playerobj):
	var b = SEGMENT_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = int(damage * 0.7)
	b.split = true
	Engine.get_main_loop().root.add_child(b)
	cooldown = 1.0
