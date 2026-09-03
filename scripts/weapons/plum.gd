extends Item
class_name Plum

@export var texture = preload("res://textures/plum.png")
@export var name = "Plum"

@export var damage := 12
@export var cooldown := 0.35
const BLOB_SCENE := preload("res://objects/projectiles/plum_blob.tscn")
func _init():
	description = "Sticky plum blobs."
	left_click_desc = "Left Click: plum blob"
	right_click_desc = "Right Click: 2 sticky blobs"



func _leftclick(playerobj):
	var b = BLOB_SCENE.instantiate()
	b.position = playerobj.position
	b.rotation.x = playerobj.player_head.rotation.x
	b.rotation.y = playerobj.rotation.y
	b.damage = damage
	Engine.get_main_loop().root.add_child(b)
	cooldown = 0.35

func _rightclick(playerobj):
	for i in 2:
		var b = BLOB_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.y = playerobj.rotation.y + (0.08 if i==0 else -0.08)
		b.rotation.x = playerobj.player_head.rotation.x
		b.damage = damage
		b.sticky = true
		Engine.get_main_loop().root.add_child(b)
	cooldown = 0.8
