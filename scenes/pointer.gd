extends Node2D

@export var smooth_speed: float = 0.2
@export var action: Callable
@onready var icon: Sprite2D = $Sprite2D
var clicking_phase: int = false

func click() -> void:
	$Click_sound.play()
	clicking_phase = max(clicking_phase, 1)

func _process(_delta: float) -> void:	
	if clicking_phase > 0:
		match clicking_phase:
			1:
				icon.position = lerp(icon.position, Vector2(32, -32), smooth_speed)
			2:
				icon.position = lerp(icon.position, Vector2.ZERO, smooth_speed)
		
		if round(icon.position.x) == 32:
			clicking_phase = 2
		elif round(icon.position.x) == 0:
			clicking_phase = 0
			action.call()
