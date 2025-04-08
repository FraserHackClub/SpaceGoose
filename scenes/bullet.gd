extends Node2D

const SPEED: float = 3000.0
const MAX_DISTANCE_PER_STEP: float = 10.0  # Maximum distance to move in a single step

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("_last_bullet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Calculate intended movement
	var movement_vector = transform.x * SPEED * delta
	var distance_to_move = movement_vector.length()
	
	# If the movement is too large, break it down into smaller steps
	if distance_to_move > MAX_DISTANCE_PER_STEP:
		var steps = ceil(distance_to_move / MAX_DISTANCE_PER_STEP)
		var step_movement = movement_vector / steps
		
		for i in range(steps):
			# Move in smaller increments and check for collision after each step
			position += step_movement
			
			# Force collision detection to update immediately
			$Area2D.force_update_transform()
			
			# If we've been queue_free'd by a collision handler, exit early
			if is_queued_for_deletion():
				return
	else:
		# Move normally for small movements
		position += movement_vector

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Check if the area belongs to a duck
func _on_area_2d_area_entered(touchedarea: Node):
	var entity: Node = touchedarea.get_parent()  # Get the parent node (the full entity)

	# First check if we hit a duck
	if entity and entity.is_in_group("duck"):
		print_debug("Duck hit by bullet! Calling bullet_hit method...")
		
		# IMPORTANT: Use bullet_hit() for consistent handling
		if entity.has_method("bullet_hit"):
			entity.bullet_hit()
			queue_free()  # Destroy the bullet
			return
		# Fallback to take_damage if bullet_hit doesn't exist
		elif entity.has_method("take_damage"):
			entity.take_damage(1, "bullet")
			queue_free()  # Destroy the bullet
			return
	
	# Handle enemies and other entities
	if entity and (entity.is_in_group("enemy") or entity.is_in_group("meteors") or entity.is_in_group("basket")):  
		if entity.has_method("start_falling"):
			entity.start_falling("bullet")
		queue_free()  # Destroy the bullet
	elif touchedarea and (touchedarea.is_in_group("enemy") or touchedarea.is_in_group("meteors") or touchedarea.is_in_group("basket")):
		if touchedarea.has_method("start_falling"):
			touchedarea.start_falling("bullet")
		queue_free()  # Destroy the bullet
	elif touchedarea and touchedarea.name == "Terrain":
		queue_free()

# Add a body entered handler for physics bodies
func _on_area_2d_body_entered(body: Node):
	# Check if we hit a duck
	if body and body.is_in_group("duck"):
		print_debug("Duck body hit by bullet! Calling bullet_hit method...")
		
		# IMPORTANT: Use bullet_hit() for consistent handling
		if body.has_method("bullet_hit"):
			body.bullet_hit()
			queue_free()
			return
		# Fallback to take_damage if bullet_hit doesn't exist
		elif body.has_method("take_damage"):
			body.take_damage(1, "bullet")
			queue_free()
			return
	
	# Check if we hit an enemy
	if body and (body.is_in_group("enemy") or body.is_in_group("meteors") or body.is_in_group("basket")):
		if body.has_method("start_falling"):
			body.start_falling("bullet")
		queue_free()
	elif body and body.name == "TileMap":
		queue_free()
