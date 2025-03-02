extends Node

const Camera2d: PackedScene = preload("res://scenes/camera_2d.tscn")

# Restart game and load main scene
#func restart_game():
	#get_tree().change_scene_to_file("res://main.tscn")  # ✅ Replace with your main scene path
		# Hide the death screen before restarting (if needed)
		
func restart_game():
	get_tree().reload_current_scene()
	# If the death screen is persistent, reset its state
	if has_node("GameOverScreen"):
		get_node("GameOverScreen").reset()

func spawn_enemies(scene: PackedScene, parent_scene: Node, pos_list):
	spawn_entities(scene, parent_scene, pos_list, "enemy")

func spawn_items(scene: PackedScene, parent_scene: Node, pos_list):
	spawn_entities(scene, parent_scene, pos_list, "enemy")

func spawn_camera(parent_scene: Node):
	spawn_entity(Camera2d, parent_scene, Vector2(0, 0))

func spawn_entities(scene: PackedScene, parent_scene: Node, pos_list: Array, type):
	for pos in pos_list:
		spawn_entity(scene, parent_scene, pos, type)

func spawn_entity(scene: PackedScene, parent_scene: Node, pos: Vector2, type=null):
	var entity = scene.instantiate()
	entity.position = pos
	if type is String:
		entity.add_to_group(type)
	parent_scene.add_child(entity)
