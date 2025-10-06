extends CharacterBody2D

@export var speed: float = 100.0       # Vertical downward speed
@export var follow_speed: float = 80.0 # Horizontal follow speed
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var fire_rate: float = 2.2

@onready var muzzle = $MuzzlePoint
@onready var fire_timer: Timer = $FireTimer

var player: Node = null
var target_y: float = -320.0   # Enemy stops vertically here
var reached_target: bool = false

func _ready():
	add_to_group("enemy")

	# Fire timer setup (restart fresh every spawn)
	fire_timer.stop()
	fire_timer.wait_time = fire_rate
	if not fire_timer.timeout.is_connected(_on_fire_timeout):
		fire_timer.timeout.connect(_on_fire_timeout, CONNECT_DEFERRED)
	fire_timer.start(fire_rate)  # start with delay

	# Find player (first node in "player" group)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players.front()


func _physics_process(delta: float) -> void:
	# Move vertically until reaching target_y
	if not reached_target:
		position.y += speed * delta
		if position.y >= target_y:
			position.y = target_y
			reached_target = true

	# Follow player horizontally
	if player and is_instance_valid(player):
		var dx = player.global_position.x - global_position.x
		global_position.x += clamp(dx, -follow_speed * delta, follow_speed * delta)

func _on_fire_timeout() -> void:
	shoot()

func shoot() -> void:
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()

	# Spawn at muzzle or enemy position
	if muzzle:
		bullet.global_position = muzzle.global_position
	else:
		bullet.global_position = global_position

	# Always set bullet direction explicitly
	bullet.direction = Vector2.DOWN  # Same as (0, 1)

	# Add bullet to the same parent as enemy (safer than root)
	get_parent().add_child(bullet)

	bullet.add_to_group("enemy_bullet")

func apply_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health:", health)
	if health <= 0:
		if explosion_scene:
			var exp = explosion_scene.instantiate()
			exp.global_position = global_position
			get_tree().root.add_child(exp)
		queue_free()
