extends Camera2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var camera_2d: Camera2D = $"."
@onready var level: Node2D = $".."

@export var smooth_speed: float = 0.1
@export var LEVEL_LENGTH: float = 0.0
const VIEWPORT_WIDTH = 1152.0
const VIEWPORT_HEIGHT = 648.0

var playing_cutscene: bool = false

func _ready():
	Global.bullet_counter = $HUD/BulletCounter/BulletCountLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_instance_valid(goose):
		var target_x = min(max(0.0, goose.position.x), (LEVEL_LENGTH - VIEWPORT_WIDTH))
		position.x = lerp(position.x, target_x, smooth_speed)
	
	if playing_cutscene:
		$"status-indicator".animation = "stop"
		$"exit-btn".hide()
	elif get_tree().paused:
		$"status-indicator".animation = "pause"
		$"exit-btn".show()
	else:
		$"status-indicator".animation = "default"
		$"exit-btn".hide()


func _on_exitbtn_pressed() -> void:
	if get_node_or_null("/root/Main"):
		level.get_tree().paused = false
		get_node_or_null("/root/Main").load_menu()
