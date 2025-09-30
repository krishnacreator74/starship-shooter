extends CharacterBody2D

@export var speed: float = 100.0        # vertical
@export var follow_speed: float = 80.0  # horizontal follow
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var fire_rate: float = 2.2

@onready var muzzle: Node2D = $MuzzlePoint
@onready var fire_timer: Timer = $FireTimer

var player: Node = null
var target_y: float = -320.0
var reached_target: bool = false

func _ready() -> void:
	add_to_group("enemy")

	# Timer hookup
	fire_timer.wait_time = fire_rate
	if not fire_timer.timeout.is_connected(_on_fire_timeout):
		fire_timer.timeout.connect(_on_fire_timeout)
	fire_timer.start()

	# find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players.front()

func _process(delta: float) -> void:
	if not reached_target:
		position.y += speed * delta
		if position.y >= target_y:
			position.y = target_y
			reached_target = true

	if player and reached_target:
		var dx = player.global_position.x - global_position.x
		global_position.x += clamp(dx, -follow_speed * delta, follow_speed * delta)

func _on_fire_timeout() -> void:
	shoot()

func shoot() -> void:
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position if muzzle else global_position
	# enemy bullets expect var 'direction' in their script
	bullet.direction = Vector2.DOWN
	bullet.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bullet)

func apply_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	if explosion_scene:
		var expi = explosion_scene.instantiate()
		expi.global_position = global_position
		get_tree().current_scene.add_child(expi)
	queue_free()
