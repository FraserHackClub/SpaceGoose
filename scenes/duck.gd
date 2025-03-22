extends CharacterBody2D

@export var speed: float = 200
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false
var space_levels = [1, 2]  # Array of level indices that should use the space duck animation

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))
	
	# Set default animation first
	animated_sprite.play("default")
	
	# Then check for special scenes with a slight delay to ensure scene is fully loaded
	call_deferred("_check_scene")
	
	# Connect to Global's level_changed signal
	Global.connect("level_changed", Callable(self, "_on_level_changed"))

func _on_level_changed(level_index: int) -> void:
	# When the level changes, update our animation based on the level index
	call_deferred("_update_animation_for_level", level_index)

func _update_animation_for_level(level_index: int) -> void:
	if level_index in Global.space_level_indices:
		print_debug("Space level detected (index 1), playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print_debug("Regular level detected (index " + str(level_index) + "), playing default animation")
		animated_sprite.play("default")

func _check_scene() -> void:
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
	# Fix the logical error in the original code
	if current_scene.name == "1-2" or current_scene.name == "1-3":
		is_space_level = true
	
	# Method 2: Check scene filename
	var scene_path = current_scene.scene_file_path if current_scene else ""
	if "1-2" in scene_path or "1-3" in scene_path:
		is_space_level = true
	
	# Method 3: Check parent node names for clues
	var parent = get_parent()
	while parent:
		if "1-2" in parent.name or "1-3" in parent.name:
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

func _physics_process(_delta: float) -> void:
	if is_falling:
		velocity = Vector2(0, fall_speed)
		move_and_slide()
		return

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
		start_falling()

func start_falling() -> void:
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
