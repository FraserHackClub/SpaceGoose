extends CharacterBody2D

@export var speed: float = 200
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))
	
	# Set default animation first
	animated_sprite.play("default")
	
	# Then check for special scenes with a slight delay to ensure scene is fully loaded
	call_deferred("_check_scene")
	
	# Connect to scene tree signals to handle scene changes
	if get_tree() != null:
		get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_node_added(node: Node) -> void:
	# Add proper null checks
	if node == null or get_tree() == null or get_tree().current_scene == null:
		return
		
	# When new nodes are added to the tree, check if we need to update our animation
	if node == get_tree().current_scene:
		call_deferred("_check_scene")

func _check_scene() -> void:
	# Add null checks
	if get_tree() == null or get_tree().current_scene == null:
		return
		
	var current_scene = get_tree().current_scene
	
	# Try multiple ways to detect the correct scene
	var is_space_level = false
	
	# Method 1: Check scene name directly
	if current_scene.name == "1-2":
		is_space_level = true
	
	# Method 2: Check scene filename
	var scene_path = current_scene.scene_file_path if current_scene else ""
	if "1-2" in scene_path or "space" in scene_path.to_lower():
		is_space_level = true
	
	# Method 3: Check parent node names for clues
	var parent = get_parent()
	while parent:
		if "1-2" in parent.name or "space" in parent.name.to_lower():
			is_space_level = true
			break
		parent = parent.get_parent()
	
	# Apply the correct animation
	if is_space_level:
		print("Space level detected, playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print("Regular level detected, playing default animation")
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
