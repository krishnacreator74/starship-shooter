extends Area2D

@export var speed := 900.0
@export var damage := 20
@export var lifetime := 2.0
@export var laser_sound: AudioStream   # assign in Inspector

var direction := Vector2.UP  # default goes up

func _ready():
	# play sound immediately
	if laser_sound:
		var sfx = AudioStreamPlayer2D.new()
		add_child(sfx)
		sfx.stream = laser_sound
		sfx.volume_db = 0
		sfx.autoplay = false
		sfx.play()
		sfx.connect("finished", Callable(sfx, "queue_free"))

	# auto destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	# Move in the rotated direction
	position += direction.rotated(rotation) * speed * delta

func _on_body_entered(body):
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
