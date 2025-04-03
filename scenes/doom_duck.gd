extends CharacterBody2D

signal health_changed(new_health, max_health)
signal boss_defeated

# Movement parameters
@export var speed: float = 150.0
@export var jump_velocity: float = -400.0

# Health parameters
@export var max_health: int = 500  # Total health is 500
var minimum_health: int = 100
var current_health: int = max_health
@export var damage_per_hit: int = 10  # 5 damage when goose jumps on head
@export var body_bullet_damage: int = 1  # 1 damage per bullet hit to body
@export var head_bullet_damage: int = 100# 3 damage per bullet hit to head
@export var damage_cooldown: float = 0.5  # Time in seconds before taking damage again
var can_take_damage: bool = true
var head_hit_cooldown: bool = false  # Specific cooldown for head hits
var has_transformed: bool = false  # Flag to track if transformation has occurred

# State variables
enum State {IDLE, CHASE, JUMP, HURT, DEFEATED, RAGE, GOLDEN}
var current_state: State = State.IDLE
var player_detected: bool = false
var player: Node2D = null
var facing_right: bool = false
var previous_facing_right: bool = false  # Track previous direction

# Physics
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Scene preloads
var duck_scene = preload("res://scenes/duck.tscn")
var egg_scene = preload("res://scenes/goldEgg.tscn")  # Preload the egg scene

@export var spawn_cooldown: float = 1
@export var spawn_distance: float = 80.0  # Increased distance to ensure no collision
var can_spawn: bool = true

# Rage mode variables
var rage_mode: bool = false
var rage_timer: float = 0.0
var rage_duration: float = 5.0  # Rage mode lasts 5 seconds
var golden_mode: bool = false

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var body_collision: CollisionShape2D = $body
@onready var head_collision: CollisionShape2D = $head
@onready var health_bar: ProgressBar = $HealthBar/ProgressBar
@onready var gold_egg: Sprite2D = $goldEgg

# Original egg position
var original_egg_position_x: float = 0
var original_egg_position_y: float = 0

# Flag to track if gold egg has been spawned
var gold_egg_spawned: bool = false

func _ready() -> void:
	# Initialize health and UI
	current_health = max_health
	_update_health_bar()
	
	# Store original egg position
	original_egg_position_x = gold_egg.position.x
	original_egg_position_y = gold_egg.position.y
	
	# Connect signals
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	# Connect animation frame changed signal
	animated_sprite.connect("frame_changed", Callable(self, "_on_animated_sprite_frame_changed"))
	
	# Add to enemy group so bullets can detect it
	add_to_group("enemy")
	
	# Start in idle state
	_change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Check if facing direction changed
	if facing_right != previous_facing_right:
		_update_egg_x_position()
		previous_facing_right = facing_right
	

	if rage_mode:
		rage_timer += delta
		if rage_timer >= rage_duration:
			_transform_to_golden()
	
	match current_state:
		State.IDLE:
			velocity.x = 0
			if player_detected and !rage_mode:
				_change_state(State.CHASE)
		
		State.CHASE:
			if player and is_instance_valid(player):
				_chase_player()
			else:
				_change_state(State.IDLE)
		
		State.JUMP:
			if is_on_floor():
				_change_state(State.CHASE if !rage_mode else State.RAGE)
		
		State.HURT:
			velocity.x = 0
			
		State.RAGE:
			velocity.x = 0
			# Rage state is handled by animation
			
		State.GOLDEN:
			if player and is_instance_valid(player):
				_chase_player()
			else:
				_change_state(State.IDLE)
		
		State.DEFEATED:
			# Boss is defeated, no movement
			velocity.x = 0
	
	# Move
	move_and_slide()
	
	# Check for collisions with the player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.name == "goose":
			var collision_point = collision.get_position()
			var local_point = to_local(collision_point)
			
			if local_point.y < head_collision.position.y:
				_on_head_collision(collider)
			else:
				_on_body_collision(collider)

func _update_egg_x_position() -> void:
	# When the duck changes direction, update the egg's X position
	if facing_right:
		gold_egg.position.x = 180  # X position when facing right
	else:
		gold_egg.position.x = original_egg_position_x  # Reset to original X position when facing left

func _on_animated_sprite_frame_changed() -> void:
	# Only update egg position if it's visible
	if !gold_egg.visible:
		return
		
	# Sync golden egg with animation frames
	if animated_sprite.animation == "rage":
		# Use the specific positions for rage animation
		var positions = [-11, -20, -27, -40]
		gold_egg.position.y = positions[animated_sprite.frame % positions.size()]
	elif animated_sprite.animation == "idle":
		var positions = [0, -2, -4, -2]
		gold_egg.position.y = positions[animated_sprite.frame % positions.size()]
	elif animated_sprite.animation == "walk":
		var positions = [0, -3, 0, -3]
		gold_egg.position.y = positions[animated_sprite.frame % positions.size()]
	elif animated_sprite.animation == "jump":
		# Add Y offset for jump animation
		var base_y_offset = 20
		if golden_mode:
			base_y_offset = 40
		
		var positions = [-5 + base_y_offset, -8 + base_y_offset]
		gold_egg.position.y = positions[animated_sprite.frame % positions.size()]
	elif animated_sprite.animation == "hurt":
		var positions = [-2, -5]
		gold_egg.position.y = positions[animated_sprite.frame % positions.size()]
	elif animated_sprite.animation == "defeated":
		var positions = [0, 5, 10, 15]
		gold_egg.position.y = positions[min(animated_sprite.frame, positions.size() - 1)]

func start_falling(body: String = "") -> void:
	var damage = 0
	if body == "bullet":
		damage = 1
	elif body == "fireball":
		damage = 5
	
	if damage > 0:
		var bullet = get_tree().get_first_node_in_group("_last_bullet")
		if bullet:
			var local_bullet_pos = to_local(bullet.global_position)
			
			if local_bullet_pos.y < head_collision.position.y:
				# Head hit - 2 damage
				take_bullet_damage(damage * head_bullet_damage)
			else:
				# Body hit - 1 damage
				take_bullet_damage(damage * body_bullet_damage)
		else:
			take_bullet_damage(body_bullet_damage)

func _chase_player() -> void:
	if not player or not is_instance_valid(player) or current_state == State.DEFEATED:
		_change_state(State.IDLE)
		return
	
	var direction = player.global_position.x - global_position.x
	facing_right = direction > 0
	animated_sprite.flip_h = facing_right
	
	# Set the direction of movement with speed boost if in golden mode
	var current_speed = speed * (2.0 if golden_mode else 1.0)
	velocity.x = current_speed if facing_right else -current_speed
	
	# Randomly jump sometimes with higher jump if in golden mode
	if is_on_floor() and randf() < 0.01:  # 1% chance per frame to jump
		_jump()
	
	# Try to spawn ducks
	if can_spawn and randf() < 0.005:  # 0.5% chance per frame to spawn ducks
		_spawn_duck()
		
		# Spawn second duck if in golden mode
		if golden_mode:
			await get_tree().create_timer(0.1).timeout
			_spawn_duck()

func _jump() -> void:
	if is_on_floor() and current_state != State.DEFEATED and current_state != State.RAGE:
		_change_state(State.JUMP)
		var current_jump_velocity = jump_velocity * (2.0 if golden_mode else 1.0)
		velocity.y = current_jump_velocity

func _spawn_duck() -> void:
	if not can_spawn or current_state == State.DEFEATED:
		return
	
	can_spawn = false
	
	# Create duck instance
	var duck = duck_scene.instantiate()
	
	# Set the override animation to "evilDuck" before adding to scene
	duck.override_animation = "evilDuck"
	
	# Calculate the duck's spawn position
	# Get the boss's collision shape width
	var boss_width = 0
	if body_collision and body_collision.shape:
		if body_collision.shape is RectangleShape2D:
			boss_width = body_collision.shape.size.x
		elif body_collision.shape is CircleShape2D:
			boss_width = body_collision.shape.radius * 2
		elif body_collision.shape is CapsuleShape2D:
			boss_width = body_collision.shape.radius * 2
	
	# Get the duck's collision shape width (approximate)
	var duck_width = 0
	var duck_collision = duck.get_node_or_null("CollisionShape2D")
	if duck_collision and duck_collision.shape:
		if duck_collision.shape is RectangleShape2D:
			duck_width = duck_collision.shape.size.x
		elif duck_collision.shape is CircleShape2D:
			duck_width = duck_collision.shape.radius * 2
		elif duck_collision.shape is CapsuleShape2D:
			duck_width = duck_collision.shape.radius * 2
	
	# Calculate minimum safe distance (half boss width + half duck width + extra space)
	var min_distance = (boss_width/2 + duck_width/2 + 20)
	
	# Find the ground level below the boss
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 500))
	query.collision_mask = 1  # Layer for ground/platforms
	var result = space_state.intersect_ray(query)
	
	var ground_y = global_position.y
	if result:
		ground_y = result.position.y - 20  # 20 pixels above ground
	
	# Spawn the duck at the ground level
	var spawn_offset = Vector2(max(spawn_distance, min_distance) * (1 if facing_right else -1), 0)
	
	# Add the duck to the scene first so its properties can be modified
	get_parent().add_child(duck)
	
	# Position the duck in front of the boss at ground level
	duck.global_position = Vector2(global_position.x + spawn_offset.x, ground_y)
	
	# Set duck direction to match boss facing direction
	duck.direction = Vector2.RIGHT if facing_right else Vector2.LEFT
	
	# Flip the sprite if needed
	if duck.has_node("AnimatedSprite2D"):
		duck.get_node("AnimatedSprite2D").flip_h = facing_right
	
	# Start cooldown timer
	var timer = get_tree().create_timer(spawn_cooldown)
	await timer.timeout
	can_spawn = true

func _spawn_golden_egg() -> void:
	# Only spawn the gold egg once
	if gold_egg_spawned:
		return
		
	gold_egg_spawned = true
	
	# Create egg instance
	var egg = egg_scene.instantiate()
	
	# Add the egg to the scene
	get_parent().add_child(egg)
	
	# Position the egg where the boss died
	egg.global_position = global_position
	
	# Print debug message
	print("Golden egg spawned at position: ", global_position)

func take_bullet_damage(damage_amount: int) -> void:
	if current_state == State.DEFEATED:
		return
	
	# Don't take damage during rage animation
	if rage_mode:
		return
	
	current_health -= damage_amount
	_update_health_bar()
	
	# Flash effect
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	if golden_mode:
		animated_sprite.modulate = Color(1.0, 0.84, 0.0)  # Brighter gold color
	else:
		animated_sprite.modulate = Color(1, 1, 1)
	
	# Check if we should enter rage mode
	if current_health <= 100 and !rage_mode and !golden_mode:
		_enter_rage_mode()
	elif current_health <= 0:
		_defeat()

# Normal damage function (with cooldown) for player hits
func take_damage(damage_amount: int = -1) -> void:
	if current_state == State.DEFEATED or not can_take_damage:
		return
	
	# Don't take damage during rage animation
	if rage_mode:
		return
		
	can_take_damage = false

	var actual_damage = damage_amount if damage_amount > 0 else damage_per_hit
	
	current_health -= actual_damage
	_update_health_bar()
	
	_change_state(State.HURT)
	
	# Flash effect
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.2).timeout
	if golden_mode:
		animated_sprite.modulate = Color(1.0, 0.84, 0.0)  # Brighter gold color
	else:
		animated_sprite.modulate = Color(1, 1, 1)
	
	# Check if we should enter rage mode
	if current_health <= 100 and !rage_mode and !golden_mode:
		_enter_rage_mode()
	elif current_health <= 0:
		_defeat()
	else:
		# Return to chase after hurt animation
		await get_tree().create_timer(0.5).timeout
		if current_state == State.HURT:
			if rage_mode:
				_change_state(State.RAGE)
			else:
				_change_state(State.CHASE if player_detected else State.IDLE)
	
	# Reset damage cooldown
	await get_tree().create_timer(damage_cooldown).timeout
	can_take_damage = true

func _enter_rage_mode() -> void:
	rage_mode = true
	rage_timer = 0.0  # Reset the rage timer
	_change_state(State.RAGE)
	
	print("Entering rage mode - will transform in 5 seconds")

func _transform_to_golden() -> void:
	# Only transform once
	if has_transformed:
		return
		
	print("Transforming to golden mode!")
	has_transformed = true
	golden_mode = true
	rage_mode = false  # End rage mode
	
	# Hide the golden egg - it's now absorbed into the duck
	gold_egg.visible = false
	
	# Add 1000 health
	max_health += 1000
	current_health += 1000
	minimum_health = 0
	_update_health_bar()
	
	# Change color to a brighter gold
	animated_sprite.modulate = Color(1.0, 0.84, 0.0)  # Brighter gold color
	
	# Return to chase state with enhanced abilities
	if player and is_instance_valid(player):
		player_detected = true
		_change_state(State.GOLDEN)
	else:
		_change_state(State.IDLE)

func _defeat() -> void:
	_change_state(State.DEFEATED)
	
	animated_sprite.play("defeated")
	
	body_collision.set_deferred("disabled", true)
	head_collision.set_deferred("disabled", true)
	
	# Spawn golden egg if we were in golden mode
	if golden_mode:
		_spawn_golden_egg()
	
	# Emit signal
	emit_signal("boss_defeated")
	
	# Optional: fade out and remove
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.tween_callback(Callable(self, "queue_free"))

func _update_health_bar() -> void:
	current_health = max(current_health, minimum_health)
	emit_signal("health_changed", current_health, max_health)

func _change_state(new_state: State) -> void:
	# Only block state changes during rage mode, not after transformation
	if rage_mode and new_state != State.RAGE and new_state != State.DEFEATED:
		return
		
	current_state = new_state
	
	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.CHASE:
			animated_sprite.play("walk")
		State.JUMP:
			animated_sprite.play("jump")
		State.HURT:
			animated_sprite.play("hurt")
		State.RAGE:
			animated_sprite.play("rage")
		State.GOLDEN:
			animated_sprite.play("walk")
		State.DEFEATED:
			animated_sprite.play("defeated")

func _on_detection_area_body_entered(body: Node) -> void:
	if body.name == "goose" and current_state != State.DEFEATED and !rage_mode:
		player_detected = true
		player = body
		_change_state(State.CHASE if !golden_mode else State.GOLDEN)

func _on_detection_area_body_exited(body: Node) -> void:
	if body.name == "goose":
		player_detected = false
		player = null
		# Give a small delay before returning to idle
		await get_tree().create_timer(1.0).timeout
		if not player_detected and current_state != State.DEFEATED and !rage_mode:
			_change_state(State.IDLE)

func _on_head_collision(collider: Node) -> void:
	if head_hit_cooldown or rage_mode:
		if collider.has_method("bounce"):
			collider.bounce()
		return
	
	# Check if the goose is actively jumping (falling downward)
	var is_jumping_on_head = false
	if collider.has_method("is_jumping"):
		is_jumping_on_head = collider.is_jumping()
	else:
		# Fallback check: if the player's Y velocity is positive (falling)
		if collider is CharacterBody2D and collider.velocity.y > 0:
			is_jumping_on_head = true
	
	head_hit_cooldown = true
	
	if is_jumping_on_head:
		take_damage()
	
	if collider.has_method("bounce"):
		collider.bounce()
	
	await get_tree().create_timer(0.5).timeout
	head_hit_cooldown = false

func _on_body_collision(collider: Node) -> void:
	if collider.has_method("game_over"):
		collider.game_over(2)  # 2 is LOSE
	else:
		var death_screen = get_tree().get_nodes_in_group("death_screen")
		if death_screen.size() > 0:
			death_screen[0].set_game_over_state(2)  # 2 is LOSE
