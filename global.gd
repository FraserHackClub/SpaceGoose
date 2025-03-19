extends Node

signal level_changed(level_index)

const Camera2d: PackedScene = preload("res://scenes/camera_2d.tscn")
const MainCharacter: PackedScene = preload("res://scenes/main_character.tscn")

#REFERENCES:
var bullet_counter: Label = null  # Store reference to BulletCountLabel
var player_gun: Node = null  # Stores reference to the player's gun
var main_character: Node2D = null  # Stores reference to the Player

var player_gun_path: NodePath = "PlayerGun"  # Default relative path


# Array containing paths to the level scenes in order
var level_paths = [
	"res://scenes/worlds/world_1-1.tscn",
	"res://scenes/worlds/world_1-2.tscn"
]

var current_level_index = -1
var current_level = null

# Function to check if a level exists at the given index
func has_level(level_index):
	return level_index >= 0 and level_index < level_paths.size()

# Function to change to the next level
func change_level(level_index):
	if has_level(level_index):
		switch_level(level_index)
		return true
	return false

# Function to switch to a specific level by index
func switch_level(level_index):
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		var success = main.load_level(level_index)
		if success:
			current_level_index = level_index
			# Emit signal that level has changed
			emit_signal("level_changed", level_index)
		return success
	else:
		push_error("Main scene not found!")
		return false

# Restart game and load current level
func restart_game():
	# Store the current level index
	var current_index = current_level_index
	print("Restarting level with index: ", current_index)
	
	# First, remove any game over screens that might be present
	remove_game_over_screens()
	
	# If we're in a level, use switch_level to properly reload it
	if has_level(current_index):
		switch_level(current_index)
	else:
		# Fallback to reloading the current scene if we're not in a tracked level
		get_tree().reload_current_scene()

# Helper function to remove any game over screens
func remove_game_over_screens():
	var root = get_tree().get_root()
	for child in root.get_children():
		if child.get_name() == "GameOverScreen" or child.is_in_group("game_over_screen"):
			child.queue_free()

func spawn_enemies(scene: PackedScene, parent_scene: Node, pos_list):
	spawn_entities(scene, parent_scene, pos_list, "enemy")

func spawn_items(scene: PackedScene, parent_scene: Node, pos_list):
	spawn_entities(scene, parent_scene, pos_list, "item")

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
	
	# Ensure helmet is hidden by default
	call_deferred("_ensure_helmet_hidden", player)

# Helper function to ensure helmet is hidden when player is spawned
func _ensure_helmet_hidden(player_node):
	if player_node and player_node.has_node("Helmet"):
		var helmet = player_node.get_node("Helmet")
		helmet.visible = false

func spawn_entities(scene: PackedScene, parent_scene: Node, pos_list: Array, type):
	for pos in pos_list:
		spawn_entity(scene, parent_scene, pos, type)

func spawn_entity(scene: PackedScene, parent_scene: Node, pos: Vector2, type=null):
	var entity = scene.instantiate()
	entity.position = pos
	if type is String:
		entity.add_to_group(type)
	parent_scene.add_child(entity)
	print("Spawned entity:", entity, "at", pos)  # Debugging
	
func get_random_element(array: Array, rng: RandomNumberGenerator, amount: int = 0):
	if amount <= 0:
		return []
	
	var array_copy = array.duplicate()
	if array_copy.size() <= amount:
		array_copy.shuffle()
		return array_copy
	
	var result_array = []
	
	for _i in range(amount):
		var random_index = rng.randi_range(0, array_copy.size() - 1)
		result_array.append(array_copy[random_index])
		array_copy.remove_at(random_index)
	
	return result_array
