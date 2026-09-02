extends VBoxContainer

const ITEM_ADDITION = preload("res://objects/item_addition.tscn")


var items_collected = [""]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _item_collected(itemname: String, num: int, color := Color(1,1,1,1)):
	var item_new = ITEM_ADDITION.instantiate()
	item_new.text = str("[font_size=30px]+" + str(num) + "  " + itemname + "[/font_size]")
	# apply optional color override (uses the same theme override used by the tscn)
	if color != null:
		item_new.set("theme_override_colors/default_color", color)
	add_child(item_new)
