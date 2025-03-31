extends CharacterBody2D

@export var speed: float = 200
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false
var space_levels = [1, 2, 3]  # Updated to include levels 1-2, 1-3, and 1-4 (indices 1, 2, 3)

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var goose = Global.main_character

func _ready() -> void:
	print_debug("Duck script _ready() called. Global.main_character:", goose)
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))
	
	# Set default animation first
	animated_sprite.play("default")
	
	# Then check for special scenes with a slight delay to ensure scene is fully loaded
	call_deferred("_check_scene")
	
	# Connect to Global's level_changed signal
	Global.connect("level_changed", Callable(self, "_on_level_changed"))

func _on_level_changed(level_index: int) -> void:
	print_debug("Duck script received level_changed signal. Level index:", level_index)
	# When the level changes, update our animation based on the level index
	call_deferred("_update_animation_for_level", level_index)

func _update_animation_for_level(level_index: int) -> void:
	if level_index in Global.space_level_indices or level_index in space_levels:
		print_debug("Space level detected (index " + str(level_index) + "), playing spaceDuck animation")
		animated_sprite.play("spaceDuck")
	else:
		print_debug("Regular level detected (index " + str(level_index) + "), playing default animation")
		animated_sprite.play("default")

func _check_scene() -> void:
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
		animated_sprite.play("spaceDuck")
	else:
		animated_sprite.play("default")

func start_falling(body: String = "goose") -> void:
	print_debug("start_falling() called. Body:", body)
	if goose == null:
		print_debug("Error: Global.main_character is not set or is null.")
		return

	if not goose.has_method("increase_score"):
		print_debug("Error: Goose instance does not have 'increase_score()' method.")
		return

	if body == "bullet":
		goose.increase_score(100)
	elif body == "fireball":
		goose.increase_score(150)
		modulate = Color.RED
	elif body == "invincible":
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

func _on_top_area_entered(body: Node) -> void:
	print_debug("_on_top_area_entered() called. Body:", body)
	if body.name == "goose":
		start_falling()

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


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "goose":
		if body.invincible:
			start_falling("invincible")
