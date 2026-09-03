extends Node3D

var growthstage: int = -1
var plantid: int
var growthtime: int

@export var pot_id = 0

@onready var ungrown = $ungrown

@onready var plantpot_growing = $plantpot_growing

@onready var plantpot_grown = $plantpot_grown

@onready var plant_1 = $plantpot_grown/Plant1
@onready var plant_2 = $plantpot_grown/Plant2
@onready var plant_3 = $plantpot_grown/Plant3

var text = "[font_size=20px]Press E to plant a seed![/font_size]"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Daycycle.daypassed.connect(_on_day_passed)

func get_hover_text():
	return text
	

func _process(delta):
	if growthstage == -1:
		text = "[font_size=20px]Press E to plant a seed![/font_size]"
		ungrown.visible = true
		plantpot_growing.visible = false
		plantpot_grown.visible = false
	elif(growthstage >= 0 and growthstage < growthtime):
		text = "[font_size=20px]Its growing[/font_size]"
		ungrown.visible = false
		plantpot_growing.visible = true
		plantpot_grown.visible = false
	elif(growthstage >= growthtime):
		text = "[font_size=20px]Press E to harvest![/font_size]"
		ungrown.visible = false
		plantpot_growing.visible = false
		plantpot_grown.visible = true
		
		
		plant_1.texture = SeedData._get_plant(plantid).texture
		plant_2.texture = SeedData._get_plant(plantid).texture
		plant_3.texture = SeedData._get_plant(plantid).texture

func activate(playerobj):
	if growthstage == -1:
		playerobj._open_seedslots(pot_id)
	elif(growthstage >= growthtime):
		print(plantid)
		playerobj._pickup_item(SeedData._get_plant(plantid), 3)
		playerobj._collect_seed(plantid, randi_range(1,3))
		growthstage = -1

func _plant(plantid_temp: int):
	if growthstage == -1:
		plantid = plantid_temp
		growthtime = SeedData._get_seed(plantid_temp).growthtime
		growthstage = 0        
		
		
func _on_day_passed() -> void:
	if growthstage >= 0:  
		growthstage += 1
