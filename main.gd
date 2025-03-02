extends Node


func load_level(level_path):
	get_tree().change_scene_to_file(level_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("res://scenes/worlds/world_1-1.tscn")
	pass # Replace with function body.
