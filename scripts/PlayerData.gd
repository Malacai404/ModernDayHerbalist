extends Node

const SAVE_PATH := "user://playerdata_save.cfg"

var selected_slot:= 0

var inventory = [
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0},
	{"item": null, "count": 0}
]
var seedpouch = [
	{"itemid": 0, "count": 5},
	{"itemid": 1, "count": 5},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0},
	{"itemid": -1, "count": 0}
]

func _ready() -> void:
	load_state()

func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "selected_slot", selected_slot)
	config.set_value("player", "inventory", _serialize_inventory(inventory))
	config.set_value("player", "seedpouch", seedpouch)
	config.save(SAVE_PATH)

func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	selected_slot = int(config.get_value("player", "selected_slot", 0))
	var saved_inventory = config.get_value("player", "inventory", null)
	if saved_inventory is Array:
		inventory = _deserialize_inventory(saved_inventory)
	var saved_seedpouch = config.get_value("player", "seedpouch", seedpouch)
	if saved_seedpouch is Array:
		seedpouch = saved_seedpouch

func _process(delta: float) -> void:
	pass

# --- serialization helpers: store plant ids, not Resources (ConfigFile can't store Resources) ---
func _item_to_plant_id(item: Variant) -> int:
	if item == null:
		return -1
	if item is int:
		return int(item) if int(item) >= 0 and int(item) < 16 else -1
	if item is Dictionary:
		if item.has("plant_id"):
			return int(item["plant_id"])
		return -1
	if not (item is Resource):
		return -1
	var sd = get_node_or_null("/root/SeedData")
	if sd == null or not ("plants" in sd):
		return -1
	# match by script identity first (most reliable)
	var item_script: Script = (item as Resource).get_script() as Script
	for i in range(sd.plants.size()):
		var cand = sd.plants[i]
		if cand is Script and item_script == cand:
			return i
	# fallback: match by display name
	var dname: String = ""
	if (item as Resource).has_method("get_display_name"):
		dname = str((item as Resource).call("get_display_name"))
	else:
		dname = str(item.get("name") if (item as Resource).get("name") != null else (item as Resource).get("item_name"))
	for i in range(sd.plants.size()):
		var cand2 = sd.plants[i]
		var probe = null
		if cand2 is Script:
			probe = (cand2 as Script).new()
		else:
			probe = cand2
		var cand_name: String = ""
		if probe and probe.has_method("get_display_name"):
			cand_name = str(probe.call("get_display_name"))
		elif probe:
			cand_name = str(probe.get("name") if probe.get("name") != null else probe.get("item_name"))
		if cand_name == dname and dname != "":
			return i
	return -1

func _plant_id_to_item(pid: int) -> Variant:
	if pid < 0:
		return null
	var sd = get_node_or_null("/root/SeedData")
	if sd == null or not sd.has_method("_get_plant"):
		return null
	if pid < 0 or pid >= sd.plants.size():
		return null
	return sd._get_plant(pid)

func _serialize_inventory(inv: Array) -> Array:
	var out: Array = []
	for slot in inv:
		if not (slot is Dictionary):
			out.append({"plant_id": -1, "count": 0})
			continue
		var pid: int = -1
		var cnt: int = int(slot.get("count", 0))
		if slot.has("plant_id"):
			pid = int(slot["plant_id"])
		elif slot.has("item"):
			pid = _item_to_plant_id(slot["item"])
		# also handle new-format where item is already plant_id int stored under "item"
		if pid < 0 or pid >= 16:
			pid = -1
			cnt = 0
		out.append({"plant_id": pid, "count": cnt})
	return out

func _deserialize_inventory(data: Array) -> Array:
	var out: Array = []
	for entry in data:
		if not (entry is Dictionary):
			out.append({"item": null, "count": 0})
			continue
		var pid: int = -1
		var cnt: int = 0
		if entry.has("plant_id"):
			pid = int(entry.get("plant_id", -1))
			cnt = int(entry.get("count", 0))
		elif entry.has("item"):
			# legacy save: {"item": Resource|null, "count": int}
			var raw_item = entry.get("item")
			cnt = int(entry.get("count", 0))
			if raw_item == null:
				pid = -1
			elif raw_item is Resource:
				pid = _item_to_plant_id(raw_item)
			elif raw_item is int:
				pid = int(raw_item)
			elif raw_item is Dictionary and raw_item.has("plant_id"):
				pid = int(raw_item["plant_id"])
			else:
				# stringified Resource from broken ConfigFile -> treat as empty
				pid = -1
				cnt = 0
		else:
			pid = -1
		var item = _plant_id_to_item(pid)
		out.append({"item": item, "count": cnt if pid >= 0 else 0})
	# ensure size 5
	while out.size() < 5:
		out.append({"item": null, "count": 0})
	if out.size() > 5:
		out = out.slice(0, 5)
	return out

func normalize_inventory_runtime(inv: Array) -> Array:
	# ensure runtime format {"item": Resource|null, "count": int}
	if inv.is_empty():
		return inventory.duplicate(true)
	# detect if already runtime format
	var needs_convert := false
	for s in inv:
		if s is Dictionary and s.has("plant_id"):
			needs_convert = true
			break
	if needs_convert:
		return _deserialize_inventory(inv)
	# also handle legacy where item might be int/plant_id
	for s in inv:
		if s is Dictionary and s.has("item") and s["item"] is int:
			needs_convert = true
			break
	if needs_convert:
		return _deserialize_inventory(inv)
	return inv
