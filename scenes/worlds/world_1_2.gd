extends Node2D

const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
var rng = RandomNumberGenerator.new()

const LEVEL_LENGTH = 11500
const TIME = 120.0

signal level_ready

@onready var current_scene = get_tree().current_scene

func _ready() -> void:
	var possible_bread_spawn_locations = [
		Vector2(530, 400),
		Vector2(1480, 512),
		Vector2(2150,400),
		Vector2(2760, 400),
		Vector2(3272, 180),
		Vector2(4090, 294),
		Vector2(4484, 510),
		Vector2(4877, 291),
		Vector2(5540, 400),
		Vector2(5910, 176),
		Vector2(6474, 320),
		Vector2(7314,394),
		Vector2(8614, 456),
		Vector2(9254, 380),
		Vector2(9892, 460),
		Vector2(10658, 486)
	]
	
	rng.randomize()
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	var duck_spawn_locations = [Vector2(3172,400), Vector2(8390,384), Vector2(10416,384)]
	var egg_spawn_locations = [Vector2(3172,400), Vector2(8390,384), Vector2(10416,384)]
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(11150, 460), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 550), TIME)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	
	emit_signal("level_ready")
