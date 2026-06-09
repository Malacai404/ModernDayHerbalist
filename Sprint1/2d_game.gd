extends Node2D

var obstacles = [preload("uid://bof2je4fisr7"), preload("uid://b5atdowfob8m1"), preload("uid://bsigo2e8k6m4i")]
@onready var spawn_one = $spawnOne
@onready var spawn_two = $spawnTwo
@onready var spawn_three = $spawnThree



@onready var spawns = [spawn_one, spawn_two, spawn_three]

const base_spawn_time = 2.5
var spawn_time = 2.5

var speed = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed += delta
	spawn_time -= delta
	if spawn_time <= 0:
		_spawn()
		spawn_time = base_spawn_time

func _spawn():
	var i = randi_range(0,2)
	var object = obstacles[i].instantiate()
	i = randi_range(0,2)
	object.global_position = spawns[i].global_position
	add_child(object)
