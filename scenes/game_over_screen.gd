extends CanvasLayer

const WIN = 1
const LOSE = 2
const BASE_OFFSET = Vector2(600, 675)

@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $Panel/TextureRect

func _ready():
	randomize()  # Initialize random number generator.
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.layer = 100
	self.follow_viewport_enabled = false  # Keeps the death screen fixed.
	panel.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	hide()  # Hide the death screen initially.
	# Set the TextureRect’s base position.
	texture_rect.position = BASE_OFFSET
	# Set a fixed, smaller scale.
	self.scale = Vector2(0.4, 0.3)

func set_game_over_state(state: int) -> void:
	if state == LOSE:
		# Load the death screen image.
		var death_texture: Texture2D = load("res://assets/sprites/die.png") as Texture2D
		if death_texture:
			texture_rect.texture = death_texture
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.modulate = Color(1, 1, 1, 1)
		else:
			print("Error: Could not load die.png!")
		show()  # Show the death screen.
		
		# Shake tween: 10 cycles of a rigid, sharp shake applied to the TextureRect.
		var shake_tween = get_tree().create_tween()
		var shake_cycles = 10
		for i in range(shake_cycles):
			var off = BASE_OFFSET + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			shake_tween.tween_property(texture_rect, "position", off, 0.1).set_trans(Tween.TRANS_LINEAR)
			shake_tween.tween_property(texture_rect, "position", BASE_OFFSET, 0.1).set_trans(Tween.TRANS_LINEAR)
	else:
		hide()
