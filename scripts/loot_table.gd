extends Resource
class_name LootTable

@export var entries: Array[Dictionary] = []

static func default_for(enemy_kind: String) -> LootTable:
	var t = LootTable.new()
	match enemy_kind:
		"enemy":
			t.entries.assign([
				{"kind":"money","id":0,"min":2,"max":6,"weight":10.0},
				{"kind":"seed","id":0,"min":1,"max":1,"weight":2.0},
				{"kind":"seed","id":1,"min":1,"max":1,"weight":1.0},
			])
		"enemy_brute":
			t.entries.assign([
				{"kind":"money","id":0,"min":8,"max":16,"weight":10.0},
				{"kind":"seed","id":5,"min":1,"max":2,"weight":4.0},
				{"kind":"seed","id":13,"min":1,"max":1,"weight":2.0},
				{"kind":"fruit","id":13,"min":1,"max":1,"weight":1.0},
			])
		"enemy_sprinter":
			t.entries.assign([
				{"kind":"money","id":0,"min":1,"max":3,"weight":10.0},
				{"kind":"seed","id":6,"min":1,"max":2,"weight":3.0},
				{"kind":"seed","id":12,"min":1,"max":1,"weight":2.0},
			])
		"enemy_spitter":
			t.entries.assign([
				{"kind":"money","id":0,"min":4,"max":9,"weight":10.0},
				{"kind":"seed","id":14,"min":1,"max":1,"weight":2.5},
				{"kind":"seed","id":15,"min":1,"max":1,"weight":1.5},
				{"kind":"seed","id":8,"min":1,"max":1,"weight":1.5},
			])
		_:
			t.entries.assign([
				{"kind":"money","id":0,"min":1,"max":4,"weight":10.0},
			])
	return t

func roll_count() -> int:
	return 1

func pick_one(rng: RandomNumberGenerator) -> Dictionary:
	if entries.is_empty():
		return {}
	var total := 0.0
	for e in entries:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		total += float(e.get("weight", 1.0))
	if total <= 0.0:
		var last0 = entries[0].duplicate() if typeof(entries[0]) == TYPE_DICTIONARY else {}
		if not last0.is_empty():
			last0["rolled"] = int(last0.get("min", 1))
		return last0
	var r = rng.randf() * total
	var acc := 0.0
	for e in entries:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		acc += float(e.get("weight", 1.0))
		if r <= acc:
			var out = e.duplicate()
			var mn = int(e.get("min", 1))
			var mx = int(e.get("max", 1))
			if mx < mn:
				mx = mn
			out["rolled"] = rng.randi_range(mn, mx)
			return out
	for i in range(entries.size() - 1, -1, -1):
		if typeof(entries[i]) == TYPE_DICTIONARY:
			var last = entries[i].duplicate()
			last["rolled"] = int(last.get("min", 1))
			return last
	return {}
