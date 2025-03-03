extends Node2D

const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
var rng = RandomNumberGenerator.new()

const LEVEL_LENGTH = 6000.0

signal level_ready

@onready var current_scene = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 439), "win_zone")
	Global.spawn_entity(player_scene, current_scene, Vector2(0, 638))
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	
	emit_signal("level_ready")
