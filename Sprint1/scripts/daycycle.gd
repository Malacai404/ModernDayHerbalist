extends Node

signal daypassed
var daycount := 0
var beaten_days := 0
const MAX_BEATEN_DAYS := 15
const SAVE_PATH := "user://daycycle_save.cfg"

func _ready() -> void:
	load_state()

func _process(_delta: float) -> void:
	pass

func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("daycycle", "daycount", daycount)
	config.set_value("daycycle", "beaten_days", beaten_days)
	config.save(SAVE_PATH)

func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	daycount = int(config.get_value("daycycle", "daycount", 0))
	beaten_days = int(config.get_value("daycycle", "beaten_days", 0))
	if beaten_days > MAX_BEATEN_DAYS:
		beaten_days = MAX_BEATEN_DAYS

func _daypassed() -> void:
	daycount += 1
	if beaten_days < MAX_BEATEN_DAYS:
		beaten_days += 1
	save_state()
	emit_signal("daypassed")

func _day_failed() -> void:
	daycount += 1
	save_state()
	emit_signal("daypassed")
