extends Area2D

@export var speed: float = 900.0
@export var damage: int = 20
@export var lifetime: float = 2.0
@export var laser_sound: AudioStream   # assign in Inspector

var direction: Vector2 = Vector2.UP


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	_destroy_after_lifetime()




func _physics_process(delta):
	global_position += direction.rotated(rotation) * speed * delta




func _on_body_entered(body):
	if body.is_in_group("enemy") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()


func _destroy_after_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()
