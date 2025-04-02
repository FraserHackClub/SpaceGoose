extends Node

signal level_changed(level_index)

const Camera2d: PackedScene = preload("res://scenes/camera_2d.tscn")
const MainCharacter: PackedScene = preload("res://scenes/main_character.tscn")

#REFERENCES:
var bullet_counter: Label = null  # Store reference to BulletCountLabel
var player_gun: Node = null  # Stores reference to the player's gun
var main_character: Node2D = null  # Stores reference to the Player
var camera_2d: Camera2D = null
var player_gun_path: NodePath = "PlayerGun"  # Default relative path
var custom_font = load("res://assets/PixeloidMono.ttf")
var piston: CharacterBody2D = null  # Stores reference to the Player
const default_inventory = {
	"items": {
		"egg": 3,
		"bread": 0,
		"apple_juice": 0,
		"orange_juice": 0,
		"grape_juice": 0
	},
	"has_gold_egg": false,
	"score": 0,
	"current_level": 0
}

# Array containing paths to the level scenes in order
var level_paths = [
	"res://scenes/worlds/world_1-1.tscn", #0
	"res://scenes/worlds/world_1-2.tscn", #1
	"res://scenes/worlds/world_1-3.tscn", #2
	"res://scenes/worlds/world_1_4.tscn", #3
	"res://scenes/worlds/world_2-1.tscn", #4
	"res://scenes/worlds/world_2-2.tscn", #5
	"res://scenes/worlds/world_2-2_5.tscn", #6
	"res://scenes/worlds/world_2-3.tscn", #7
	"res://scenes/worlds/world_3-1.tscn", #8
	"res://scenes/worlds/world_4-1.tscn" #9
]

var level_score_reqs = [
	0, 3000, 10000, 25000, 40000, 0, 0, 0, 0, 0
]

var space_level_indices = [
	1, 2, 3, 4, 5, 6
]

var current_level_index = -1
var current_level = null

var helmet_visible_levels = [1,2,3,4,5, 6]

# Chunk management
var terrain_chunk_manager = null

# FPS counter
var fps_canvas_layer = null
var fps_label = null
var show_fps = false
var c_key_pressed = false
@onready var KeyID: float = 0.0
@onready var Collected_Keys: Array = []
func _ready():
	KeyID = 0.0
	get_tree().root.connect("ready", Callable(self, "_on_scene_ready"))


func _process(_delta):
	#print(KeyID)
	# Update FPS counter if visible
	
	if fps_label and show_fps:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Toggle FPS display with C key (only on press, not hold)
	if Input.is_key_pressed(KEY_C):
		if not c_key_pressed:
			c_key_pressed = true
			toggle_fps_display()
	else:
		c_key_pressed = false
		
	for node in get_tree().get_nodes_in_group("CharacterBody2D"):
		if node == null or not is_instance_valid(node):
			continue
		if node.get_script() == null:
			continue
		if node.has_method("get_rid"):
			var rid = node.get_rid()
			if rid == RID():
				print("💥 Null RID on:", node.name, "(", node.get_path(), ")")

func spawn_juice(scene: PackedScene, parent_scene: Node, pos_list: Array):
	# Create a list of juice types
	var juice_types = ["apple", "orange", "grape"]
	
	# Randomize the seed
	randomize()
	
	# Shuffle the juice types to ensure randomness
	juice_types.shuffle()
	
	# Debug: Check available animations in the scene
	var temp_juice = scene.instantiate()
	var temp_sprite = temp_juice.get_node("AnimatedSprite2D")
	if temp_sprite and temp_sprite.sprite_frames:
		print_debug("Available juice animations:", temp_sprite.sprite_frames.get_animation_names())
	temp_juice.queue_free()
	
	# For each position in the list
	for i in range(pos_list.size()):
		var pos = pos_list[i]
		var juice = scene.instantiate()
		juice.position = pos
		
		# Get the AnimatedSprite2D
		var sprite = juice.get_node("AnimatedSprite2D")
		if sprite and sprite.sprite_frames:
			# Choose a juice type - ensure variety when possible
			var type_index = i % juice_types.size()
			var selected_type = juice_types[type_index]
			
			# Verify the animation exists
			if sprite.sprite_frames.has_animation(selected_type):
				# Set the animation directly on the sprite
				sprite.animation = selected_type
				
				# Store the juice type on the node for collection logic
				juice.juice_type = selected_type
				
				print_debug("Set juice type to:", selected_type, "at position:", pos)
			else:
				print_debug("ERROR: Animation", selected_type, "not found! Using default.")
				# List available animations
				print_debug("Available animations:", sprite.sprite_frames.get_animation_names())
				
				# Default to first animation if available
				if sprite.sprite_frames.get_animation_names().size() > 0:
					var default_anim = sprite.sprite_frames.get_animation_names()[0]
					sprite.animation = default_anim
					juice.juice_type = default_anim
		else:
			print_debug("ERROR: AnimatedSprite2D or SpriteFrames not found in juice scene!")
		
		juice.add_to_group("item")
		juice.add_to_group("juice")
		parent_scene.add_child(juice)
		print_debug("Spawned juice:", juice.juice_type, "at", pos)
		
func create_fps_counter():
	# Remove any existing FPS counter first
	remove_fps_counter()

	# Create new canvas layer for FPS counter
	fps_canvas_layer = CanvasLayer.new()
	fps_canvas_layer.name = "FPSDisplayLayer"
	fps_canvas_layer.layer = 100  # Very high layer to be on top
	get_tree().root.add_child(fps_canvas_layer)

	# Create a CenterContainer that will center its children
	var center_container = CenterContainer.new()
	center_container.name = "CenterContainer"
	center_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center_container.offset_top = 10  # Small margin from top
	fps_canvas_layer.add_child(center_container)

	# Create FPS label
	fps_label = Label.new()
	fps_label.name = "FPSCounter"
	fps_label.text = "FPS: 0"

	# Style the FPS counter
	fps_label.add_theme_font_override("font", custom_font)
	fps_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green text
	fps_label.add_theme_font_size_override("font_size", 16)

	# Add label to center container
	center_container.add_child(fps_label)

	# Set visibility based on show_fps
	fps_label.visible = show_fps

	print("FPS counter created. Visibility: " + ("ON" if show_fps else "OFF"))

func remove_fps_counter():
	if fps_canvas_layer != null:
		if is_instance_valid(fps_canvas_layer) and fps_canvas_layer.is_inside_tree():
			fps_canvas_layer.queue_free()
		fps_canvas_layer = null
		fps_label = null

func toggle_fps_display():
	show_fps = !show_fps
	
	# Update label visibility if it exists
	if fps_label:
		fps_label.visible = show_fps
	
	print("FPS display: " + ("ON" if show_fps else "OFF"))
	return show_fps

func _on_scene_ready():
	detect_current_level()
	setup_chunk_managers()
	
	# Ensure FPS counter exists in the new scene
	call_deferred("create_fps_counter")

func detect_current_level():
	var current_scene = get_tree().current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		print("Current scene path: ", scene_path)
		
		for i in range(level_paths.size()):
			if level_paths[i] == scene_path:
				current_level_index = i
				print("Detected level index: ", current_level_index)
				return
		
		print("Warning: Current scene is not in the level_paths array")

func setup_chunk_managers():
	# Clean up existing chunk managers
	if terrain_chunk_manager:
		terrain_chunk_manager.cleanup()
		
	var current_scene = get_tree().current_scene
	if current_scene:
		# Find the Terrain tilemap
		var terrain = find_node_by_name(current_scene, "Terrain")
		if terrain and terrain is TileMap:
			terrain_chunk_manager = ChunkManager.new(terrain)
			print("Created chunk manager for Terrain")
		else:
			print("Terrain tilemap not found")

func has_level(level_index):
	print("current level index >")
	print(level_index)
	return level_index >= 0 and level_index < level_paths.size()

func change_level(level_index):
	print("Attempting to change to level index:", level_index)
	if has_level(level_index):
		current_level_index = level_index
		print("Set current_level_index to:", current_level_index)
		
		#var level_path = level_paths[level_index]
		#print("Loading scene:", level_path)
		
		get_node("/root/Main").load_level(level_index)
		
		#var error = get_tree().change_scene_to_file(level_path)
		#if error == OK:
			#print("Scene loaded successfully")
		emit_signal("level_changed", level_index)
			## Setup chunk managers for the new level
		call_deferred("setup_chunk_managers")
			#return true
		#else:
			#print("Failed to load scene. Error:", error)
			#return false
	else:
		print("Level index out of range:", level_index)
		return false

func change_to_next_level():
	var next_level_index = current_level_index + 1
	KeyID = 0.0
	print("Changing from level", current_level_index, "to", next_level_index)
	return change_level(next_level_index)

func restart_game():
	# Store the current level index
	KeyID = 0.0
	var current_index = current_level_index
	print_debug("Restarting level with index: ", current_index)
	
	# First, remove any game over screens that might be present
	remove_game_over_screens()
	
	# If we're in a level, use switch_level to properly reload it
	if has_level(current_index):
		change_level(current_index)
		print("skibidi")
	else:
		# Fallback to reloading the current scene if we're not in a tracked level
		get_tree().reload_current_scene()

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

func spawn_player(player_scene, parent_scene: Node, pos: Vector2, time: float, jump_velocity: float = -900):
	var player = player_scene.instantiate()
	player.position = pos
	player.time = time
	player.JUMP_VELOCITY = jump_velocity
	parent_scene.add_child(player)
	
	main_character = player
	
	detect_current_level()
	
	call_deferred("update_helmet_visibility")

func update_helmet_visibility():
	print("Updating helmet visibility for level index:", current_level_index)
	
	if main_character and main_character.has_node("Helmet"):
		var helmet = main_character.get_node("Helmet")
		
		if current_level_index in helmet_visible_levels:
			helmet.visible = true
			print("Global: Helmet set to visible for level index:", current_level_index)
		else:
			helmet.visible = false
			print("Global: Helmet set to hidden for level index:", current_level_index)
	else:
		var player = find_player_in_scene()
		if player and player.has_node("Helmet"):
			var helmet = player.get_node("Helmet")
			if current_level_index in helmet_visible_levels:
				helmet.visible = true
				print("Global: Helmet set to visible for level index:", current_level_index)
			else:
				helmet.visible = false
				print("Global: Helmet set to hidden for level index:", current_level_index)
		else:
			print("Global: Could not find player or helmet node")

func find_player_in_scene():
	var current_scene = get_tree().current_scene
	
	var player = current_scene.get_node_or_null("goose")
	if player:
		return player
	
	player = current_scene.get_node_or_null("LevelContainer/goose")
	if player:
		return player
	
	return find_node_by_name(current_scene, "goose")

func find_node_by_name(node, node_name):
	if node.name == node_name:
		return node
	
	for child in node.get_children():
		var found = find_node_by_name(child, node_name)
		if found:
			return found
	
	return null

func set_helmet_visibility(visible: bool):
	if main_character and main_character.has_node("Helmet"):
		var helmet = main_character.get_node("Helmet")
		helmet.visible = visible
		print("Global: Helmet visibility manually set to:", visible)
	else:
		print("Global: Could not find main_character or helmet node")

func toggle_helmet_visibility():
	if main_character and main_character.has_node("Helmet"):
		var helmet = main_character.get_node("Helmet")
		helmet.visible = !helmet.visible
		print("Global: Helmet visibility toggled to:", helmet.visible)
	else:
		print("Global: Could not find main_character or helmet node")

func add_helmet_visible_level(level_index: int):
	if level_index not in helmet_visible_levels:
		helmet_visible_levels.append(level_index)
		if current_level_index == level_index:
			update_helmet_visibility()

func remove_helmet_visible_level(level_index: int):
	if level_index in helmet_visible_levels:
		helmet_visible_levels.erase(level_index)
		if current_level_index == level_index:
			update_helmet_visibility()

func spawn_entities(scene: PackedScene, parent_scene: Node, pos_list: Array, type):
	for pos in pos_list:
		spawn_entity(scene, parent_scene, pos, type)

func spawn_entity(scene: PackedScene, parent_scene: Node, pos: Vector2, type=null):
	var entity = scene.instantiate()
	entity.position = pos
	if type is String:
		entity.add_to_group(type)
	parent_scene.add_child(entity)
	print_debug("Spawned entity:", entity, "at", pos)  # Debugging
	
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

# ChunkManager class for optimizing tilemap performance
class ChunkManager:
	const CHUNK_SIZE = 64
	const ACTIVE_RADIUS = 3  # Number of chunks to keep active around player
	
	var active_chunks = {}
	var tilemap: TileMap
	var player_position = Vector2.ZERO
	var is_processing = true
	var last_player_chunk = Vector2i(0, 0)
	var update_frequency = 0.5  # Update every 0.5 seconds
	var time_since_last_update = 0.0
	
	func _init(parent_tilemap: TileMap):
		tilemap = parent_tilemap
		convert_to_chunks()
		
		# Connect to process callback
		if Engine.get_main_loop():
			Engine.get_main_loop().process_frame.connect(self._process)
	
	func _process(delta = 0.0):
		if !is_processing or !tilemap or !tilemap.is_inside_tree():
			return
		
		# Only update periodically to improve performance
		time_since_last_update += delta
		if time_since_last_update < update_frequency:
			return
			
		time_since_last_update = 0.0
		
		# Update player position
		var player = find_player()
		if player:
			player_position = player.global_position
			update_active_chunks()
	
	func find_player():
		var root = Engine.get_main_loop().root
		var current_scene = root.get_child(root.get_child_count() - 1)
		
		# Try common player node paths
		var player = current_scene.get_node_or_null("goose")
		if player:
			return player
		
		player = current_scene.get_node_or_null("LevelContainer/goose")
		if player:
			return player
		
		# Recursive search
		return find_node_by_name(current_scene, "goose")
	
	func find_node_by_name(node, name):
		if node.name == name:
			return node
		
		for child in node.get_children():
			var found = find_node_by_name(child, name)
			if found:
				return found
		
		return null
	
	func convert_to_chunks():
		if !tilemap:
			push_error("TileMap not found!")
			return
			
		var all_tiles = []
		var cells = tilemap.get_used_cells(0)
		
		for cell in cells:
			all_tiles.append(cell)
		
		for cell in all_tiles:
			var chunk_pos = Vector2i(
				int(floor(float(cell.x) / CHUNK_SIZE)),
				int(floor(float(cell.y) / CHUNK_SIZE))
			)
			
			var chunk_key = str(chunk_pos)
			
			if !active_chunks.has(chunk_key):
				create_chunk(chunk_pos)
	
	func create_chunk(chunk_pos: Vector2i):
		var chunk_key = str(chunk_pos)
		
		if active_chunks.has(chunk_key):
			return
			
		active_chunks[chunk_key] = {
			"position": chunk_pos,
			"active": false,  # Start as inactive
			"cells": []
		}
		
		# Store cells in this chunk
		var start_x = chunk_pos.x * CHUNK_SIZE
		var start_y = chunk_pos.y * CHUNK_SIZE
		
		for x in range(start_x, start_x + CHUNK_SIZE):
			for y in range(start_y, start_y + CHUNK_SIZE):
				var cell = Vector2i(x, y)
				if tilemap.get_cell_source_id(0, cell) >= 0:
					active_chunks[chunk_key].cells.append(cell)
		
		print_verbose("Created terrain chunk at: ", chunk_pos, " with ", active_chunks[chunk_key].cells.size(), " cells")
	
	func update_active_chunks():
		if !tilemap or !tilemap.is_inside_tree():
			return
			
		var player_chunk_x = int(floor(player_position.x / (CHUNK_SIZE * tilemap.scale.x)))
		var player_chunk_y = int(floor(player_position.y / (CHUNK_SIZE * tilemap.scale.y)))
		var player_chunk = Vector2i(player_chunk_x, player_chunk_y)
		
		# Skip if player hasn't moved to a new chunk
		if player_chunk == last_player_chunk:
			return
			
		last_player_chunk = player_chunk
		
		# Activate chunks near player, deactivate far chunks
		for chunk_key in active_chunks.keys():
			var chunk = active_chunks[chunk_key]
			var distance = chunk.position.distance_to(player_chunk)
			
			if distance <= ACTIVE_RADIUS:
				if !chunk.active:
					activate_chunk(chunk_key)
			else:
				if chunk.active:
					deactivate_chunk(chunk_key)
	
	func activate_chunk(chunk_key):
		if !active_chunks.has(chunk_key) or !tilemap:
			return
			
		var chunk = active_chunks[chunk_key]
		chunk.active = true
		
		# Make cells in this chunk visible
		for cell in chunk.cells:
			var source_id = tilemap.get_cell_source_id(0, cell)
			if source_id >= 0:  # Only set if there's actually a tile
				tilemap.set_cell(0, cell, source_id, 
					tilemap.get_cell_atlas_coords(0, cell))
	
	func deactivate_chunk(chunk_key):
		if !active_chunks.has(chunk_key) or !tilemap:
			return
			
		var chunk = active_chunks[chunk_key]
		chunk.active = false
		
		# Hide cells in this chunk to save performance
		for cell in chunk.cells:
			tilemap.erase_cell(0, cell)
	
	func cleanup():
		is_processing = false
		
		# Disconnect from process callback
		if Engine.get_main_loop() and Engine.get_main_loop().process_frame.is_connected(self._process):
			Engine.get_main_loop().process_frame.disconnect(self._process)
		
		# Restore all cells before cleanup
		if tilemap and tilemap.is_inside_tree():
			for chunk_key in active_chunks.keys():
				var chunk = active_chunks[chunk_key]
				for cell in chunk.cells:
					if !chunk.active:
						# Restore hidden cells
						var source_id = tilemap.get_cell_source_id(0, cell)
						if source_id >= 0:
							tilemap.set_cell(0, cell, source_id, 
								tilemap.get_cell_atlas_coords(0, cell))
		
		active_chunks.clear()
