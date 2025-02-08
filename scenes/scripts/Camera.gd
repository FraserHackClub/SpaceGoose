extends Camera2D

@export var min_zoom := 0.5
@export var max_zoom := 2.0
@export var zoom_speed := 0.1

func adjust_zoom(zoom_in: bool) -> void:
	var zoom_change = zoom_speed if zoom_in else -zoom_speed
	var new_zoom = clamp(zoom.x + zoom_change, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

var shake_strength := 0.0
var shake_decay := 5.0

func add_shake(amount: float) -> void:
	shake_strength = amount

func _process(delta: float) -> void:
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			0  
		)
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
