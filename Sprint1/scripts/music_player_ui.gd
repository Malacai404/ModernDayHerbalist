extends CanvasLayer

@onready var panel = $PanelContainer
@onready var album_art = $PanelContainer/HBoxContainer/MarginContainer/TextureRect
@onready var title_label = $PanelContainer/HBoxContainer/VBoxContainer/TitleLabel
@onready var artist_label = $PanelContainer/HBoxContainer/VBoxContainer/ArtistLabel

var fade_tween: Tween

func _ready():
	MusicManager.song_changed.connect(update_ui)
	panel.modulate.a = 0.0

func update_ui(song_info: Dictionary):
	title_label.text = song_info["title"]
	artist_label.text = song_info["artist"]
	album_art.texture = song_info["art"]
	
	animate_ui()

func animate_ui():
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	
	fade_tween = create_tween()
	
	fade_tween.tween_property(panel, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	fade_tween.tween_interval(4.0)
	
	fade_tween.tween_property(panel, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
