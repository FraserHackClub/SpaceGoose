extends Node2D

@onready var area = $Area2D
@onready var Press_E_Prompt_Interface = $Press_E_Prompt_Interface
@export var teleport_destination: Vector2
@export var camera_section_length: float = 16281.0
@export var camera_section_height: float = 900.0
@export var camera_offset: Vector2
@export var sublevel_index: float = 0.0

@onready var teleported = false
@onready var player_in_bounds = false
func _ready() -> void:
	Press_E_Prompt_Interface.visible = false
	add_to_group("teleporter")
	
	
	
func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		Press_E_Prompt_Interface.visible = true
		player_in_bounds = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	Press_E_Prompt_Interface.visible = false
	player_in_bounds = false


func _process(delta: float) -> void:
	if player_in_bounds == true:
		if Input.is_action_just_pressed("enter"):
				print("cool")
				Global.main_character.change_to_next_level()
				teleported = true
