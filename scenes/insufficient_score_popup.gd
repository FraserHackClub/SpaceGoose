extends PopupPanel


@onready var ScoreLabel: Label = $Score/ScoreLabel

func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	add_theme_stylebox_override("panel", style)

func set_score(player_score: int, required_score: int) -> void:
	ScoreLabel.text = str(player_score) + "/" + str(required_score)

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
