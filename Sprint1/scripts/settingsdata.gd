extends Node

const SAVE_PATH := "user://settings_save.cfg"

var sens_settings = 0.005
var volume_settings = -30

func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "sens_settings", sens_settings)
	config.set_value("settings", "volume_settings", volume_settings)
	config.save(SAVE_PATH)

func load_state() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	sens_settings = float(config.get_value("settings", "sens_settings", sens_settings))
	volume_settings = float(config.get_value("settings", "volume_settings", volume_settings))

func _ready() -> void:
	load_state()

func _process(delta: float) -> void:
	pass
