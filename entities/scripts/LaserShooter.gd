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

	# Play one sound for the batch and cleanup properly (use parent.get_tree() inside static)
	if laser_sound:
		var sfx = AudioStreamPlayer2D.new()
		parent.add_child(sfx)
		sfx.stream = laser_sound
		sfx.play()

		# try to get length; if unavailable, wait a short default time
		var sound_length = 0.0
		if sfx.stream:
			sound_length = sfx.stream.get_length()
		if sound_length <= 0.0:
			sound_length = 0.25
		await parent.get_tree().create_timer(sound_length).timeout
		if is_instance_valid(sfx):
			sfx.queue_free()

	# Spawn lasers
	for i in range(laser_count):
		var muzzle = muzzle_positions[i]
		if not is_instance_valid(muzzle):
			continue

		var bolt = bolt_scene.instantiate()
		# set starting position & color
		bolt.global_position = muzzle.global_position
		bolt.modulate = color

		# compute angle (degrees -> radians)
		var angle = 0.0
		if i < angles.size():
			angle = deg_to_rad(angles[i])

		# set rotation for visuals and pass rotated direction for movement
		bolt.rotation = angle
		# ensure bolt has 'direction' var in its script (we provide it in Laser.gd)
		bolt.direction = direction.rotated(angle)

		parent.add_child(bolt)
		# mark it so collisions/logic can see it
		if not bolt.is_in_group("player_laser"):
			bolt.add_to_group("player_laser")
