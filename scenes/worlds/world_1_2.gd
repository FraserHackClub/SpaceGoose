extends Node2D

const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
var rng = RandomNumberGenerator.new()

const LEVEL_LENGTH = 11500

signal level_ready

@onready var current_scene = get_tree().current_scene

func _ready() -> void:
	rng.randomize()
	Global.spawn_entity(finish_scene, current_scene, Vector2(11150, 460), "win_zone")
	Global.spawn_entity(player_scene, current_scene, Vector2(0, 550))
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	
	emit_signal("level_ready")
