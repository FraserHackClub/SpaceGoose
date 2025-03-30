extends CharacterBody2D

@export var speed: float = 200
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1
@export var gravity: float = 980  # Added gravity value

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false
var space_levels = [1, 2, 3]  # Updated to include levels 1-2, 1-3, and 1-4 (indices 1, 2, 3)
var override_animation: String = ""  # New property to override the default animation logic
var is_evil_duck: bool = false  # Flag to identify ducks spawned by Doom Duck

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var goose = $"../goose"

func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))
	
	# Check if we should override the animation
	if override_animation != "":
		animated_sprite.play(override_animation)
		if override_animation == "evilDuck":
			is_evil_duck = true
			# Ensure evil ducks can collide with the ground
			collision_layer = 1  # Make sure collision layer is set correctly
			collision_mask = 1   # Make sure collision mask is set correctly
			
			# Check if we're in a space level and adjust gravity
			var is_space_level = _is_in_space_level()
			if is_space_level:
				gravity = 50  # Low gravity for space levels
			else:
				gravity = 980  # Normal gravity for earth levels
				
			# Ensure the duck is placed on solid ground
			call_deferred("_ensure_on_ground")
	else:
		# Set default animation first
		animated_sprite.play("default")
		
		# Then check for special scenes with a slight delay to ensure scene is fully loaded
		call_deferred("_check_scene")
		
		# Connect to Global's level_changed signal
		Global.connect("level_changed", Callable(self, "_on_level_changed"))
	
	# Set collision mask to ignore doom duck
	# Assuming doom duck is on layer 4 (you may need to adjust this based on your collision layers)
	if not is_evil_duck:
		collision_mask &= ~(1 << 3)  # Remove layer 4 from collision mask

# Function to ensure the duck is placed on solid ground
func _ensure_on_ground() -> void:
	# Wait a frame to make sure the duck is fully initialized
	await get_tree().process_frame
	
	# Cast a ray downward to find the ground
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 500))
	query.collision_mask = 1  # Layer for ground/platforms
	var result = space_state.intersect_ray(query)
	
	if result:
		# Position the duck just above the ground
		global_position.y = result.position.y - 20  # 20 pixels above ground
	else:
		# If no ground found, try to find a platform nearby
		var found_platform = false
		for x_offset in [-100, -50, 0, 50, 100]:
			query = PhysicsRayQueryParameters2D.create(
				global_position + Vector2(x_offset, -50), 
				global_position + Vector2(x_offset, 500)
			)
			result = space_state.intersect_ray(query)
			if result:
				global_position = Vector2(global_position.x, result.position.y - 20)
				found_platform = true
				break
				
		# If still no platform, place at a default safe position
		if not found_platform:
			# Try to find the goose and place the duck at a similar height
			var goose_node = get_node_or_null("../goose")
			if goose_node:
				global_position.y = goose_node.global_position.y - 20

# Function to check if we're in a space level
func _is_in_space_level() -> bool:
	# Check Global first
	if Global.current_level_index in Global.space_level_indices:
		return true
		
	# Check scene name
	var current_scene = get_tree().current_scene
	if current_scene:
		if current_scene.name == "1-2" or current_scene.name == "1-3" or current_scene.name == "1-4":
			return true
			
		# Check scene filename
		var scene_path = current_scene.scene_file_path
		if "1-2" in scene_path or "1-3" in scene_path or "1-4" in scene_path:
			return true
	
	return false

func _on_level_changed(level_index: int) -> void:
	# When the level changes, update our animation based on the level index
	# Only update if we're not using an override animation
	if override_animation == "":
		call_deferred("_update_animation_for_level", level_index)

func _update_animation_for_level(level_index: int) -> void:
	# Skip if using override animation
	if override_animation != "":
		return
		
	if level_index in Global.space_level_indices or level_index in space_levels:
		print_debug("Space level detected (index " + str(level_index) + "), playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print_debug("Regular level detected (index " + str(level_index) + "), playing default animation")
		animated_sprite.play("default")

func _check_scene() -> void:
	# Skip if using override animation
	if override_animation != "":
		return
		
	# First check if we can use the Global's current level index
	if Global.current_level_index >= 0:
		_update_animation_for_level(Global.current_level_index)
		return
		
	# Fallback to scene detection if Global doesn't have a valid level index
	# Add null checks
	if get_tree() == null or get_tree().current_scene == null:
		return
		
	var current_scene = get_tree().current_scene
	
	# Try multiple ways to detect the correct scene
	var is_space_level = false
	
	# Method 1: Check scene name directly
	# Updated to include 1-4 in the space levels
	if current_scene.name == "1-2" or current_scene.name == "1-3" or current_scene.name == "1-4":
		is_space_level = true
	
	# Method 2: Check scene filename
	var scene_path = current_scene.scene_file_path if current_scene else ""
	if "1-2" in scene_path or "1-3" in scene_path or "1-4" in scene_path:
		is_space_level = true
	
	# Method 3: Check parent node names for clues
	var parent = get_parent()
	while parent:
		if "1-2" in parent.name or "1-3" in parent.name or "1-4" in parent.name:
			is_space_level = true
			break
		parent = parent.get_parent()
	
	# Apply the correct animation
	if is_space_level:
		print_debug("Space level detected through scene detection, playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print_debug("Regular level detected through scene detection, playing default animation")
		animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	if is_falling:
		velocity.y = fall_speed
		move_and_slide()
		return

	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply horizontal movement
	velocity.x = direction.x * speed
	
	# Debug output for evil ducks
	if is_evil_duck and Engine.get_frames_drawn() % 60 == 0:  # Log once per second
		print_debug("Evil Duck position: ", global_position, " velocity: ", velocity)
	
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var normal = collision_info.get_normal()
		if abs(normal.x) > 0.7:
			direction = -direction
			animated_sprite.flip_h = (direction.x > 0)
			break

	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var other = collision_info.get_collider()
		if other and other.name == "goose":
			other.call("game_over", 2)
			break

func _on_top_area_entered(body: Node) -> void:
	if body.name == "goose":
		start_falling()

func start_falling(body: String = "goose") -> void:
	if body == "bullet":
		goose.increase_score(100)
	else:
		goose.increase_score(250)
		
	is_falling = true
	collision_layer = 0
	collision_mask = 0
	sfx_duckfall.play()

	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fall_delete_delay
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fall_timeout"))
	timer.start()

func _on_fall_timeout() -> void:
	queue_free()
