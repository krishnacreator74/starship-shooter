extends CharacterBody2D

@export var speed := 400
@export var bolt_scene: PackedScene
@export var fire_rate := 0.3
@export var margin := 50   # padding from the screen edges
@export var health: int = 5
@export var explosion_scene: PackedScene  # optional, for death effect

var can_shoot := true
var laser_level := 1  # 1 = single laser, 2 = triple, 3 = 5-laser spread
var muzzle_nodes: Array

var LaserShooter = preload("res://entities/scripts/LaserShooter.gd")

func _ready():
	add_to_group("player")  # For enemy targeting
	muzzle_nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight, $MuzzleFarLeft, $MuzzleFarRight]

func upgrade_laser():
	if laser_level < 3:
		laser_level += 1
		print("Laser upgraded to level %d" % laser_level)

func _physics_process(delta):
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	# Clamp inside camera view
	var cam := get_viewport().get_camera_2d()
	if cam:
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		var half_size := viewport_size * 0.5 * cam.zoom
		var top_left := cam.global_position - half_size
		var bottom_right := cam.global_position + half_size

		position.x = clamp(position.x, top_left.x + margin, bottom_right.x - margin)
		position.y = clamp(position.y, top_left.y + margin, bottom_right.y - margin)

	if Input.is_action_pressed("shoot"):
		shoot_laser()
		
	if Input.is_action_just_pressed("upgrade"):
		upgrade_laser()

func shoot_laser():
	if not can_shoot:
		return
	can_shoot = false
	_cooldown()

	var nodes: Array
	var angles: Array

	if laser_level == 1:
		nodes = [$Muzzle]
		angles = [0]
	elif laser_level == 2:
		nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight]
		angles = [0, -25, 25]
	elif laser_level == 3:
		nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight, $MuzzleFarLeft, $MuzzleFarRight]
		angles = [0, -25, 25, -50, 50]

	for i in range(nodes.size()):
		var muzzle = nodes[i]
		var angle_deg = angles[i]
		var bolt = bolt_scene.instantiate()
		get_tree().current_scene.add_child(bolt)
		bolt.global_position = muzzle.global_position
		bolt.rotation = deg_to_rad(angle_deg)
		bolt.direction = Vector2.UP
		bolt.modulate = Color(0.2, 0.8, 1.0)

func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

# -------------------------------
# Damage Handling
# -------------------------------
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
