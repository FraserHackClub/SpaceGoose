extends CharacterBody2D

# Preload the juice scene
@export var juice_box_scene: PackedScene = preload("res://scenes/juice.tscn")

# Configuration constants
const NUM_JUICE_BOXES = 3
const SPAWN_OFFSET = Vector2(0, -20)  # Smaller offset to keep juice closer to ground
const SPACING = 60  # Tighter spacing
const DISABLE_AUTO_DESPAWN_GROUND_Y = 10000.0

# State tracking
var exploded: bool = false
var juice_spawned: bool = false

# Juice types
const JUICE_TYPES = ["apple", "orange", "grape"]

func _ready():
	# Set up the explosion area if it exists
	var explosion_area = get_node_or_null("ExplosionArea")
	if explosion_area:
		if not explosion_area.is_connected("body_entered", Callable(self, "_on_body_entered")):
			explosion_area.connect("body_entered", Callable(self, "_on_body_entered"))
		
		# Play default animation if it exists
		var animated_sprite = get_node_or_null("AnimatedSprite2D")
		if animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("default"):
				animated_sprite.play("default")
	else:
		# Create a default explosion area if none exists
		var area = Area2D.new()
		area.name = "ExplosionArea"
		add_child(area)
		
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 50.0
		collision.shape = shape
		area.add_child(collision)
		
		# Connect the signal
		area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if exploded or juice_spawned:
		return
	
	# Check for player with various possible names
	if "goose" in body.name.to_lower() or "player" in body.name.to_lower() or "main_character" in body.name.to_lower():
		exploded = true
		juice_spawned = true
		
		# Disable collision to prevent multiple triggers
		var explosion_area = get_node_or_null("ExplosionArea")
		if explosion_area:
			explosion_area.set_deferred("monitoring", false)
			explosion_area.set_deferred("monitorable", false)
		
		# Play explosion animation if available
		var animated_sprite = get_node_or_null("AnimatedSprite2D")
		if animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("explode"):
				animated_sprite.play("explode")
				await animated_sprite.animation_finished
		
		# Spawn juice boxes directly on the ground - using call_deferred to avoid physics errors
		call_deferred("spawn_juice_boxes_on_ground", body)
		
		# Hide the basket but don't free it yet
		visible = false
		
		# Queue free after a delay
		var timer = get_tree().create_timer(0.1)
		await timer.timeout
		queue_free()

func start_falling(body: String = ""):
	if body == "bullet" and not juice_spawned:
		exploded = true
		juice_spawned = true
		
		# Find player to add juice to inventory
		var player = find_player()
		if player:
			# Spawn juice boxes directly on the ground - using call_deferred to avoid physics errors
			call_deferred("spawn_juice_boxes_on_ground", player)
			
			# Hide the basket but don't free it yet
			visible = false
			
			# Queue free after a delay
			var timer = get_tree().create_timer(0.1)
			await timer.timeout
			queue_free()
	elif body == "fireball":
		modulate = Color.DARK_ORANGE
		await get_tree().create_timer(0.3).timeout
		while round(modulate.a * 100) > 10:
			modulate.a = lerp(modulate.a, 0.0, 0.2)
			await get_tree().create_timer(0.01).timeout
		queue_free()

func find_player():
	# Try to find player in the scene
	var player = null
	
	# Method 1: Check Global.main_character
	if Engine.has_singleton("Global"):
		var Global = Engine.get_singleton("Global")
		if Global.get("main_character") and is_instance_valid(Global.main_character):
			player = Global.main_character
			return player
	
	# Method 2: Look for nodes with common player names
	var current_scene = get_tree().current_scene
	player = current_scene.get_node_or_null("goose")
	if player:
		return player
		
	player = current_scene.get_node_or_null("player")
	if player:
		return player
		
	player = current_scene.get_node_or_null("main_character")
	if player:
		return player
	
	# Method 3: Look for nodes in the "player" group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	
	return null

# New function to spawn juice boxes directly on the ground
func spawn_juice_boxes_on_ground(player):
	# For each juice box, spawn it directly at the final position
	for i in range(NUM_JUICE_BOXES):
		if not juice_box_scene:
			continue
			
		var juice_box = juice_box_scene.instantiate()
		if not juice_box:
			continue
			
		# Set a random juice type for visual variety
		var random_juice_type = JUICE_TYPES[randi() % JUICE_TYPES.size()]
		
		# Set juice type on the sprite if possible
		if juice_box.get("juice_type") != null:
			juice_box.juice_type = random_juice_type
		
		# Calculate position in a line
		var offset = Vector2((i - (NUM_JUICE_BOXES - 1) / 2.0) * SPACING, 0)
		var final_pos = global_position + SPAWN_OFFSET + offset
		
		# Add a tiny bit of randomness to the position
		final_pos += Vector2(
			randf_range(-5, 5),
			randf_range(-2, 2)
		)
		
		# Add the juice box to the scene
		get_parent().add_child(juice_box)
		
		# Set the position directly
		juice_box.global_position = final_pos
		
		# Configure the juice box safely using deferred calls
		configure_juice_box_deferred(juice_box, random_juice_type, player)

# Safely configure juice box properties using deferred calls
func configure_juice_box_deferred(juice_box, juice_type, player):
	# Disable physics to prevent falling
	if juice_box.has_method("set_physics_process"):
		juice_box.call_deferred("set_physics_process", false)
	
	# Set extremely high ground_y to prevent auto-despawn
	if juice_box.get("ground_y") != null:
		juice_box.ground_y = DISABLE_AUTO_DESPAWN_GROUND_Y
	
	# Reset spawn protection to allow immediate collection
	if juice_box.get("spawn_protection_duration") != null:
		juice_box.spawn_protection_duration = 0
		juice_box.time_since_spawn = 999  # Ensure it's collectable immediately
	
	# Make sure velocity is zero
	if juice_box is CharacterBody2D:
		juice_box.velocity = Vector2.ZERO
	elif juice_box is RigidBody2D:
		juice_box.call_deferred("set_linear_velocity", Vector2.ZERO)
		juice_box.call_deferred("set_angular_velocity", 0)
		juice_box.call_deferred("set_freeze", true)
	
	# Disable any collision shapes
	for child in juice_box.get_children():
		if child is CollisionShape2D:
			child.call_deferred("set_disabled", true)
			child.call_deferred("set_disabled", false)  # Re-enable after physics step
		elif child is CollisionPolygon2D:
			child.call_deferred("set_disabled", true)
			child.call_deferred("set_disabled", false)  # Re-enable after physics step
	
	# Add a custom script to handle collection properly
	call_deferred("add_collection_script_to_juice", juice_box, juice_type, player)

# Add a script to handle juice collection properly
func add_collection_script_to_juice(juice_box, juice_type, player):
	# Create a new script to override the juice's behavior
	var script_text = """
extends CharacterBody2D

# Original juice properties to preserve
var juice_type = "{0}"
var collected = false
var ground_y = 10000.0  # Set very high to prevent auto-despawn
var time_since_spawn = 999.0  # Ensure it's immediately collectable
var spawn_protection_duration = 0.0
var fly_up_speed = -800
var disappear_delay = 0.15
static var collection_in_progress = false

func _ready():
	# Disable physics to keep the juice stationary
	set_physics_process(false)
	
	# Make sure animation is playing
	var sprite = $AnimatedSprite2D
	if sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(juice_type):
			sprite.animation = juice_type
			sprite.play()
	
	# Make sure we're in the right groups
	if not is_in_group("juice"):
		add_to_group("juice")
	if not is_in_group("item"):
		add_to_group("item")
	
	# Ensure velocity is zero
	velocity = Vector2.ZERO
	
	# Create a dedicated collection area
	call_deferred("create_collection_area")

func create_collection_area():
	# Check if we already have a collection area
	if has_node("CollectionArea"):
		return
		
	# Create a new area for collection
	var area = Area2D.new()
	area.name = "CollectionArea"
	add_child(area)
	
	# Add a collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 30.0
	collision.shape = shape
	area.add_child(collision)
	
	# Connect the signal
	area.connect("body_entered", Callable(self, "_on_collection_area_body_entered"))

func _on_collection_area_body_entered(body):
	# Check if this is the player
	if "goose" in body.name.to_lower() or "player" in body.name.to_lower() or "main_character" in body.name.to_lower():
		collect()

func _physics_process(delta):
	# Override to do nothing - keep the juice stationary
	pass

# Add this function to match the original juice script
func is_collectable() -> bool:
	return time_since_spawn >= spawn_protection_duration and (not collection_in_progress) and (not collected)

func collect():
	if collected:
		return
		
	print("Juice being collected: " + juice_type)
	collected = true
	collection_in_progress = true  # Set static flag
	
	# Disable collision
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Disable collection area
	var collection_area = get_node_or_null("CollectionArea")
	if collection_area:
		collection_area.set_deferred("monitoring", false)
		collection_area.set_deferred("monitorable", false)
	
	# Add to inventory
	add_to_inventory()
	
	# Play collection animation
	play_collection_animation()
	
	# Play collection sound
	play_collection_sound()

func add_to_inventory():
	var player = find_player()
	if not player:
		return
		
	var added = false
	
	# Method 1: Try player's inventory directly
	if player.get("inventory") != null:
		var inventory = player.inventory
		if inventory.has_method("add_item"):
			inventory.add_item(juice_type + "_juice", 1)
			if inventory.has_method("commit_inventory"):
				inventory.commit_inventory()
			added = true
	
	# Method 2: Try player's add_juice method
	if not added and player.has_method("add_juice"):
		player.add_juice(juice_type)
		added = true
	
	# Method 3: Try Global inventory
	if not added and Engine.has_singleton("Global"):
		var Global = Engine.get_singleton("Global")
		if Global.get("inventory") != null:
			var inventory = Global.inventory
			if inventory.has_method("add_item"):
				inventory.add_item(juice_type + "_juice", 1)
				if inventory.has_method("commit_inventory"):
					inventory.commit_inventory()
			added = true
	
	# Update UI if possible
	if player.has_method("update_inventory_labels"):
		player.update_inventory_labels()

func play_collection_animation():
	var player = find_player()
	if not player:
		queue_free()
		return
		
	# Make sure we're visible
	visible = true
	z_index = 100
	
	# Create animation tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	
	# Calculate target position (slightly above player)
	var target_pos = player.global_position + Vector2(0, -50)
	
	# Animate flying to player
	tween.tween_property(self, "global_position", target_pos, 0.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	tween.tween_property(self, "modulate:a", 0, 0.2)
	
	# Free the juice box when animation is done
	tween.tween_callback(func(): 
		collection_in_progress = false  # Reset static flag
		queue_free()
	)

func play_collection_sound():
	var player = find_player()
	if not player:
		return
		
	if player.has_node("sfx_collect"):
		var sfx = player.get_node("sfx_collect")
		if sfx and sfx.has_method("play"):
			sfx.play()

func find_player():
	# Try to find player in the scene
	var player = null
	
	# Method 1: Check Global.main_character
	if Engine.has_singleton("Global"):
		var Global = Engine.get_singleton("Global")
		if Global.get("main_character") and is_instance_valid(Global.main_character):
			player = Global.main_character
			return player
	
	# Method 2: Look for nodes with common player names
	var current_scene = get_tree().current_scene
	player = current_scene.get_node_or_null("goose")
	if player:
		return player
		
	player = current_scene.get_node_or_null("player")
	if player:
		return player
		
	player = current_scene.get_node_or_null("main_character")
	if player:
		return player
	
	# Method 3: Look for nodes in the "player" group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	
	return null

# Add this to match the original juice script
func start_falling(body: String = ""):
	if body == "fireball":
		modulate = Color.DARK_ORANGE
		await get_tree().create_timer(0.3).timeout
		while round(modulate.a * 100) > 10:
			modulate.a = lerp(modulate.a, 0.0, 0.2)
			await get_tree().create_timer(0.01).timeout
		call_deferred("queue_free")
"""

	# Format the script with the juice type
	script_text = script_text.format([juice_type])
	
	# Create and apply the script
	var script = GDScript.new()
	script.source_code = script_text
	script.reload()
	juice_box.set_script(script)
