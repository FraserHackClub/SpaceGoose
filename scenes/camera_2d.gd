extends Camera2D

@onready var grapejuice_timericon: TextureRect = $"HUD/GrapeJuiceTimer/TimerIcon"
@onready var goose: CharacterBody2D = $"../goose"
@onready var camera_2d: Camera2D = $"."
@onready var level: Node2D = $".."
@onready var juice_menu_scene: PackedScene = preload("res://scenes/worlds/juice_menu.tscn")
@onready var main: Node = get_node_or_null("/root/Main")

@export var smooth_speed: float = 0.1
@export var LEVEL_LENGTH: float = 0.0
const VIEWPORT_WIDTH = 1152.0
const VIEWPORT_HEIGHT = 648.0

var playing_cutscene: bool = false
var juice_menu: PopupPanel 

func toggle_pause(value = null):
	if main:
		main.toggle_pause(value)

func toggle_juice_menu():
	if juice_menu.visible:
		juice_menu.hide()
	else:
		juice_menu.show()

func _ready():
	juice_menu = juice_menu_scene.instantiate()
	juice_menu.hide()
	add_child(juice_menu)
	
	Global.bullet_counter = $HUD/BulletCounter/BulletCountLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_instance_valid(goose):
		var target_x = min(max(0.0, goose.position.x), (LEVEL_LENGTH - VIEWPORT_WIDTH))
		position.x = lerp(position.x, target_x, smooth_speed)
		grapejuice_timericon.modulate = goose.modulate
	
	if Input.is_action_just_pressed("juice") and not playing_cutscene:
		toggle_juice_menu()
	
	if playing_cutscene:
		juice_menu.hide()
		$"status-indicator".animation = "stop"
		$"btn-container".hide()
	elif get_tree().paused:
		$"status-indicator".animation = "pause"
		$"btn-container".show()
	else:
		$"status-indicator".animation = "default"
		$"btn-container".hide()
	
	toggle_pause(juice_menu.visible)


func _on_exitbtn_pressed() -> void:
	if get_node_or_null("/root/Main"):
		level.get_tree().paused = false
		get_node_or_null("/root/Main").load_menu()


func _on_restartbtn_pressed() -> void:
	if goose.game_state == 0:
		level.get_tree().paused = false
		Global.restart_game()
