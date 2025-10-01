extends Area2D

@export var speed: float = 150.0
@export var damage: int = 25
var direction: Vector2 = Vector2(0, 1)

@export var lifetime: float = 5.0
var life_timer: float = 0.0

func _ready():
	add_to_group("enemy_bullet")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	# Movement
	if direction.length() > 0:
		global_position += direction.normalized() * speed * delta

	# Lifetime
	life_timer += delta
	if life_timer >= lifetime:
		queue_free()

	# Kill if off-screen (bottom/side overflow allowed, top ignored)
	var rect = get_viewport().get_visible_rect()
	if global_position.y > rect.size.y + 100 \
	or global_position.x < -100 or global_position.x > rect.size.x + 100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()
