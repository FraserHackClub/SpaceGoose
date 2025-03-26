extends CharacterBody2D

@export var gravity: float = 500.0         
@export var fly_up_speed: float = -800  
@export var disappear_delay: float = 0.15  
@export var Possessing_Key_ID: float = 0.0

var collected: bool = false  

func _physics_process(delta: float) -> void:
	if collected:
		velocity.y = fly_up_speed  
		move_and_slide()  
		return  

	velocity.y += gravity * delta
	move_and_slide()

func collect_key() -> void:
	if collected:
		return  
	Global.KeyID = Possessing_Key_ID
	collected = true
	
	set_deferred("collision_layer", 0)  
	set_deferred("collision_mask", 0)  
	velocity = Vector2(0, fly_up_speed)  

	await get_tree().create_timer(disappear_delay).timeout  
	queue_free()
