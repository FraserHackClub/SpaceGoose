extends Node



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

func spawn_entities(scene: PackedScene, parent_scene: Node, pos_list, type):
	for pos in pos_list:
		var entity = scene.instantiate()
		entity.position = pos
		entity.add_to_group(type)
		parent_scene.add_child(entity)
		print(entity)
