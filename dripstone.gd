extends CharacterBody2D

@export_range(0.5, 5.0, 0.1)
var fall_delay_min: float = 0.1
@export_range(0.5, 5.0, 0.1)
var fall_delay_max: float = 0.5
var contact_monitor = false
var contacts_reported = 0

var gravity: float = 980.0
@export var fall_speed_multiplier: float = 2.0

var triggered: bool = false
var falling: bool = false
var game_over_triggered: bool = false

func _ready() -> void:
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

func _physics_process(delta: float) -> void:
	if falling:
		velocity.y += gravity * fall_speed_multiplier * delta
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	if not game_over_triggered and ((not falling) or (falling and not is_on_floor())):
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.name == "goose":
				collider.game_over(collider.LOSE)
				game_over_triggered = true
	
	if falling and is_on_floor():
		falling = false
