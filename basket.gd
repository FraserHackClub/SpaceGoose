extends CharacterBody2D

var bread_scene = preload("res://scenes/bread.tscn")

# Configuration constants:
const NUM_BREAD = 5                             # Number of bread pieces to spawn
const SPAWN_OFFSET = Vector2(0, -100)            # Offset from basket position where bread spawns
const DISABLE_AUTO_DESPAWN_GROUND_Y = 10000.0   # Override ground_y so bread never auto-despawns
const SPACING = 60                          # Horizontal spacing between bread pieces in the final line
const TWEEN_DURATION = 0.2                   # Faster tween duration for spawn animation

var exploded: bool = false                      # Ensure the basket triggers explosion only once

func _ready():
	# Connect the ExplosionArea's body_entered signal.
	if $ExplosionArea:
		$ExplosionArea.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		push_error("ExplosionArea node is missing from the basket scene!")

func _on_body_entered(body):
	# Only trigger if the colliding body is the goose and the basket hasn't exploded yet.
	if exploded:
		return
	if "goose" in body.name.to_lower():
		exploded = true
		# Spawn bread in a deferred manner.
		call_deferred("spawn_bread_explosion")
		# Remove the basket from the scene after spawning bread.
		call_deferred("queue_free")

func start_falling(body: String = ""):
	if body == "bullet":
		exploded = true
		call_deferred("spawn_bread_explosion")
		call_deferred("queue_free")
	elif body == "fireball":
		modulate = Color.DARK_ORANGE
		await get_tree().create_timer(0.3).timeout
		while round(modulate.a * 100) > 10:
			modulate.a = lerp(modulate.a, 0.0, 0.2)
			await get_tree().create_timer(0.01).timeout
		call_deferred("queue_free")

func spawn_bread_explosion():
	# For each bread piece, spawn it at the basket's spawn offset then animate it to its final position in a line.
	for i in range(NUM_BREAD):
		var bread = bread_scene.instantiate()
		# Override the bread's auto-despawn and spawn protection.
		bread.ground_y = DISABLE_AUTO_DESPAWN_GROUND_Y
		bread.spawn_protection_duration = 0
		# Safely add the bread as a sibling of the basket.
		get_parent().call_deferred("add_child", bread)
		
		# Set the initial position: at the basket's position offset by SPAWN_OFFSET.
		var start_pos = global_position + SPAWN_OFFSET
		bread.global_position = start_pos
		
		# Calculate final position for a horizontal line centered at the basket.
		var offset = Vector2((i - (NUM_BREAD - 1) / 2.0) * SPACING, 0)
		var final_pos = global_position + SPAWN_OFFSET + offset
		
		# Animate bread from start_pos to final_pos over TWEEN_DURATION seconds using a tween.
		var tween = get_tree().create_tween()
		tween.tween_property(bread, "global_position", final_pos, TWEEN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
