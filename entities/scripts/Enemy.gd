extends CharacterBody2D

@export var speed: float = 100.0       # Vertical downward speed
@export var follow_speed: float = 80.0 # Horizontal follow speed
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var fire_rate: float = 2.2

@onready var muzzle = $MuzzlePoint
@onready var fire_timer = $FireTimer

var player: Node = null
var target_y: float = -320.0   # Enemy stops vertically here
var reached_target: bool = false

func _ready():
	add_to_group("enemy")

	# Fire timer setup
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	if not fire_timer.timeout.is_connected(_on_fire_timeout):
		fire_timer.timeout.connect(_on_fire_timeout)

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
	bullet.global_position = muzzle.global_position if muzzle else global_position
	bullet.direction = Vector2(0, 1)
	get_tree().current_scene.add_child(bullet)
	bullet.add_to_group("enemy_bullet")

func apply_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health:", health)
	if health <= 0:
		if explosion_scene:
			var exp = explosion_scene.instantiate()
			exp.global_position = global_position
			get_tree().current_scene.add_child(exp)
		queue_free()
