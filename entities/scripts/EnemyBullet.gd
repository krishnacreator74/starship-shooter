extends Area2D

@export var speed: float = 150.0
@export var damage: int = 25
var direction: Vector2 = Vector2.DOWN

@export var lifetime: float = 5.0
var life_timer: float = 0.0

# short spawn safety time to avoid instant collisions with overlapping bodies
const SPAWN_SAFE_TIME: float = 0.05

func _ready():
	add_to_group("enemy_bullet")
	connect("body_entered", Callable(self, "_on_body_entered"))

	# disable monitoring for a tiny moment so we don't hit something we overlap at spawn
	monitoring = false
	var t = get_tree().create_timer(SPAWN_SAFE_TIME)
	t.timeout.connect(Callable(self, "_on_spawn_safe"))


func _process(delta: float) -> void:
	# Movement
	if direction.length() > 0:
		global_position += direction.normalized() * speed * delta

	# Lifetime
	life_timer += delta
	if life_timer >= lifetime:
		queue_free()
		return

	# Off-screen check using Camera2D world rect (robust when camera moves)
	var vp = get_viewport()
	var cam = vp.get_camera_2d()
	var rect: Rect2
	if cam:
		var vp_size = vp.size
		var top_left = cam.global_position - vp_size * 0.5
		rect = Rect2(top_left, vp_size)
	else:
		# fallback (no camera); this may be screen-local
		rect = vp.get_visible_rect()

	var margin = 200
	if global_position.y > rect.position.y + rect.size.y + margin \
	or global_position.y < rect.position.y - margin \
	or global_position.x < rect.position.x - margin \
	or global_position.x > rect.position.x + rect.size.x + margin:
		queue_free()


func _on_body_entered(body):
	# Only damage & free if we hit the player
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()

func _on_spawn_safe() -> void:
	monitoring = true
