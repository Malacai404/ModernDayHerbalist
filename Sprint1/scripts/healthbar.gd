extends Node3D

@onready var progress_bar = $SubViewport/TextureProgressBar

func update_health(current_health: float, max_health: float) -> void:
	progress_bar.max_value = max_health
	progress_bar.value = current_health
