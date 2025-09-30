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

	var laser_count = muzzle_positions.size()

	# 🔊 Play ONE sound for the whole batch, with proper attenuation
	if laser_sound:
		var sfx = AudioStreamPlayer2D.new()
		parent.add_child(sfx)
		sfx.stream = laser_sound
		sfx.autoplay = false
		
		var volume_db = -6.0 * float(laser_count - 1)
		volume_db = clamp(volume_db, -24.0, 0.0)
		sfx.volume_db = volume_db

		sfx.play()
		sfx.connect("finished", Callable(sfx, "queue_free"))

	# 🔫 Spawn lasers
	for i in range(laser_count):
		var muzzle = muzzle_positions[i]
		if not is_instance_valid(muzzle):
			continue

		var bolt = bolt_scene.instantiate()
		bolt.global_position = muzzle.global_position
		bolt.modulate = color

		# Rotate laser according to angle
		var angle = 0.0
		if i < angles.size():
			angle = deg_to_rad(angles[i])
		bolt.rotation = angle
		bolt.direction = direction.rotated(angle)

		parent.add_child(bolt)
