extends Item
class_name Kiwi

@export var texture = preload("res://textures/kiwifruit.png")
@export var name = "Kiwi"

@export var damage := 14
@export var cooldown := 0.5
const SHARD_SCENE := preload("res://objects/projectiles/kiwi_shard.tscn")
const CLOUD_SCENE := preload("res://objects/projectiles/kiwi_cloud.tscn")
func _init():
	description = "Fuzzy kiwi — shards and lingering cloud."
	left_click_desc = "Left Click: 3 kiwi shards"
	right_click_desc = "Right Click: toxic kiwi cloud (area denial)"



func _leftclick(playerobj):
	for i in 3:
		var b = SHARD_SCENE.instantiate()
		b.position = playerobj.position
		b.rotation.x = playerobj.player_head.rotation.x + randf_range(-0.04, 0.04)
		b.rotation.y = playerobj.rotation.y + randf_range(-0.06, 0.06)
		b.damage = damage
		Engine.get_main_loop().root.add_child(b)
	cooldown = 0.5

func _rightclick(playerobj):
	var c = CLOUD_SCENE.instantiate()
	# spawn ~8m ahead of camera
	var origin = playerobj.player_head.global_position
	var dir = -playerobj.player_head.global_transform.basis.z.normalized()
	c.global_position = origin + dir * 8.0
	c.damage = 8
	Engine.get_main_loop().root.add_child(c)
	cooldown = 2.0
