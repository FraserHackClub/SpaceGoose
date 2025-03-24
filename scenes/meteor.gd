extends CharacterBody2D

@export var initial_fall_speed: float = 200.0  
@export var max_fall_speed: float = 800.0      
@export var horizontal_speed: float = -150.0   
@export var horizontal_variance: float = 50.0  
@export var spawn_height: float = -100.0       
@export var level_length: float = 13000.0      
@export var spawn_interval_min: float = 2.0    
@export var spawn_interval_max: float = 5.0    
@export var max_meteors: int = 10              

@export var explosion_duration: float = 10.0    
@export var screen_shake_amount: float = 5.0   

var gravity: float = 980.0
var actual_horizontal_speed: float = 0.0
var game_over_triggered: bool = false
var is_clone: bool = false
var rng = RandomNumberGenerator.new()
var has_landed: bool = false

@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var collision_shape = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var particles = $GPUParticles2D if has_node("GPUParticles2D") else null


signal meteor_landed

func _ready() -> void:
	rng.randomize()
	
	if not is_clone:
		visible = false
		if collision_shape != null:
			collision_shape.disabled = true
		call_deferred("start_meteor_spawner")
	else:
		actual_horizontal_speed = horizontal_speed + rng.randf_range(-horizontal_variance, horizontal_variance)
		
		velocity.y = initial_fall_speed
		velocity.x = actual_horizontal_speed
		
		if particles:
			particles.emitting = false
			particles.modulate.a = 1.0
		
		if animated_sprite != null && animated_sprite.sprite_frames != null:
			if animated_sprite.sprite_frames.has_animation("fall"):
				animated_sprite.play("fall")
			else:
				animated_sprite.play("default")
		
		var angle = atan2(initial_fall_speed, abs(actual_horizontal_speed))
		rotation = angle - PI/2  
		
		create_contact_area()

func start_falling(body: String = "") -> void:
	if body == "bullet":
		animated_sprite.play("exploding")  # Start animation
		await get_tree().create_timer(0.5).timeout  # Waits for 2 seconds
		queue_free()

func create_contact_area() -> void:
	var area = Area2D.new()
	area.name = "ContactArea"
	add_child(area)
	
	var area_shape = CollisionShape2D.new()
	area_shape.name = "AreaShape"
	
	if collision_shape != null and collision_shape.shape != null:
		area_shape.shape = collision_shape.shape.duplicate()
	else:
		var circle = CircleShape2D.new()
		circle.radius = 32  
		area_shape.shape = circle
	
	area.add_child(area_shape)
	
	area.connect("body_entered", Callable(self, "_on_contact_area_body_entered"))

func _on_contact_area_body_entered(body: Node) -> void:
	if body.name == "goose" and not game_over_triggered:
		game_over_triggered = true
		body.call("game_over", 2)  
		print("Meteor contact area triggered game over")

func start_meteor_spawner() -> void:
	var spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.wait_time = rng.randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.connect("timeout", Callable(self, "spawn_meteor"))
	add_child(spawn_timer)
	spawn_timer.start()
	
	spawn_meteor()

func spawn_meteor() -> void:
	var current_meteors = get_tree().get_nodes_in_group("meteors")
	if current_meteors.size() >= max_meteors:
		return
	
	var camera = get_viewport().get_camera_2d()
	var camera_position = Vector2.ZERO
	var visible_rect_width = get_viewport_rect().size.x
	
	if camera:
		camera_position = camera.global_position
	
	var spawn_x = camera_position.x + visible_rect_width + rng.randf_range(100, 300)
	
	spawn_x = min(spawn_x, level_length)
	
	var meteor_clone = self.duplicate()
	meteor_clone.is_clone = true
	meteor_clone.visible = true
	
	var clone_collision = meteor_clone.get_node("CollisionShape2D") if meteor_clone.has_node("CollisionShape2D") else null
	if clone_collision != null:
		clone_collision.disabled = false
	
	meteor_clone.position = Vector2(spawn_x, spawn_height)
	meteor_clone.add_to_group("meteors")
	
	meteor_clone.connect("meteor_landed", Callable(self, "_on_meteor_landed"))
	
	get_parent().add_child(meteor_clone)
	
	print("Spawned meteor at X: " + str(spawn_x))

func _physics_process(delta: float) -> void:
	if not is_clone:
		return  
		
	if has_landed:
		return
	
	velocity.y += gravity * delta
	
	velocity.y = min(velocity.y, max_fall_speed)
	
	velocity.x = actual_horizontal_speed
	
	var angle = atan2(velocity.y, abs(velocity.x))
	rotation = angle - PI/2  
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var other = collision_info.get_collider()
		if other and other.name == "goose" and not game_over_triggered:
			game_over_triggered = true
			other.call("game_over", 2)  
			print("Meteor hit player - game_over called via call() method")
			break
	
	if is_on_floor():
		handle_landing()

func handle_landing() -> void:
	has_landed = true
	
	velocity = Vector2.ZERO
	
	switch_to_idle_animation()
	
	emit_signal("meteor_landed")

func switch_to_idle_animation() -> void:
	rotation = 0
	
	if animated_sprite != null && animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
			
			var explosion_timer = Timer.new()
			explosion_timer.wait_time = 0.1  
			explosion_timer.one_shot = true
			explosion_timer.autostart = true
			add_child(explosion_timer)
			explosion_timer.connect("timeout", Callable(self, "create_explosion_effect"))
		else:
			create_explosion_effect()
	else:
		create_explosion_effect()

func create_explosion_effect() -> void:
	var new_particles = GPUParticles2D.new()
	add_child(new_particles)
	
	var particle_material = ParticleProcessMaterial.new()
	
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 20.0
	
	particle_material.direction = Vector3(0, 0, 1)
	particle_material.spread = 180.0
	
	particle_material.initial_velocity_min = 50.0
	particle_material.initial_velocity_max = 150.0
	
	particle_material.gravity = Vector3(0, 98, 0)
	
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0.7, 0.2, 1))  
	gradient.add_point(0.5, Color(1, 0.3, 0.1, 0.7))  
	gradient.add_point(1.0, Color(0.5, 0.1, 0.1, 0))  
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	
	particle_material.color_ramp = gradient_texture
	
	new_particles.process_material = particle_material
	
	var particle_texture = load("res://assets/sprites/flame.png")  
	if particle_texture:
		new_particles.texture = particle_texture
	
	new_particles.amount = 60  
	new_particles.lifetime = 1.0
	new_particles.explosiveness = 0.9
	new_particles.randomness = 0.2
	new_particles.one_shot = true
	new_particles.local_coords = false
	
	new_particles.scale = Vector2(0.5, 0.5)  
	
	new_particles.position = Vector2.ZERO
	
	new_particles.emitting = true
	
	shake_screen()
	
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 2.0  
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	add_child(cleanup_timer)
	cleanup_timer.connect("timeout", Callable(new_particles, "queue_free"))

func shake_screen() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(screen_shake_amount)

func _on_meteor_landed() -> void:
	pass

func set_level_length(length: float) -> void:
	level_length = length
