extends Node

# 16 seeds (0-5 original, 6-15 new) — PLACEHOLDER textures until art lands
@export var seeds = [
	preload("res://scripts/seeds/grape_seed.tres"),
	preload("res://scripts/seeds/apple_seed.tres"),
	preload("res://scripts/seeds/banana_seed.tres"),
	preload("res://scripts/seeds/lemon_seed.tres"), # lemon
	preload("res://scripts/seeds/pineapple_seed.tres"), # pineapple
	preload("res://scripts/seeds/watermelon_seed.tres"), # watermelon
	preload("res://scripts/seeds/cherry_seed.tres"),
	preload("res://scripts/seeds/mango_seed.tres"),
	preload("res://scripts/seeds/kiwi_seed.tres"),
	preload("res://scripts/seeds/peach_seed.tres"),
	preload("res://scripts/seeds/plum_seed.tres"),
	preload("res://scripts/seeds/orange_seed.tres"),
	preload("res://scripts/seeds/strawberry_seed.tres"),
	preload("res://scripts/seeds/coconut_seed.tres"),
	preload("res://scripts/seeds/dragonfruit_seed.tres"),
	preload("res://scripts/seeds/passionfruit_seed.tres"),
]

@export var plants = [
	preload("res://scripts/grape.gd"),
	preload("res://scripts/apple.gd"),
	preload("res://scripts/banana.gd"),
	preload("res://scripts/lemon.gd"),
	preload("res://scripts/pineapple.gd"),
	preload("res://scripts/watermelon.gd"),
	preload("res://scripts/weapons/cherry.gd"),
	preload("res://scripts/weapons/mango.gd"),
	preload("res://scripts/weapons/kiwi.gd"),
	preload("res://scripts/weapons/peach.gd"),
	preload("res://scripts/weapons/plum.gd"),
	preload("res://scripts/weapons/orange.gd"),
	preload("res://scripts/weapons/strawberry.gd"),
	preload("res://scripts/weapons/coconut.gd"),
	preload("res://scripts/weapons/dragonfruit.gd"),
	preload("res://scripts/weapons/passionfruit.gd"),
]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_seed(seedid: int):
	return seeds[seedid]
	
func _get_plant(plantid: int):
	return plants[plantid].new()
