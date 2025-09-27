extends Node

@export var BG_music: AudioStream  # assign your music in Inspector

var player: AudioStreamPlayer

func _ready():
	if BG_music:
		player = AudioStreamPlayer.new()  # 2D not needed for background music
		add_child(player)
		player.stream = BG_music
		player.volume_db = 0
		player.autoplay = true
		player.play()
