extends CharacterBody2D

@export var speed: float = 200
@export var fall_speed: float = 600
@export var fall_delete_delay: float = 1

var direction: Vector2 = Vector2.LEFT
var is_falling: bool = false

@onready var sfx_duckfall: AudioStreamPlayer = $DuckDie

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	call_deferred("_check_scene")
	$Area2D.connect("body_entered", Callable(self, "_on_top_area_entered"))

func _check_scene() -> void:
	var current_scene = get_tree().get_current_scene()
	if current_scene and current_scene.name == "1-2":
		$AnimatedSprite2D.play("spaceDuck")

func _physics_process(_delta: float) -> void:
	if is_falling:
		velocity = Vector2(0, fall_speed)
		move_and_slide()
		return

	velocity.x = direction.x * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var normal = collision_info.get_normal()
		if abs(normal.x) > 0.7:
			direction = -direction
			$AnimatedSprite2D.flip_h = (direction.x > 0)
			break

	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var other = collision_info.get_collider()
		if other and other.name == "goose":
			other.call("game_over", 2)
			break

func _on_top_area_entered(body: Node) -> void:
	if body.name == "goose":
		start_falling()

func start_falling() -> void:
	is_falling = true
	collision_layer = 0
	collision_mask = 0
	sfx_duckfall.play()

	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fall_delete_delay
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fall_timeout"))
	timer.start()

func _on_fall_timeout() -> void:
	queue_free()
