extends Node2D

@export var duck_scene: PackedScene = preload("res://scenes/duck.tscn")
@export var bread_scene: PackedScene = preload("res://scenes/bread.tscn")
@export var egg_scene: PackedScene = preload("res://scenes/egg.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 510)]
	var duck_spawn_locations = [Vector2(1570, 496), Vector2(4550, 480)]
	Global.spawn_items(bread_scene, get_tree().current_scene,  [Vector2(600, 500), Vector2(500, 500)])
	Global.spawn_items(egg_scene, get_tree().current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, get_tree().current_scene, duck_spawn_locations)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
