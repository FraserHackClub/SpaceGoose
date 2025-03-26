extends CharacterBody2D

@export var gravity: float = 500.0         
@export var ground_y: float = 650          
@export var spawn_protection_duration: float = 0.5 
@export var fly_up_speed: float = -800  
@export var disappear_delay: float = 0.15 

var time_since_spawn: float = 0.0
var collected: bool = false  

func _ready() -> void:
	# Add this bread instance to the "bread" group for easier detection by the goose.
	add_to_group("bread")

func _physics_process(delta: float) -> void:
	if collected:
		velocity.y = fly_up_speed  
		move_and_slide()  # Fixed typo here.
		return  

	time_since_spawn += delta

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

	if global_position.y > ground_y:
		queue_free()
		return

	# During the spawn protection period, if this bread collides with another CharacterBody2D (like the goose),
	# trigger collection.
	if time_since_spawn < spawn_protection_duration:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is CharacterBody2D and collider != self:
				collect_bread()
				return

func collect_bread() -> void:
	if collected:
		return  

	collected = true  
	set_deferred("collision_layer", 0)  
	set_deferred("collision_mask", 0)  

	velocity.y = fly_up_speed

	await get_tree().create_timer(disappear_delay).timeout  
	queue_free()
