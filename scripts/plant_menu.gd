extends CanvasLayer
class_name PlantMenu

# PlantMenu.tscn scene has a typo: PlantTextue. Accept both.
var plant_name_label: Label = null
var desc_label: Label = null
var plant_tex: TextureRect = null
var seed_tex: TextureRect = null
var title_label: Label = null

# SeedData.plants[i] <-> SeedData.seeds[i] correspondence
var _seed_texture_cache: Dictionary = {}
var _index_cache: Dictionary = {}
var _visible_layer: int = 10

func _ready() -> void:
	_ensure_nodes_bound()
	_configure_ui()
	layer = _visible_layer
	visible = false
	await ready
	_ensure_nodes_bound()

func _resolve_item(item) -> Resource:
	# Accept item directly, int plant_id, or Dictionary from legacy save
	if item == null:
		return null
	if item is Resource:
		return item as Resource
	if item is int:
		var pid := int(item)
		if pid < 0 or pid >= SeedData.plants.size():
			return null
		return SeedData._get_plant(pid) as Resource
	if item is Dictionary:
		if item.has("plant_id"):
			var p2: int = int(item.get("plant_id", -1))
			if p2 >= 0 and p2 < SeedData.plants.size():
				return SeedData._get_plant(p2) as Resource
			return null
		var probe = item.get("item", item.get("name", item.get("item_name", null)))
		if probe is Resource:
			return probe as Resource
		if probe is int and int(probe) >= 0 and int(probe) < SeedData.plants.size():
			return SeedData._get_plant(int(probe)) as Resource
	return null

func _ensure_nodes_bound() -> void:
	if plant_name_label == null: plant_name_label = get_node_or_null("PlantName") as Label
	if desc_label == null: desc_label = get_node_or_null("PlantName2") as Label
	if plant_tex == null: plant_tex = (get_node_or_null("PlantTextue") as TextureRect) if get_node_or_null("PlantTextue") else (get_node_or_null("PlantTexture") as TextureRect)
	if seed_tex == null: seed_tex = get_node_or_null("PlantSeedTexture") as TextureRect
	if title_label == null: title_label = get_node_or_null("PlantMenuTitle") as Label
	if plant_name_label == null or desc_label == null:
		push_warning("[PlantMenu] labels not found; check scene paths. PlantName=%s PlantName2=%s" % [str(plant_name_label != null), str(desc_label != null)])

func _configure_ui() -> void:
	if plant_tex:
		plant_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plant_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		plant_tex.custom_minimum_size = Vector2(128, 128)
	if seed_tex:
		seed_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		seed_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		seed_tex.custom_minimum_size = Vector2(128, 128)
	if plant_name_label:
		plant_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		plant_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if desc_label:
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func show_for_item(item) -> void:
	_ensure_nodes_bound()
	var resolved: Resource = _resolve_item(item)
	if resolved == null:
		if item is Dictionary:
			var dname: String = str(item.get("item_name", item.get("name", "Unknown")))
			if plant_name_label: plant_name_label.text = dname + " (needs replant)"
			if desc_label: desc_label.text = "Old save data couldn't store plants. Harvest a new fruit to fill this slot."
			if plant_tex: plant_tex.texture = null
			if seed_tex: seed_tex.texture = null
			visible = true
			return
		if item == null:
			return
		return
	item = resolved
	var display_name: String = _get_display_name(item)
	var tex: Texture2D = _get_icon(item)
	var description: String = _get_str(item, "description")
	var left_desc: String = _get_str(item, "left_click_desc")
	var right_desc: String = _get_str(item, "right_click_desc")
	if left_desc == "" and display_name != "":
		left_desc = "Left Click: fires %s" % display_name
	if right_desc == "" and display_name != "":
		right_desc = "Right Click: alternate %s attack" % display_name
	if plant_name_label: plant_name_label.text = display_name if display_name != "" else "Unknown Plant"
	if plant_tex: plant_tex.texture = tex
	var seed_t: Texture2D = _find_seed_texture_for_item(item, display_name)
	if seed_tex: seed_tex.texture = seed_t
	var stats := _build_stats(item, display_name)
	var parts: Array[String] = []
	if description != "":
		parts.append(description)
	else:
		parts.append("No description yet.")
	parts.append(left_desc)
	parts.append(right_desc)
	if stats != "":
		parts.append(stats)
	var joined: String = "\n\n".join(parts)
	if desc_label:
		desc_label.text = joined
	if plant_name_label: plant_name_label.queue_redraw()
	if desc_label: desc_label.queue_redraw()
	visible = true
	layer = 20

func _get_display_name(item: Resource) -> String:
	if item.has_method("get_display_name"):
		var v = str(item.get_display_name())
		if v != "" and v != "<null>": return v
	for key in ["name", "item_name", "resource_name"]:
		var val = item.get(key)
		if val != null and str(val) != "" and str(val) != "<null>":
			return str(val)
	# Fallback: script class name
	var sc: Script = item.get_script() as Script
	if sc:
		return sc.get_global_name()
	return "Unknown"

func _get_icon(item: Resource) -> Texture2D:
	if item.has_method("get_icon"):
		var ic = item.get_icon()
		if ic is Texture2D: return ic
	for key in ["texture", "icon"]:
		var v = item.get(key)
		if v is Texture2D: return v
	return null

func _get_str(item: Resource, prop: String) -> String:
	var v = item.get(prop)
	if v == null: return ""
	var s := str(v).strip_edges()
	if s == "<null>": return ""
	return s

func _build_stats(item: Resource, display_name: String) -> String:
	var idx := _find_index_for_item(item, display_name)
	var lines: Array[String] = []
	var dmg = item.get("damage")
	if dmg != null: lines.append("Damage: %s" % str(dmg))
	var cd = item.get("cooldown")
	if cd != null: lines.append("Cooldown: %ss" % str(cd))
	if idx >= 0:
		if idx < SeedData.seeds.size():
			var seed_res = SeedData.seeds[idx]
			if seed_res:
				var gt = seed_res.get("growthtime")
				if gt != null: lines.append("Growth: %s day(s)" % str(gt))
		# prices from ShopData (shared)
		if ShopData:
			if idx < ShopData.fruit_prices.size():
				lines.append("Sell: $%d" % ShopData.get_plant_price(idx))
			if idx < ShopData.seed_prices.size():
				lines.append("Seed price: $%d" % ShopData.get_seed_price(idx))
		lines.append("ID: %d" % idx)
	if lines.is_empty(): return ""
	return " | ".join(lines)

func _find_index_for_item(item: Resource, display_name: String) -> int:
	if display_name in _index_cache: return int(_index_cache[display_name])
	if item.get_script() != null:
		var s: Script = item.get_script() as Script
		if s and s in _index_cache: return int(_index_cache[str(s)])
	var idx := -1
	for i in range(SeedData.plants.size()):
		var cand = SeedData.plants[i]
		if cand is Script and item.get_script() == cand:
			idx = i
			break
		var probe = null
		if cand is Script:
			probe = (cand as Script).new()
		else:
			probe = cand
		var cand_name := ""
		if probe and probe.has_method("get_display_name"):
			cand_name = str(probe.get_display_name())
		elif probe:
			cand_name = str(probe.get("name") if probe.get("name") != null else probe.get("item_name"))
		if cand_name == display_name and display_name != "":
			idx = i
			break
	if idx >= 0:
		_index_cache[display_name] = idx
	return idx

func _find_seed_texture_for_item(item: Resource, display_name: String) -> Texture2D:
	var idx := _find_index_for_item(item, display_name)
	if idx < 0 or idx >= SeedData.seeds.size(): return null
	if idx in _seed_texture_cache:
		return _seed_texture_cache[idx] as Texture2D
	var seed_res = SeedData.seeds[idx]
	if seed_res == null: return null
	var st = seed_res.get("texture")
	if st == null: st = seed_res.get("icon")
	if st is Texture2D:
		_seed_texture_cache[idx] = st
		return st
	return null

func hide_menu() -> void:
	visible = false
	layer = _visible_layer

func toggle_for_item(item) -> void:
	# Ensure nodes are bound even if called before _ready (player _ready can fire before menu _ready)
	_ensure_nodes_bound()
	if visible:
		hide_menu()
	else:
		show_for_item(item)
