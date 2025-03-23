extends CharacterBody2D

# Meteor properties
@export var initial_fall_speed: float = 200.0  # Starting fall speed
@export var max_fall_speed: float = 800.0      # Maximum fall speed
@export var horizontal_speed: float = -150.0   # Negative for right-to-left movement
@export var horizontal_variance: float = 50.0  # Random variance in horizontal speed
@export var spawn_height: float = -100.0       # Starting Y position (above screen)
@export var level_length: float = 13000.0      # Default level length
@export var spawn_interval_min: float = 2.0    # Minimum time between meteor spawns
@export var spawn_interval_max: float = 5.0    # Maximum time between meteor spawns
@export var max_meteors: int = 10              # Maximum number of meteors on screen

# Explosion properties
@export var explosion_duration: float = 10.0    # How long the explosion particles last
@export var screen_shake_amount: float = 5.0   # How much the screen shakes on impact

# Internal variables
var gravity: float = 980.0
var actual_horizontal_speed: float = 0.0
var game_over_triggered: bool = false
var is_clone: bool = false
var rng = RandomNumberGenerator.new()
var has_landed: bool = false

# References
@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var collision_shape = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var particles = $GPUParticles2D if has_node("GPUParticles2D") else null

# Signals
signal meteor_landed

func _ready() -> void:
	rng.randomize()
	
	# If this is the original meteor (not a clone), make it invisible and start spawning
	if not is_clone:
		visible = false
		if collision_shape != null:
			collision_shape.disabled = true
		call_deferred("start_meteor_spawner")
	else:
		# This is a clone, so initialize it for falling
		# Add some variance to the horizontal speed
		actual_horizontal_speed = horizontal_speed + rng.randf_range(-horizontal_variance, horizontal_variance)
		
		# Initialize velocity
		velocity.y = initial_fall_speed
		velocity.x = actual_horizontal_speed
		
		# Make sure particles are not emitting at start
		if particles:
			particles.emitting = false
			# Make sure particles are visible but not emitting
			particles.modulate.a = 1.0
		
		# Play animation if available
		if animated_sprite != null && animated_sprite.sprite_frames != null:
			if animated_sprite.sprite_frames.has_animation("fall"):
				animated_sprite.play("fall")
			else:
				animated_sprite.play("default")
		
		# Rotate the meteor to match its diagonal trajectory
		var angle = atan2(initial_fall_speed, abs(actual_horizontal_speed))
		rotation = angle - PI/2  # Adjust based on your sprite orientation
		
		# Create an Area2D for detecting player contact after landing
		create_contact_area()

func create_contact_area() -> void:
	# Create an Area2D for detecting player contact after landing
	var area = Area2D.new()
	area.name = "ContactArea"
	add_child(area)
	
	# Create a collision shape for the area that matches the meteor's collision shape
	var area_shape = CollisionShape2D.new()
	area_shape.name = "AreaShape"
	
	# If we have a collision shape, duplicate its shape for the area
	if collision_shape != null and collision_shape.shape != null:
		area_shape.shape = collision_shape.shape.duplicate()
	else:
		# Fallback to a circle shape if no collision shape exists
		var circle = CircleShape2D.new()
		circle.radius = 32  # Default size
		area_shape.shape = circle
	
	area.add_child(area_shape)
	
	# Connect the area's body_entered signal
	area.connect("body_entered", Callable(self, "_on_contact_area_body_entered"))

func _on_contact_area_body_entered(body: Node) -> void:
	if body.name == "goose" and not game_over_triggered:
		game_over_triggered = true
		body.call("game_over", 2)  # 2 is LOSE state
		print("Meteor contact area triggered game over")

func start_meteor_spawner() -> void:
	# Create a timer to spawn meteors periodically
	var spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.wait_time = rng.randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.connect("timeout", Callable(self, "spawn_meteor"))
	add_child(spawn_timer)
	spawn_timer.start()
	
	# Spawn first meteor immediately
	spawn_meteor()

func spawn_meteor() -> void:
	# Check if we've reached the maximum number of meteors
	var current_meteors = get_tree().get_nodes_in_group("meteors")
	if current_meteors.size() >= max_meteors:
		return
	
	# Get the camera position to determine valid spawn area
	var camera = get_viewport().get_camera_2d()
	var camera_position = Vector2.ZERO
	var visible_rect_width = get_viewport_rect().size.x
	
	if camera:
		camera_position = camera.global_position
	
	# For right-to-left diagonal movement, spawn on the right side
	# Calculate a spawn position to the right of the camera view
	var spawn_x = camera_position.x + visible_rect_width + rng.randf_range(100, 300)
	
	# Make sure it's within the level bounds
	spawn_x = min(spawn_x, level_length)
	
	# Create meteor clone
	var meteor_clone = self.duplicate()
	meteor_clone.is_clone = true
	meteor_clone.visible = true
	
	# Find and enable collision shape in the clone
	var clone_collision = meteor_clone.get_node("CollisionShape2D") if meteor_clone.has_node("CollisionShape2D") else null
	if clone_collision != null:
		clone_collision.disabled = false
	
	meteor_clone.position = Vector2(spawn_x, spawn_height)
	meteor_clone.add_to_group("meteors")
	
	# Connect signal from clone
	meteor_clone.connect("meteor_landed", Callable(self, "_on_meteor_landed"))
	
	# Add to scene
	get_parent().add_child(meteor_clone)
	
	# Debug print
	print("Spawned meteor at X: " + str(spawn_x))

func _physics_process(delta: float) -> void:
	if not is_clone:
		return  # Original meteor doesn't move
		
	if has_landed:
		# Even when landed, we still need to check for collisions
		# This is handled by the Area2D now, so we don't need additional code here
		return
	
	# Apply gravity to increase fall speed
	velocity.y += gravity * delta
	
	# Cap fall speed
	velocity.y = min(velocity.y, max_fall_speed)
	
	# Keep horizontal speed constant
	velocity.x = actual_horizontal_speed
	
	# Update rotation to match trajectory
	var angle = atan2(velocity.y, abs(velocity.x))
	rotation = angle - PI/2  # Adjust based on your sprite orientation
	
	# Move the meteor using move_and_slide() like the duck script
	move_and_slide()
	
	# Check for collisions with the goose - EXACTLY like the duck script
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var other = collision_info.get_collider()
		if other and other.name == "goose" and not game_over_triggered:
			# This is exactly how duck does it - using call() method
			game_over_triggered = true
			other.call("game_over", 2)  # 2 is LOSE state
			print("Meteor hit player - game_over called via call() method")
			break
	
	# Check if landed on floor
	if is_on_floor():
		handle_landing()

func handle_landing() -> void:
	# Mark as landed to stop movement
	has_landed = true
	
	# Stop movement
	velocity = Vector2.ZERO
	
	# Switch to idle animation and create explosion effect
	switch_to_idle_animation()
	
	# Emit signal that meteor has landed
	emit_signal("meteor_landed")

func switch_to_idle_animation() -> void:
	# Reset rotation for idle animation
	rotation = 0
	
	# Switch to idle animation if available
	if animated_sprite != null && animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("idle"):
			# Play the idle animation
			animated_sprite.play("idle")
			
			# Create a timer to trigger the explosion after a short delay
			# This ensures the idle animation is visible before particles start
			var explosion_timer = Timer.new()
			explosion_timer.wait_time = 0.1  # Short delay to ensure idle animation is visible
			explosion_timer.one_shot = true
			explosion_timer.autostart = true
			add_child(explosion_timer)
			explosion_timer.connect("timeout", Callable(self, "create_explosion_effect"))
		else:
			# No idle animation, create explosion immediately
			create_explosion_effect()
	else:
		# No animated sprite, create explosion immediately
		create_explosion_effect()

func create_explosion_effect() -> void:
	# Create a completely new particle system to ensure it works
	var new_particles = GPUParticles2D.new()
	add_child(new_particles)
	
	# Set up the particle material
	var particle_material = ParticleProcessMaterial.new()
	
	# Configure for circular explosion
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 20.0
	
	# Direction and spread for circular pattern
	particle_material.direction = Vector3(0, 0, 1)
	particle_material.spread = 180.0
	
	# Velocity settings
	particle_material.initial_velocity_min = 50.0
	particle_material.initial_velocity_max = 150.0
	
	# Gravity to make particles fall slightly
	particle_material.gravity = Vector3(0, 98, 0)
	
	# Color over lifetime (start bright, fade out)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0.7, 0.2, 1))  # Bright yellow/orange
	gradient.add_point(0.5, Color(1, 0.3, 0.1, 0.7))  # Orange/red
	gradient.add_point(1.0, Color(0.5, 0.1, 0.1, 0))  # Dark red, fade out
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	
	particle_material.color_ramp = gradient_texture
	
	# Apply material to particles
	new_particles.process_material = particle_material
	
	# Create a simple square texture for the particles
	var particle_texture = load("res://assets/sprites/flame.png")  # Use your flame texture
	if particle_texture:
		new_particles.texture = particle_texture
	
	# Configure particle system with UPDATED values
	new_particles.amount = 60  # Reduced from 100 to 60 particles
	new_particles.lifetime = 1.0
	new_particles.explosiveness = 0.9
	new_particles.randomness = 0.2
	new_particles.one_shot = true
	new_particles.local_coords = false
	
	# Make particles 2x larger
	new_particles.scale = Vector2(0.5, 0.5)  # Double the size of the particles
	
	# Position at center of meteor
	new_particles.position = Vector2.ZERO
	
	# Start emitting
	new_particles.emitting = true
	
	# Add screen shake
	shake_screen()
	
	# Set up a timer to clean up the particles after they finish
	# (but don't remove the meteor itself)
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 2.0  # Time for particles to complete
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	add_child(cleanup_timer)
	cleanup_timer.connect("timeout", Callable(new_particles, "queue_free"))

func shake_screen() -> void:
	# Find the camera and apply screen shake if available
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(screen_shake_amount)

func _on_meteor_landed() -> void:
	# This is called on the original meteor when a clone lands
	# You can use this to track statistics if needed
	pass

# Set the level length from the level script
func set_level_length(length: float) -> void:
	level_length = length
