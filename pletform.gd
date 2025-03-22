extends AnimatableBody2D

@export var speed: float = 500
@export var move_offset: Vector2 = Vector2(4500, 0) # Can be (0, 4500) for vertical movement
@export var wait_time: float = 1

var direction: int = 1
var start_position: Vector2
var target_position: Vector2
var moving: bool = true

func _ready():
	start_position = global_position
	target_position = start_position + move_offset

func _physics_process(delta):
	if moving:
		# Move manually along the direction vector
		position += move_offset.normalized() * speed * direction * delta

		# Check if we passed the target position
		var current_vector = position - start_position
		var target_vector = move_offset

		# Use dot product to determine if we’ve gone too far
		if direction == 1 and current_vector.dot(target_vector) >= target_vector.length_squared():
			position = target_position
			_reverse_direction()

		elif direction == -1 and current_vector.dot(target_vector) <= 0:
			position = start_position
			_reverse_direction()

func _reverse_direction():
	direction *= -1
	moving = false
	await get_tree().create_timer(wait_time).timeout
	moving = true
