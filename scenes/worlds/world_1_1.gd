extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")

signal level_ready

@onready var current_scene = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var possible_bread_spawn_locations = [
		
	]
	var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 526)]
	var duck_spawn_locations = [Vector2(1570, 496), Vector2(4550, 496)]
	Global.spawn_items(bread_scene, current_scene,  [Vector2(600, 500), Vector2(500, 500)])
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 439), "win_zone")
	Global.spawn_entity(player_scene, current_scene, Vector2(0, 638))
	Global.spawn_camera(current_scene)
	
	emit_signal("level_ready")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
