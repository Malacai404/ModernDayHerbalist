extends "res://scripts/enemy.gd"
# Brute — tanky, slow, high health. Drops heavier loot later (hook in outerworld.gd).
# PLACEHOLDER mesh: uses parent enemy mesh with tint; replace material when art ready.

func _ready() -> void:
	health = 90
	speed = 2.6
	acceleration = 6.0
	enemy_kind = "enemy_brute"
	loot_rolls = 1
	money_min = 8
	money_max = 16
	# call parent ready for nav setup
	super._ready()
	# tint if mesh exists (best-effort)
	var mi = get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mi and mi.mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.72, 0.2, 0.2)
		mi.material_override = mat
