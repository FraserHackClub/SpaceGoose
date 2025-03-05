extends Node

func load_level(level_path):
	get_tree().call_deferred("change_scene_to_file", level_path)

func _ready() -> void:
	load_level("res://scenes/worlds/world_1-1.tscn")
