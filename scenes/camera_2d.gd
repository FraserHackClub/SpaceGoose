extends Camera2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var camera_2d: Camera2D = $"."

@export var smooth_speed = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(goose):
		var target_x = max(0.0, goose.position.x)
		position.x = lerp(position.x, target_x, smooth_speed)
		
