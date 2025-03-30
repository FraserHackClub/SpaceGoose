extends CharacterBody2D

var juice_box_scene = preload("res://scenes/juice.tscn")

const NUM_JUICE_BOXES = 3
const SPAWN_OFFSET = Vector2(0, -50)
const DISABLE_AUTO_DESPAWN_GROUND_Y = 10000.0
const SPACING = 100
const TWEEN_DURATION = 0.5
const COLLECTION_DELAY = 0

const JUICE_TYPES = ["apple", "orange", "grape"]

var exploded: bool = false
var collected: bool = true

var juice_timers = {}

func _ready():
	if $ExplosionArea:
		$ExplosionArea.connect("body_entered", Callable(self, "_on_body_entered"))
		if $AnimatedSprite2D:
			$AnimatedSprite2D.play("default")
	else:
		push_error("ExplosionArea node is missing from the galactic basket scene!")

func _on_body_entered(body):
	if exploded:
		return
	if "goose" in body.name.to_lower():
		exploded = true
		if $AnimatedSprite2D:
			if $AnimatedSprite2D.sprite_frames and $AnimatedSprite2D.sprite_frames.has_animation("explode"):
				$AnimatedSprite2D.play("explode")
				await $AnimatedSprite2D.animation_finished
		
		call_deferred("spawn_juice_explosion")
		call_deferred("queue_free")

func start_falling(body: String = ""):
	if body == "bullet":
		exploded = true
		call_deferred("spawn_juice_explosion")
		call_deferred("queue_free")
	elif body == "fireball":
		modulate = Color.DARK_ORANGE
		await get_tree().create_timer(0.3).timeout
		while round(modulate.a * 100) > 10:
			modulate.a = lerp(modulate.a, 0.0, 0.2)
			await get_tree().create_timer(0.01).timeout
		call_deferred("queue_free")

func spawn_juice_explosion():
	for i in range(NUM_JUICE_BOXES):
		var juice_box = juice_box_scene.instantiate()
		
		var random_juice_type = JUICE_TYPES[randi() % JUICE_TYPES.size()]
		juice_box.juice_type = random_juice_type
		
		if juice_box.get("ground_y") != null:
			juice_box.ground_y = DISABLE_AUTO_DESPAWN_GROUND_Y
		if juice_box.get("spawn_protection_duration") != null:
			juice_box.spawn_protection_duration = 0
		
		var juice_id = juice_box.get_instance_id()
		
		juice_box.tree_exited.connect(_on_juice_box_exited.bind(juice_id))
		
		get_parent().call_deferred("add_child", juice_box)
		
		var start_pos = global_position + SPAWN_OFFSET
		juice_box.global_position = start_pos
		
		var offset = Vector2((i - (NUM_JUICE_BOXES - 1) / 2.0) * SPACING, 0)
		var final_pos = global_position + SPAWN_OFFSET + offset
		
		final_pos += Vector2(
			randf_range(-20, 20),
			randf_range(-20, 10)
		)
		
		var arc_height = randf_range(-50, -80)
		var mid_point = start_pos + Vector2((final_pos.x - start_pos.x) / 2, arc_height)
		
		var tween = get_tree().create_tween()
		
		tween.tween_property(juice_box, "global_position", mid_point, TWEEN_DURATION/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(juice_box, "global_position", final_pos, TWEEN_DURATION/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = TWEEN_DURATION + COLLECTION_DELAY
		timer.timeout.connect(_on_juice_timer_timeout.bind(juice_id))
		add_child(timer)
		timer.start()
		
		juice_timers[juice_id] = timer

func _on_juice_timer_timeout(juice_id):
	var juice_box = instance_from_id(juice_id) if juice_id else null
	
	if is_instance_valid(juice_box):
		if juice_box.get("spawn_protection_duration") != null:
			juice_box.time_since_spawn = juice_box.spawn_protection_duration + 0.1
		
		if juice_box.get("modulate") != null:
			var flash_tween = get_tree().create_tween()
			flash_tween.tween_property(juice_box, "modulate", Color(1.5, 1.5, 1.5, 1), 0.1)
			flash_tween.tween_property(juice_box, "modulate", Color(1, 1, 1, 1), 0.1)
	
	if juice_timers.has(juice_id):
		var timer = juice_timers[juice_id]
		if is_instance_valid(timer):
			timer.queue_free()
		juice_timers.erase(juice_id)

func _on_juice_box_exited(juice_id):
	if juice_timers.has(juice_id):
		var timer = juice_timers[juice_id]
		if is_instance_valid(timer):
			timer.queue_free()
		juice_timers.erase(juice_id)
