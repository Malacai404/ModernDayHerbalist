extends Item
class_name Watermelon

@export var texture = preload("res://textures/watermelon_fruit.png")
@export var name = "Watermelon"
@export var damage := 10
@export var cooldown := 0.1
const bullet_obj = preload("uid://capyx5500a4y4")
func _init():
	description = "Juicy melon — chance to refund on fire."
	left_click_desc = "Left Click: rapid melon shot (chance to not consume)"
	right_click_desc = "Right Click: —"






# Called when the node enters the scene tree for the first time.
func _leftclick(playerobj):
	var bullet = bullet_obj.instantiate()
	bullet.position = playerobj.position
	bullet.rotation.x = playerobj.player_head.rotation.x
	bullet.rotation.y = playerobj.rotation.y
	bullet.damage = 10
	var rand = randi_range(1,4)
	if rand != 1:
		print("New bullet")
		var slot = playerobj.inventory[playerobj.selected_slot]
		if slot["item"] != null:
			slot["item"]._rightclick(self)
			slot["count"] += 1
			playerobj.attack_cooldown = slot["item"].cooldown
			playerobj.attack_cooldown_save = slot["item"].cooldown
			if slot["count"] <= 0:
				slot["item"] = null
				slot["count"] = 0
			playerobj._handle_inventory()
	Engine.get_main_loop().root.add_child(bullet)
	cooldown = 0.2
func _rightclick(playerobj):
	pass
	cooldown = 0.4
