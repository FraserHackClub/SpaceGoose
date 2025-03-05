extends Node2D

const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
var rng = RandomNumberGenerator.new()

const LEVEL_LENGTH = 11500
const TIME = 120.0

signal level_ready

@onready var current_scene = get_tree().current_scene

func _ready() -> void:
	var possible_bread_spawn_locations = []
	
	rng.randomize()
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(11150, 460), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 550), TIME)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	
	emit_signal("level_ready")
