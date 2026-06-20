extends Control

@onready var icon = $TextureRect
@onready var item_name = $Label
@onready var count = $CountLabel

func select():
	modulate = Color(1, 1, 0.5)

func deselect():
	modulate = Color(1, 1, 1)

func set_item(item, amount):
	if item == null:
		icon.texture = null
		item_name.text = ""
		count.text = ""
		return
	icon.texture = item.texture
	item_name.text = item.name
	count.text = "" + str(amount)
