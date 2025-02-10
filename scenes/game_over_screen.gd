extends CanvasLayer

const WIN = 1
const LOSE = 2

@onready var background_panel: Panel = $Panel


func set_game_over_state(state: int):
	if background_panel:
		var style = background_panel.get_theme_stylebox("panel", "Panel") # Get the current StyleBox
		if style is StyleBoxFlat: # Check if it's a StyleBoxFlat
			if state == WIN:
				style.bg_color = Color.GREEN
			else:
				style.bg_color = Color.RED
			background_panel.add_theme_stylebox_override("panel", style)
		else:
			print("Warning: Panel's StyleBox is not a StyleBoxFlat.")
