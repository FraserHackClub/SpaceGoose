extends CharacterBody2D

@export var gravity: float = 500.0         
@export var fly_up_speed: float = -800  
@export var disappear_delay: float = 0.15  

var player_gun: Node2D = Global.player_gun

var collected: bool = false  

func _physics_process(delta: float) -> void:
	if collected:
		velocity.y = fly_up_speed  
		move_and_slide()  
		return  

	velocity.y += gravity * delta
	move_and_slide()

func collect_weapon() -> void:
	if collected:
		return  

	collected = true  
	set_deferred("collision_layer", 0)  
	set_deferred("collision_mask", 0)  

	print("WeaponPickup collected! Checking global main_character...")

	if Global.main_character:
		print("Main Character found globally:", Global.main_character.name)

		# Retrieve the gun using the stored path
		var gun = Global.main_character.get_node_or_null(Global.player_gun_path)
		
		if gun:
			print("Gun found via stored path! Activating...")
			gun._pickedup()  # Activate the gun!
		else:
			print("Error: Could not find PlayerGun using stored path!")

	else:
		print("Error: Global.main_character is null!")

	velocity = Vector2(0, fly_up_speed)  
	await get_tree().create_timer(disappear_delay).timeout  
	queue_free()
