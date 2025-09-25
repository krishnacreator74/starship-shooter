extends CharacterBody2D

@export var speed := 400
@export var fire_rate := 0.2
@export var laser_range := 1200.0
@export var laser_damage := 25

var can_shoot := true

func _physics_process(delta):
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_pressed("shoot"):
		shoot_laser()

func shoot_laser():
	if not can_shoot:
		return
	can_shoot = false
	_cooldown()

	var muzzle = $Muzzle.global_position
	var from = muzzle
	var to = from + Vector2(0, -1) * laser_range  # ✅ shoot upward (negative Y)

	# Raycast straight up
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	var hit_pos = to
	if result:
		hit_pos = result.position
		var collider = result.collider
		if collider and collider.has_method("apply_damage"):
			collider.apply_damage(laser_damage)

	_draw_beam(from, hit_pos)

	# trigger muzzle flash particles
	if $CPUParticles2D:
		$CPUParticles2D.restart()

func _draw_beam(from: Vector2, to: Vector2):
	var beam = Line2D.new()
	beam.width = 4
	beam.default_color = Color(0.2, 0.8, 1.0, 0.9) # cyan Star Wars style
	beam.z_index = 100
	
	# make sure beam uses global coords, not ship-local
	beam.global_position = Vector2.ZERO
	beam.add_point(from)
	beam.add_point(to)

	get_tree().current_scene.add_child(beam)

	_fade_beam(beam)


func _fade_beam(beam: Line2D) -> void:
	await get_tree().create_timer(0.03).timeout
	if is_instance_valid(beam):
		beam.queue_free()

func _cooldown() -> void:
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
