extends Area2D

@export var speed: float = 900.0
@export var damage: int = 20
@export var lifetime: float = 2.0
@export var laser_sound: AudioStream   # optional, assign in Inspector

var direction: Vector2 = Vector2.UP

func _ready() -> void:
	# Add to group so others (debug or systems) can find player lasers
	add_to_group("player_laser")

	# connect signals (Area2D emits body_entered for PhysicsBody2D like CharacterBody2D)
	# and area_entered for other Area2D overlaps
	self.body_entered.connect(_on_body_entered)
	self.area_entered.connect(_on_area_entered)

	_destroy_after_lifetime()

func _physics_process(delta: float) -> void:
	# Movement uses direction (already rotated by shooter if needed)
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _handle_hit(node: Node) -> void:
	if not is_instance_valid(node):
		return
	# Only damage things in the "enemy" group
	if node.is_in_group("enemy"):
		if node.has_method("apply_damage"):
			node.apply_damage(damage)
		else:
			print("Hit enemy but it has no apply_damage()")
		queue_free()

func _destroy_after_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()
