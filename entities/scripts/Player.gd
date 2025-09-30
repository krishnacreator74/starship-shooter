extends CharacterBody2D

@export var speed: float = 400
@export var bolt_scene: PackedScene
@export var fire_rate: float = 0.3
@export var margin: float = 50
@export var health: int = 100
@export var laser_level: int = 1  # 1=single,2=triple,3=5-laser
@export var explosion_scene: PackedScene  # optional for death

var can_shoot: bool = true
var muzzle_nodes: Array

var LaserShooter = preload("res://entities/scripts/LaserShooter.gd")
var laser_sound = preload("res://assests/Laser1-sfx.mp3")  # optional

func _ready() -> void:
	add_to_group("player")
	# Ensure these nodes exist in the Player scene. Add placeholders if not.
	muzzle_nodes = [
		$Muzzle,
		$MuzzleLeft,
		$MuzzleRight,
		$MuzzleFarLeft,
		$MuzzleFarRight
	]

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	move_and_slide()

	# clamp inside viewport/camera
	var cam = get_viewport().get_camera_2d()
	if cam:
		var viewport_size = get_viewport().get_visible_rect().size
		var half_size = viewport_size * 0.5 * cam.zoom
		var top_left = cam.global_position - half_size
		var bottom_right = cam.global_position + half_size

		position.x = clamp(position.x, top_left.x + margin, bottom_right.x - margin)
		position.y = clamp(position.y, top_left.y + margin, bottom_right.y - margin)

	if Input.is_action_pressed("shoot"):
		shoot_laser()

	if Input.is_action_just_pressed("upgrade"):
		upgrade_laser()

func shoot_laser() -> void:
	if not can_shoot or bolt_scene == null:
		return
	can_shoot = false
	_cooldown()

	var nodes: Array
	var angles: Array

	match laser_level:
		1:
			nodes = [$Muzzle]
			angles = [0]
		2:
			nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight]
			angles = [0, -25, 25]
		3:
			nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight,$MuzzleLeft, $MuzzleRight]
			angles = [0, -15, 15, -25, 25]

	# parent = the scene root so bullets are at top-level (collisions simpler)
	var parent_node = get_tree().current_scene
	LaserShooter.shoot_lasers(
		bolt_scene,
		nodes,
		Vector2.UP,
		Color(0.2, 0.8, 1.0),
		angles,
		parent_node,
		laser_sound
	)

func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func upgrade_laser() -> void:
	if laser_level < 3:
		laser_level += 1
		print("Laser upgraded to level %d" % laser_level)

# Damage Handling
func apply_damage(amount: int) -> void:
	health -= amount
	print("Player hit! Health:", health)
	if health <= 0:
		die()

func die() -> void:
	if explosion_scene:
		var exp = explosion_scene.instantiate()
		exp.global_position = global_position
		get_tree().current_scene.add_child(exp)
	queue_free()
