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
	icon.texture = (item.get_icon() if item.has_method("get_icon") else (item.get("texture") if item.get("texture") != null else item.get("icon")))
	item_name.text = (item.get_display_name() if item.has_method("get_display_name") else (str(item.get("name")) if str(item.get("name")) not in ["", "Null", "<null>"] else str(item.get("item_name"))))
	count.text = "" + str(amount)
