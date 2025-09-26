extends CharacterBody2D

@export var speed := 400
@export var bolt_scene: PackedScene
@export var fire_rate := 0.3
@export var margin := 50   # 🚧 padding from the screen edges
var can_shoot := true

func _physics_process(delta):
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	# Clamp inside camera view
	var cam := get_viewport().get_camera_2d()
	if cam:
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		var half_size := viewport_size * 0.5 * cam.zoom  # account for zoom
		var top_left := cam.global_position - half_size
		var bottom_right := cam.global_position + half_size

		position.x = clamp(position.x, top_left.x + margin, bottom_right.x - margin)
		position.y = clamp(position.y, top_left.y + margin, bottom_right.y - margin)

	if Input.is_action_pressed("shoot"):
		shoot_laser()

func shoot_laser():
	if not can_shoot:
		return
	can_shoot = false
	_cooldown()

	var muzzle = $Muzzle.global_position
	var bolt = bolt_scene.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.global_position = muzzle
	bolt.direction = Vector2.UP
	bolt.modulate = Color(0.2, 0.8, 1.0)
	if $CPUParticles2D:
		$CPUParticles2D.restart()

func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
