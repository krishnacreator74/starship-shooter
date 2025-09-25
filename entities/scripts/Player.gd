extends CharacterBody2D

@export var speed := 400

func _physics_process(delta):
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_pressed("shoot"):
		shoot_laser()
		
@export var bolt_scene: PackedScene   # Drag your LaserBolt.tscn here in the editor
@export var fire_rate := 0.3
var can_shoot := true

func shoot_laser():
	if not can_shoot:
		return
	can_shoot = false
	_cooldown()

	var muzzle = $Muzzle.global_position
	var bolt = bolt_scene.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.global_position = muzzle
	bolt.direction = Vector2.UP   # 🚀 goes upward
	bolt.modulate = Color(0.2, 0.8, 1.0)  # 🔵 player color
	if $CPUParticles2D:
		$CPUParticles2D.restart()

func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
