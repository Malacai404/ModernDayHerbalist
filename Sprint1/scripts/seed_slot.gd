extends Control

@onready var icon = $SeedIcon
@onready var item_name = $SeedName
@onready var count = $SeedCount
@onready var seedid = -1
@onready var count_seed = 0
@onready var seed_menu = $"../../../.."


func select():
	modulate = Color(1, 1, 0.5)

func deselect():
	modulate = Color(1, 1, 1)

func _reload():
	if seedid != -1:
		set_item(SeedData._get_seed(seedid), count_seed)
	else:
		set_item(null, 0)

func set_item(item, amount):
	if item == null:
		icon.texture = null
		item_name.text = ""
		count.text = ""
		return
	icon.texture = item.texture
	item_name.text = item.name
	count.text = "" + str(amount)



func _on_button_pressed():
	seed_menu._set_pot(self)
