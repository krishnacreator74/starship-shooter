extends Area2D

@export var speed: float = 100.0       # Vertical downward speed
@export var follow_speed: float = 80.0 # Horizontal follow speed
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var fire_rate: float = 2.2

@onready var muzzle = $MuzzlePoint
@onready var fire_timer = $FireTimer

var player: Node = null
var target_y: float = -320.0   # Enemy stops here vertically
var reached_target: bool = false

func _ready():
	add_to_group("enemy")

	# Start firing timer
	fire_timer.wait_time = fire_rate
	fire_timer.start()
	var callback = Callable(self, "_on_fire_timeout")
	if not fire_timer.is_connected("timeout", callback):
		fire_timer.timeout.connect(callback)

	# Get the player (assumes player is in "player" group)
	player = get_tree().get_nodes_in_group("player").front() if get_tree().get_nodes_in_group("player").size() > 0 else null

func _process(delta: float) -> void:
	# Vertical movement down until target_y
	if not reached_target:
		position.y += speed * delta
		if position.y >= target_y:
			position.y = target_y
			reached_target = true

	# Horizontal follow after reaching target
	if player:
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
	if health <= 0:
		if explosion_scene:
			var exp = explosion_scene.instantiate()
			exp.global_position = global_position
			get_tree().current_scene.add_child(exp)
		queue_free()
