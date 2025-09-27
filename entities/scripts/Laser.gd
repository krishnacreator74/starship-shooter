extends Area2D

@export var speed := 900.0
@export var damage := 20
@export var lifetime := 2.0
@export var laser_sound: AudioStream

var direction := Vector2.UP

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if laser_sound:
		var sfx = AudioStreamPlayer2D.new()
		add_child(sfx)
		sfx.stream = laser_sound
		sfx.play()
		await sfx.finished
		sfx.queue_free()

	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	position += direction.rotated(rotation) * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()
