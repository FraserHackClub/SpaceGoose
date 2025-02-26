extends CharacterBody2D

@export var speed: float = 300
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false

func _ready():
	# Connect the duck's top Area2D signal (for the top collision shape)
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))

func _physics_process(delta: float) -> void:
	if is_falling:
		velocity = Vector2(0, fall_speed)
		move_and_slide()
		return

	velocity.x = direction.x * speed
	move_and_slide()

	# Reverse direction on wall collisions.
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var normal = collision_info.get_normal()
		if abs(normal.x) > 0.7:
			direction = -direction
			$AnimatedSprite2D.flip_h = (direction.x > 0)
			break

	# Check if the duck's main CollisionShape2D touches a body named "goose".
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var other = collision_info.get_collider()
		if other and other.name == "goose":
			# Broadcast game_over to the goose.
			other.call("game_over", 2)
			break

func _on_top_area_entered(body: Node) -> void:
	# When a body enters the top Area2D, if it's the goose, start falling.
	if body.name == "goose":
		start_falling()

func start_falling() -> void:
	is_falling = true
	collision_layer = 0
	collision_mask = 0

	# Start a timer to remove the duck after a delay.
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fall_delete_delay
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fall_timeout"))
	timer.start()

func _on_fall_timeout() -> void:
	queue_free()
