extends Camera2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var camera_2d: Camera2D = $"."

@export var smooth_speed = 0.1
const LEVEL_END = 5056.0
const VIEWPORT_WIDTH = 1152.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(goose):
		var target_x = min(max(0.0, goose.position.x), (LEVEL_END - VIEWPORT_WIDTH))
		position.x = lerp(position.x, target_x, smooth_speed)
		
