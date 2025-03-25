extends CharacterBody2D

@export var gravity: float = 600       
@export var ground_y: float = 650          
@export var spawn_protection_duration: float = 0.5 
@export var fly_up_speed: float = -800  
@export var disappear_delay: float = 0.15 

var time_since_spawn: float = 0.0
var collected: bool = false
var juice_type: String = "apple"  

# Static variable to track if any juice is currently being collected
static var collection_in_progress: bool = false

func _ready() -> void:
	add_to_group("juice")
	add_to_group("item")
	
	var sprite = $AnimatedSprite2D
	if sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(juice_type):
			sprite.animation = juice_type
			sprite.play()
		elif sprite.sprite_frames.get_animation_names().size() > 0:
			var default_anim = sprite.sprite_frames.get_animation_names()[0]
			sprite.animation = default_anim
			juice_type = default_anim
			sprite.play()
	
	print("Juice initialized: ", name)

func _physics_process(delta: float) -> void:
	# Debug - check if collected flag is working
	if collected:
		print("Juice flying up, position: ", global_position, " velocity: ", velocity)
		velocity.y = fly_up_speed  
		move_and_slide()
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

	# Only check for collisions after spawn protection ends and if no other juice is being collected
	if time_since_spawn >= spawn_protection_duration and not collection_in_progress: 
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is CharacterBody2D and collider != self:
				print("Detected collision with: ", collider.name)
				# Check if it's likely the player
				if collider.is_in_group("player") or collider.name.to_lower().contains("goose") or collider == Global.main_character:
					print("Juice collided with player/goose: ", collider.name)
					collect_juice()
					return

func collect() -> void:
	collect_juice()

func collect_juice() -> void:
	print("collect_juice() called")
	
	# Don't collect if already collected or another juice is being collected
	if collected or collection_in_progress:
		print("Already collected or collection in progress, ignoring")
		return  

	print("Setting collected=true and starting fly-up animation")
	collected = true
	collection_in_progress = true  # Set the static flag
	
	set_collision_layer(0)
	set_collision_mask(0)

	modulate.a = 1.0
	visible = true
	z_index = 100
	
	velocity.y = fly_up_speed
	print("Set juice velocity to: ", velocity)
	
	var timer = get_tree().create_timer(disappear_delay)
	timer.timeout.connect(_on_animation_complete)

func _on_animation_complete() -> void:
	print("Juice animation complete, adding to inventory")
	
	# Add to inventory before disappearing
	if Global.main_character and Global.main_character.inventory:
		match juice_type:
			"apple":
				Global.main_character.inventory.add_item("apple_juice", 1)
				print("Added apple juice to inventory")
			"orange":
				Global.main_character.inventory.add_item("orange_juice", 1)
				print("Added orange juice to inventory")
			"grape":
				Global.main_character.inventory.add_item("grape_juice", 1)
				print("Added grape juice to inventory")
			_:
				# Default case for any other juice types
				Global.main_character.inventory.add_item("juice", 1)
				print("Added generic juice to inventory")
		
		# Update UI if needed
		if Global.main_character.has_method("update_inventory_labels"):
			Global.main_character.update_inventory_labels()
	
	# Reset the static flag so other juices can be collected
	collection_in_progress = false
	
	queue_free()
