extends CharacterBody2D

@export_range(0.5, 5.0, 0.1)
var fall_delay_min: float = 0.4
var fall_delay_max: float = 1.0
var contact_monitor = false
var contacts_reported = 0

@onready var sprite = $AnimatedSprite2D


var gravity: float = 980.0
@export var fall_speed_multiplier: float = 2.0

@onready var goose = $"../goose"

var triggered: bool = false
var falling: bool = false
var landed: bool = false
var game_over_triggered: bool = false

func _ready() -> void:
	sprite.play("default")
	randomize()
	velocity = Vector2.ZERO
	contact_monitor = true
	contacts_reported = 1
	$TriggerArea.body_entered.connect(_on_trigger_area_body_entered)
	$Timer.timeout.connect(_on_timer_timeout)

func _on_trigger_area_body_entered(body: Node) -> void:
	if triggered:
		return
	if body.name == "goose":
		triggered = true
		var wait_time: float = randf_range(fall_delay_min, fall_delay_max)
		$Timer.wait_time = wait_time
		$Timer.start()

func _on_timer_timeout() -> void:
	falling = true
	
func start_falling(body: String = "") -> void:
	if body == "bullet":
		goose.increase_score(25)

	sprite.play("exploding")  # Start animation
	await get_tree().create_timer(0.27).timeout  # Waits for 2 seconds
	queue_free()

func _physics_process(delta: float) -> void:
	if falling:
		velocity.y += gravity * fall_speed_multiplier * delta
		move_and_slide()
		
		# Always check for collisions while falling.
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.name == "goose" and not game_over_triggered:
				collider.game_over(collider.LOSE)
				game_over_triggered = true
				
		# After checking collisions, mark as landed if on the floor.
		if is_on_floor():
			falling = false
			landed = true
	else:
		velocity = Vector2.ZERO
		move_and_slide()
