extends Node

const Camera2d: PackedScene = preload("res://scenes/camera_2d.tscn")
const MainCharacter: PackedScene = preload("res://scenes/main_character.tscn")

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

func spawn_camera(parent_scene: Node, level_length: float):
	var camera = Camera2d.instantiate()
	camera.position = Vector2(0, 0)
	camera.LEVEL_LENGTH = level_length
	parent_scene.add_child(camera)

func spawn_player(player_scene, parent_scene: Node, pos: Vector2, time: float):
	var player = player_scene.instantiate()
	player.position = pos
	player.time = time
	parent_scene.add_child(player)

func spawn_entities(scene: PackedScene, parent_scene: Node, pos_list: Array, type):
	for pos in pos_list:
		spawn_entity(scene, parent_scene, pos, type)

func spawn_entity(scene: PackedScene, parent_scene: Node, pos: Vector2, type=null):
	var entity = scene.instantiate()
	entity.position = pos
	if type is String:
		entity.add_to_group(type)
	parent_scene.add_child(entity)
	
func get_random_element(array: Array, rng: RandomNumberGenerator, amount: int = 0):
	if array.size() <= amount:
		return array
	
	var result_array = []
	
	for _i in range(amount):
		result_array.append(array.pop_at(rng.randi_range(0, array.size() - 1)))
	
	return result_array
