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

# Health system for evil ducks
var health: int = 1  # Regular ducks have 1 health
var max_health: int = 1  # Store the maximum health for reference
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
var invulnerability_duration: float = 0.2  # Brief invulnerability after being hit
var hit_count: int = 0  # Track hits for debugging

signal duck_hit(source)  # Signal emitted when duck is hit

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var goose = get_node_or_null("../goose")

@onready var goose = Global.main_character

func _ready() -> void:
	print_debug("Duck script _ready() called. Global.main_character:", goose)
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))
	
	# Add to duck group for easier detection
	add_to_group("duck")
	
	# IMPORTANT: Check if this is an evil duck FIRST before anything else
	# This ensures evil ducks are properly identified regardless of how they're created
	if "evil" in name.to_lower():
		print("Evil duck detected by name: " + name)
		is_evil_duck = true
		health = 5
		max_health = 5
	
	# Check if we should override the animation
	if override_animation != "":
		print("Duck using override animation: " + override_animation)
		animated_sprite.play(override_animation)
		if override_animation == "evilDuck":
			is_evil_duck = true
			# Evil ducks have more health
			health = 5
			max_health = 5
			print("Evil duck created with health: " + str(health))
			
			# Ensure evil ducks can collide with the ground
			collision_layer = 1
			collision_mask = 1
			
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
		if Global.has_signal("level_changed"):
			Global.connect("level_changed", Callable(self, "_on_level_changed"))
	
	# Set collision mask to ignore doom duck
	if not is_evil_duck:
		collision_mask &= ~(1 << 3)  # Remove layer 4 from collision mask
	
	# Additional check for evil ducks based on appearance
	if animated_sprite.animation == "evilDuck":
		is_evil_duck = true
		health = 5
		max_health = 5
		print("Evil duck identified by animation: " + str(animated_sprite.animation))
	
	# Final debug output
	print("Duck initialized: " + name + " | Evil: " + str(is_evil_duck) + " | Health: " + str(health) + " | Animation: " + str(animated_sprite.animation))

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
	print_debug("Duck script received level_changed signal. Level index:", level_index)
	# When the level changes, update our animation based on the level index
	# Only update if we're not using an override animation
	if override_animation == "":
		call_deferred("_update_animation_for_level", level_index)

func _update_animation_for_level(level_index: int) -> void:
	# Skip if using override animation
	if override_animation != "":
		return
		
	if level_index in Global.space_level_indices or level_index in space_levels:
		print("Space level detected (index " + str(level_index) + "), playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print("Regular level detected (index " + str(level_index) + "), playing default animation")
		animated_sprite.play("default")

func _check_scene() -> void:
	# Skip if using override animation
	if override_animation != "":
		return
		
	print_debug("Checking scene. Global.main_character:", goose)
	# First check if we can use the Global's current level index
	if Global.current_level_index >= 0:
		_update_animation_for_level(Global.current_level_index)
		return
	
	if get_tree() == null or get_tree().current_scene == null:
		return
	
	var current_scene = get_tree().current_scene
	print_debug("Current scene name:", current_scene.name)

	var is_space_level = false

	if current_scene.name in ["1-2", "1-3", "1-4"]:
		is_space_level = true

	if is_space_level:
		print("Space level detected through scene detection, playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print("Regular level detected through scene detection, playing default animation")
		animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	# Handle invulnerability timer
	if is_invulnerable:
		invulnerability_timer += delta
		if invulnerability_timer >= invulnerability_duration:
			is_invulnerable = false
			invulnerability_timer = 0.0
			# Reset flash effect
			modulate = Color(1, 1, 1, 1)
	
	if is_falling:
		velocity.y = fall_speed
		move_and_slide()
		return

	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply horizontal movement
	velocity.x = direction.x * speed
	
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
		if is_evil_duck:
			# Evil ducks take damage from jumps
			take_damage(1, "jump")
			
			# Make the player bounce regardless of whether duck dies
			if body.has_method("bounce"):
				body.bounce()
		else:
			# Regular ducks die in one hit
			start_falling()

# This is a special function just for bullets to call
# It ensures proper damage handling for evil ducks
func bullet_hit() -> void:
	hit_count += 1
	print("BULLET HIT FUNCTION CALLED! Duck: " + name + " | Evil: " + str(is_evil_duck) + " | Hit count: " + str(hit_count) + " | Health: " + str(health))
	
	# CRITICAL FIX: Always use take_damage and never call start_falling directly for evil ducks
	take_damage(1, "bullet")

# Function to handle damage for all ducks
func take_damage(amount: int, source: String = "") -> void:
	print("Duck taking damage: " + str(amount) + " from: " + source + 
				" | Current health: " + str(health) + 
				" | Is evil: " + str(is_evil_duck))
	
	# Emit the duck_hit signal
	emit_signal("duck_hit", source)
	
	# CRITICAL FIX: Check is_evil_duck first and handle separately
	if is_evil_duck:
		# Don't take damage during invulnerability frames
		if is_invulnerable:
			print("Duck is invulnerable, ignoring damage")
			return
		
		# Special case: fireballs one-shot evil ducks
		if source == "fireball":
			print("Fireball hit! Instant death")
			health = 0
			start_falling(source)
			return
		
		# Normal damage processing for evil ducks
		health -= amount
		print("Evil duck health after damage: " + str(health) + "/" + str(max_health))
		
		# Set invulnerability
		is_invulnerable = true
		invulnerability_timer = 0.0
		
		# Flash effect to indicate hit
		modulate = Color(1, 0.5, 0.5, 1)
		
		# Only fall when health reaches zero
		if health <= 0:
			print("Evil duck died from damage")
			start_falling(source)
		else:
			# Play hit animation or feedback
			animated_sprite.modulate = Color(1, 0.5, 0.5)
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 0.2)
	else:
		# Regular ducks just die immediately
		print("Regular duck hit - dying immediately")
		start_falling(source)

func start_falling(source: String = "goose") -> void:
	# Duck is already falling
	if is_falling:
		return
	
	print("Duck starting to fall: " + name + " | Source: " + source)
	
	# Award points based on how the duck was defeated
	if goose and goose.has_method("increase_score"):
		if source == "bullet":
			goose.increase_score(100)
		elif source == "fireball":
			goose.increase_score(150)
			modulate = Color.RED
		elif source == "invincible":
			goose.increase_score(500)
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

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "goose":
		if body.invincible:
			start_falling("invincible")
