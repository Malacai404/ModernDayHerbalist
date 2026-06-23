extends VBoxContainer

const ITEM_ADDITION = preload("uid://bnhx8qp4uiaqv")

var items_collected = [""]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _item_collected(itemname: String, num: int):
	var item_new = ITEM_ADDITION.instantiate()
	item_new.text = str("[font_size=30px]+" + str(num) + "  " + itemname + "[/font_size]")
	add_child(item_new)
