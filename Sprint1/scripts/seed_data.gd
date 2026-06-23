extends Node

var seeds = [preload("res://scripts/seeds/grape_seed.tres")]

var plants = [preload("res://scripts/grape.gd")]
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
