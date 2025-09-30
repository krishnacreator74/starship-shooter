extends Node

@export var enemy_scene: PackedScene   # Drag your Enemy.tscn here in the editor
@export var spawn_interval: float = 3.0   # seconds between spawns

var spawn_timer: Timer

@export var BG_music: AudioStream  # assign your music in Inspector

var player: AudioStreamPlayer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_enemy)
	add_child(spawn_timer)
	if BG_music:
		player = AudioStreamPlayer.new()  # 2D not needed for background music
		add_child(player)
		player.stream = BG_music
		player.volume_db = 0
		player.autoplay = true
		player.play()



func _input(event):
	if event.is_action_pressed("Quit"):
		get_tree().quit()
	elif event.is_action_pressed("Respawn"):
		get_tree().reload_current_scene()


# Called by spawn timer
func _spawn_enemy():
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()

	# Place enemy at random X across top of screen
	var viewport_rect = get_viewport().get_visible_rect()
	var x = randf_range(50, viewport_rect.size.x - 50)  # margin so they don’t spawn off-screen
	var y = -50  # just above the top
	enemy.position = Vector2(x, y)

	add_child(enemy)
