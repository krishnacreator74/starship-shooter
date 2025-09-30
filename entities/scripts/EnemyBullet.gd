extends Area2D

@export var speed: float = 150.0
@export var damage: int = 25
var direction: Vector2 = Vector2.DOWN

@export var lifetime: float = 5.0
var life_timer: float = 0.0

func _ready() -> void:
	# connect signals to detect collision with player
	self.body_entered.connect(_on_body_entered)
	self.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Move bullet in set direction
	if direction.length() > 0:
		global_position += direction.normalized() * speed * delta

	# Lifetime handling
	life_timer += delta
	if life_timer >= lifetime:
		queue_free()

	# Free if off-screen (ignore top for spawn)
	var rect = get_viewport().get_visible_rect()
	if global_position.y > rect.size.y + 100 \
	or global_position.x < -100 or global_position.x > rect.size.x + 100:
		queue_free()

func _on_body_entered(body: Node) -> void:
	_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _handle_hit(node: Node) -> void:
	if not is_instance_valid(node):
		return

	# Only damage the player
	if node.is_in_group("player"):
		if node.has_method("apply_damage"):
			node.apply_damage(damage)
		# Remove bullet after hitting player
		queue_free()
