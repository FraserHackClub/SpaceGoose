extends CharacterBody2D

@export var speed: float = 300
@export var fall_speed: float = 400
@export var fall_delete_delay: float = 1.5

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false

func _physics_process(delta: float) -> void:
	if is_falling:

		velocity = Vector2(0, fall_speed)
		move_and_slide()
		return


	velocity.x = direction.x * speed
	move_and_slide()

	# Reverse direction on walls
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var normal = collision_info.get_normal()
		if abs(normal.x) > 0.7:
			direction = -direction
			$AnimatedSprite2D.flip_h = (direction.x > 0)
			break

	# Check for goose collision
	var goose_touching = false
	var goose_on_top = false
	var goose: CharacterBody2D = null
	
	for i in range(get_slide_collision_count()):
		var collision2 = get_slide_collision(i)
		var other = collision2.get_collider()
		if other and other.name == "goose":
			goose_touching = true
			goose = other
			if goose.is_on_floor():
				goose.call("game_over", 2)  
				return  
			

			var goose_bottom = goose.global_position.y + (goose.get_node("CollisionShape2D").shape.get_rect().size.y / 2)
			var duck_top = global_position.y - (get_node("CollisionShape2D").shape.get_rect().size.y / 2)
			
			if goose_bottom <= duck_top:
				goose_on_top = true
	

	if goose_touching and (goose_on_top or (goose and not goose.is_on_floor())):
		start_falling()

func start_falling() -> void:
	is_falling = true

	$CollisionShape2D.disabled = true
	collision_layer = 0
	collision_mask = 0


	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fall_delete_delay
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fall_timeout"))
	timer.start()

func _on_fall_timeout() -> void:
	queue_free()
