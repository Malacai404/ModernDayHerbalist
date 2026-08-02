extends Node

@export var seeds = [preload("res://scripts/seeds/grape_seed.tres"),preload("res://scripts/seeds/apple_seed.tres"), preload("res://scripts/seeds/banana_seed.tres"), preload("uid://b47nqw3us0lsk"), preload("uid://dio5lel8oxjrk"), preload("uid://b60imja7agp5k")]

@export var plants = [preload("res://scripts/grape.gd"), preload("res://scripts/apple.gd"), preload("res://scripts/banana.gd"), preload("res://scripts/lemon.gd"), preload("res://scripts/pineapple.gd"), preload("res://scripts/watermelon.gd")]
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
