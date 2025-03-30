extends CharacterBody2D

@export var gravity: float = 500.0         
@export var fly_up_speed: float = -800  
@export var disappear_delay: float = 0.15  

var collected: bool = false  

func _physics_process(delta: float) -> void:
	if collected:
		velocity.y = fly_up_speed  
		move_and_slide()  
		return  

	velocity.y += gravity * delta
	move_and_slide()

func start_falling(body: String = ""):
	if body == "fireball":
		modulate = Color.DARK_ORANGE
		await get_tree().create_timer(0.3).timeout
		while round(modulate.a * 100) > 10:
			modulate.a = lerp(modulate.a, 0.0, 0.2)
			await get_tree().create_timer(0.01).timeout
		call_deferred("queue_free")

func collect() -> void:
	if collected:
		return  

	collected = true  
	set_deferred("collision_layer", 0)  
	set_deferred("collision_mask", 0)  
	velocity = Vector2(0, fly_up_speed)  

	await get_tree().create_timer(disappear_delay).timeout  
	queue_free()
