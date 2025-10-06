extends Node

static func shoot_lasers(
	bolt_scene: PackedScene,
	muzzle_positions: Array,
	direction: Vector2,
	color: Color,
	angles: Array = [],
	parent: Node = null,
	laser_sound: AudioStream = null
) -> void:
	if parent == null:
		push_error("LaserShooter: parent node must be passed to add lasers!")
		return

	for i in range(muzzle_positions.size()):
		var muzzle = muzzle_positions[i]
		if not is_instance_valid(muzzle):
			continue

		var bolt = bolt_scene.instantiate()
		bolt.global_position = muzzle.global_position
		bolt.modulate = color

		# Calculate spread
		var angle = 0.0
		if i < angles.size():
			angle = deg_to_rad(angles[i])

		bolt.direction = direction.rotated(angle)
		bolt.rotation = bolt.direction.angle() + deg_to_rad(-90)  # adjust if sprite points up

		parent.add_child(bolt)

	# Play sound once
	if laser_sound:
		var sfx = AudioStreamPlayer2D.new()
		parent.add_child(sfx)
		sfx.stream = laser_sound
		sfx.play()
		sfx.connect("finished", Callable(sfx, "queue_free"))
