extends CharacterBody2D

@export var speed: float = 500
@export var move_offset: Vector2 = Vector2(4500, 0)



var direction: int = 1
var start_position: Vector2
var target_position: Vector2
var moving: bool = false

func _ready():
	start_position = global_position
	target_position = start_position + move_offset
	Global.piston = self
func go():
	moving = true

func _physics_process(delta):
	if moving:
		global_position += move_offset.normalized() * speed * direction * delta

		var current_vector = global_position - start_position
		var target_vector = move_offset

		if direction == 1 and current_vector.dot(target_vector) >= target_vector.length_squared():
			global_position = target_position
