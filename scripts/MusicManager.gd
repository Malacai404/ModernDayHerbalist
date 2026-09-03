extends Node

var audio_player: AudioStreamPlayer

@export var playlists = {
	"grow_world": [
		{"title": "Decorate", "artist": "Abstract", "art": preload("res://music/InteriorBirdecorator.png"), "file": preload("res://music/audio/Interior Birdecorator Decorate.ogg")},
	],
	"outerworld_1": [
		{"title": "Sketchbook 2024-07-04", "artist": "Abstract", "art": preload("res://music/Sketchbook2024Metadata.jpg"), "file": preload("res://music/audio/Sketchbook 2024-07-04.ogg")},
		{"title": "Sketchbook 2024-12-21", "artist": "Abstract", "art": preload("res://music/Sketchbook2024Metadata.jpg"), "file": preload("res://music/audio/Sketchbook 2024-12-21.ogg")},
		{"title": "Sketchbook 2025-11-13", "artist": "Abstract", "art": preload("res://music/Sketchbook2025Metadata.jpg"), "file": preload("res://music/audio/Sketchbook 2025-11-13.ogg")},
		{"title": "Sketchbook 2025-12-14", "artist": "Abstract", "art": preload("res://music/Sketchbook2025Metadata.jpg"), "file": preload("res://music/audio/Sketchbook 2025-12-14.ogg")},
		{"title": "Three Red Hearts Go (No Vocal)", "artist": "Abstract", "art": preload("res://music/album_three_red_hearts.jpg"), "file": preload("res://music/audio/Three Red Hearts Go (No Vocal).ogg")},
		{"title": "Three Red Hearts Modern Bits", "artist": "Abstract", "art": preload("res://music/album_three_red_hearts.jpg"), "file": preload("res://music/audio/Three Red Hearts Modern Bits.ogg")}
	]
}

var current_playlist: Array = []
var current_song_index: int = 0

signal song_changed(song_info)

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = SettingsData.volume_settings
	audio_player.finished.connect(_on_song_finished)

func _process(delta: float) -> void:
	audio_player.volume_db = SettingsData.volume_settings

func play_playlist(playlist_name: String):
	if playlists.has(playlist_name):
		current_playlist = playlists[playlist_name].duplicate()
		current_playlist.shuffle()
		current_song_index = 0
		play_current_song()

func play_current_song():
	if current_playlist.size() == 0: return
	
	var song = current_playlist[current_song_index]
	audio_player.stream = song["file"]
	audio_player.play()
	
	song_changed.emit(song)

func play_specific_song(song_title: String):
	for playlist_name in playlists:
		var playlist = playlists[playlist_name]
		for index in range(playlist.size()):
			if playlist[index]["title"] == song_title:
				current_playlist = playlist.duplicate()
				current_playlist.shuffle()
				
				for new_index in range(current_playlist.size()):
					if current_playlist[new_index]["title"] == song_title:
						current_song_index = new_index
						break
						
				play_current_song()
				return
				

func _on_song_finished():
	current_song_index = (current_song_index + 1) % current_playlist.size()
	play_current_song()
