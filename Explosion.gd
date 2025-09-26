# res://scenes/Explosion.gd
extends Node2D

@export var duration: float = 0.8

func _ready() -> void:
	$ExplosionParticles.one_shot = true
	$ExplosionParticles.emitting = true
	# wait for duration then free
	await get_tree().create_timer(duration).timeout
	queue_free()
