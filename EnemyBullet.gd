# res://scenes/EnemyBullet.gd
extends Area2D

@export var speed: float = 420.0
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# make sure Area2D emits collisions
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	position += direction.normalized() * speed * delta

	var rect = get_viewport_rect()
	if position.y < -100 or position.y > rect.size.y + 100 or position.x < -100 or position.x > rect.size.x + 100:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# enemy bullets should hit the player only
	if is_in_group("enemy_bullet") and area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()

	# (If you use a shared bullet for player, handle player bullet hitting enemy here too)
