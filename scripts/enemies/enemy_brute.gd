extends "res://scripts/enemy.gd"
# Brute — tanky, slow, high health. Drops heavier loot later (hook in outerworld.gd).
# PLACEHOLDER mesh: uses parent enemy mesh with tint; replace material when art ready.

func _ready() -> void:
	health = 90
	speed = 2.6
	acceleration = 6.0
	enemy_kind = "enemy_brute"
	attack_damage = 22
	attack_cooldown = 1.4
	loot_rolls = 1
	money_min = 8
	money_max = 16
	# call parent ready for nav setup
	super._ready()
	# tint if mesh exists (best-effort)
