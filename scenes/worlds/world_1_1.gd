extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")

const LEVEL_LENGTH = 5056.0
const TIME = 60.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	var possible_bread_spawn_locations = [
		Vector2(768, 528),
		Vector2(1600, 336),
		Vector2(1600, 528),
		Vector2(2496, 528),
		Vector2(2816, 528),
		Vector2(2976, 528),
		Vector2(5024, 208),
		Vector2(4705, 208),
		Vector2(4512, 208),
		Vector2(4448, 272),
		Vector2(4384, 336)
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 5)
	var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 526)]
	var duck_spawn_locations = [Vector2(1570, 496), Vector2(4550, 496)]
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 439), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	
	Global.update_helmet_visibility()
	emit_signal("level_ready")
