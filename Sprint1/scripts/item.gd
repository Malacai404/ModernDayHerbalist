extends Resource
class_name Item

@export var item_name: String = ""
@export var icon: Texture2D

# Helpers so call sites work regardless of whether instance uses item_name/icon or name/texture
func get_display_name() -> String:
	var v = get("name")
	if v != null and str(v) != "":
		return str(v)
	v = get("item_name")
	return str(v) if v != null else ""
func get_icon() -> Texture2D:
	var v = get("texture")
	if v != null:
		return v as Texture2D
	v = get("icon")
	return v as Texture2D

func _leftclick(playerobj): pass
func _rightclick(playerobj): pass
