extends CharacterBody2D

@export var speed := 400 # Adjust speed as needed

func _physics_process(delta):
	# Get input as a vector (left, right, up, down)
	var direction := Input.get_vector("left", "right", "up", "down")
	
	# Set velocity based on input
	velocity = direction * speed
	
	# Move the character
	move_and_slide()
