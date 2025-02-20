extends CanvasLayer

const WIN = 1
const LOSE = 2
const BASE_OFFSET = Vector2(135, 100)
@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $Panel/TextureRect

func _ready():
	randomize()  
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.layer = 100
	self.follow_viewport_enabled = false  
	panel.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	hide()  
	self.offset = BASE_OFFSET

	self.scale = Vector2(0.8, 0.6)

func set_game_over_state(state: int) -> void:
	if state == LOSE:
		# Load the death screen image.
		var death_texture: Texture2D = load("res://assets/sprites/die.png") as Texture2D
		if death_texture:
			texture_rect.texture = death_texture
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.modulate = Color(1, 1, 1, 1)
		else:
			print("Error: Could not load")
		show()  
		

		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(self, "scale", Vector2(0.85, 0.6), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		zoom_tween.tween_property(self, "scale", Vector2(0.8, 0.6), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		

		var shake_tween = get_tree().create_tween()
		var shake_cycles = 10
		for i in range(shake_cycles):
			var off = BASE_OFFSET + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			shake_tween.tween_property(self, "offset", off, 0.1).set_trans(Tween.TRANS_LINEAR)
			shake_tween.tween_property(self, "offset", BASE_OFFSET, 0.1).set_trans(Tween.TRANS_LINEAR)
	else:
		hide()
