extends CharacterBody2D

@export var speed := 400
@export var bolt_scene: PackedScene
@export var fire_rate := 0.3
@export var margin := 50   # padding from the screen edges
var can_shoot := true
var laser_level := 1  # 1 = single laser, 2 = triple, 3 = 5-laser spread
var muzzle_nodes: Array
var LaserShooter = preload("res://entities/scripts/LaserShooter.gd")
var laser_sound = preload("res://assests/Laser1-sfx.mp3")
@export var health: int = 100  # Player starting health
@export var lifetime: float = 2.0


func _ready():
	# Collect muzzle nodes (make sure these exist in your Player scene)  a
	muzzle_nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight]


func upgrade_laser():
	if laser_level < 3:   # max level 3
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
		
	if Input.is_action_just_pressed("upgrade"):  # Press 'U' to test upgrade
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
		if $CPUParticles2D:
			$CPUParticles2D.restart()
	elif laser_level == 2:
		nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight]
		angles = [0, -25, 25]
		if $CPUParticles2D and $CPUParticles2D2 and $CPUParticles2D3:
			$CPUParticles2D.restart()
			$CPUParticles2D2.restart()
			$CPUParticles2D3.restart()
			
	elif laser_level == 3:
		nodes = [$Muzzle, $MuzzleLeft, $MuzzleRight, $MuzzleLeft, $MuzzleRight]
		angles = [0, -15, 15, -25, 25]
		if $CPUParticles2D and $CPUParticles2D2 and $CPUParticles2D3:
			$CPUParticles2D.restart()
			$CPUParticles2D2.restart()
			$CPUParticles2D3.restart()



	LaserShooter.shoot_lasers(
		bolt_scene,
		nodes,
		Vector2.UP,
		Color(0.2, 0.8, 1.0),
		angles,
		get_tree().current_scene,
		laser_sound  # ✅ this is the correct AudioStream
	)

func apply_damage(amount: int) -> void:
	health -= amount
	print("Player hit! Health:", health)
	if health <= 0:
		die()

func die():
	print("Player destroyed!")
	queue_free()  # Or handle respawn/game over



func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
