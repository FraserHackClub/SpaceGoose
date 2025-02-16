extends CharacterBody2D

@export var gravity: float = 500.0         
@export var ground_y: float = 650          
@export var spawn_protection_duration: float = 0.5 

var time_since_spawn: float = 0.0

func _physics_process(delta: float) -> void:
	time_since_spawn += delta


	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0


	move_and_slide()


	if global_position.y > ground_y:
		queue_free()
		return


	if time_since_spawn < spawn_protection_duration:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is CharacterBody2D and collider != self:
				queue_free()
				return
