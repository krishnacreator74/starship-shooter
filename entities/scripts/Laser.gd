extends Area2D

@export var speed: float = 900.0
@export var damage: int = 20
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.UP

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	rotation = direction.angle() + deg_to_rad(-90)  # adjust if sprite points up
	_destroy_after_lifetime()

func _physics_process(delta):
	# Move along direction ONLY
	global_position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body.has_method("apply_damage"):
			body.apply_damage(damage)
		queue_free()

func _destroy_after_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()
