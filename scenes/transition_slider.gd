extends TextureRect 

@onready var texture_rect = self

func fade_in(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 1.0, duration)

func fade_out(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 0.0, duration)

func _ready():
	texture_rect.modulate.a = 0.0  # Start invisible
	fade_in(1.5)
	await get_tree().create_timer(3.0).timeout
	fade_out(1.5)
