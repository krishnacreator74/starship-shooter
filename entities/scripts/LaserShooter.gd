# res://entities/scripts/LaserShooter.gd
extends Node

static func shoot_lasers(
	bolt_scene: PackedScene,
	muzzle_positions: Array,
	direction: Vector2,
	color: Color,
	angles: Array = [],
	parent: Node = null
) -> void:
	if parent == null:
		push_error("LaserShooter: parent node must be passed to add lasers!")
		return

	for i in muzzle_positions.size():
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
		bolt.direction = direction.rotated(angle)

		parent.add_child(bolt)
