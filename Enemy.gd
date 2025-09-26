# res://scenes/Enemy.gd
extends Area2D

@export var speed: float = 80.0
@export var health: int = 3
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var fire_rate: float = 2.2  # seconds between shots

@onready var sprite := $ShipSprite
@onready var muzzle := $MuzzleParticles
@onready var fire_timer := $FireTimer

func _ready() -> void:
	add_to_group("enemy")
	# ensure timer matches exported value
	fire_timer.wait_time = fire_rate
	# connect the Timer signal (you can also connect in the editor Node > Signals)
	fire_timer.timeout.connect(Callable(self, "_on_fire_timeout"))

func _process(delta: float) -> void:
	# move downward
	position.y += speed * delta

	# free if off-screen
	var rect = get_viewport_rect()
	if position.y > rect.size.y + 50:
		queue_free()

func _on_fire_timeout() -> void:
	shoot()

func shoot() -> void:
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	# spawn the bullet from slightly below the ship (adjust offset to match your sprite)
	var muzzle_offset = Vector2.ZERO
	if sprite and sprite.texture:
		muzzle_offset = Vector2(0, sprite.texture.get_size().y * 0.5)

	bullet.position = global_position + muzzle_offset
	bullet.direction = Vector2(0, 1) # downwards: change if your orientation differs
	get_parent().add_child(bullet)  # put bullet into the same parent as Enemy

	# tag it in case you didn't add the group in the bulet scene
	bullet.add_to_group("enemy_bullet")

	# play muzzle particles (one-shot)
	if muzzle:
		muzzle.emitting = false  # restart the one-shot properly
		muzzle.one_shot = true
		muzzle.emitting = true

func take_damage(dmg: int) -> void:
	health -= dmg
	# optional: flash effect here
	if health <= 0:
		die()

func die() -> void:
	if explosion_scene:
		var ex = explosion_scene.instantiate()
		ex.global_position = global_position
		get_parent().add_child(ex)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		var d = 1  # default damage
		# If the bullet scene has a "damage" property, use it
		if "damage" in area:
			d = area.damage
		take_damage(d)
		area.queue_free()
