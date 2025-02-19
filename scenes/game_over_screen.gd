extends CanvasLayer

const WIN = 1
const LOSE = 2

@onready var panel: Panel = $Panel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.layer = 100
	self.follow_viewport_enabled = false  # Prevents the CanvasLayer from moving with the camera.
	panel.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	panel.hide()

func set_game_over_state(state: int) -> void:
	if state == LOSE:
		panel.show()
	else:
		panel.hide()
