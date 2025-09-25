extends Area2D

@export var speed := 900.0
@export var damage := 20
@export var lifetime := 2.0

var direction := Vector2.UP  # goes upward by default

func _ready():
	# auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
