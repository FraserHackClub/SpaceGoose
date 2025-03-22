extends CharacterBody2D

const SPEED = 400
@export var JUMP_VELOCITY = -900.0  # Changed from const to var to @export var because why not
const DUCKING_MULTIPLIER = 0.75

const WIN = 1
const LOSE = 2
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionPolygon2D
@onready var hitbox_crouch = $CollisionShape2D_Duck
@onready var helmet: Sprite2D = $Helmet
# The hitbox we want to consider for terrain collision:
@onready var square_hitbox = $SquareCollisionShape2D   # <<< This is the specified hitbox

# OverheadDetector is an Area2D node added as a child to the player.
@onready var overhead_detector: Area2D = $OverheadDetector

@onready var game_over_screen_scene: PackedScene = preload("res://scenes/game_over_screen.tscn")
@onready var hazards_tilemap: TileMap = get_node_or_null("../Hazards")
@onready var signs: TileMap = get_node_or_null("../Signs")
@onready var finish_plate = null
@onready var win_area = null
@onready var finish_sprite: AnimatedSprite2D
@onready var sfx_collect: AudioStreamPlayer = $sfx_collect
@onready var sfx_jump: AudioStreamPlayer = $sfx_jump
@onready var sfx_swoosh: AudioStreamPlayer = $sfx_swoosh
@onready var sfx_blastoff: AudioStreamPlayer = $Blastoff

#GUN
@onready var gun: Node2D = $PlayerGun

var inventory: Inventory

@export var time = 60.0

@export var inventory_labels: Dictionary

@onready var goose = get_node_or_null(".")


#GUN

@onready var is_disabled := false
var jumpcount = 0
var game_state = 0


# Overhead detection variables
var overhead_count := 0
var forced_crouch := false

var timer_label: Node
var level_changing = false



func _ready():
	sprite_2d.animation = "default"
	square_hitbox.disabled = false
	$Sprite2D2.hide()
	sprite_2d.connect("frame_changed", Callable(self, "_on_goose_frame_changed"))
	$ItemPickupArea.connect("body_entered", _on_area_body_entered)
	overhead_detector.connect("body_entered", Callable(self, "_on_OverheadDetector_body_entered"))
	overhead_detector.connect("body_exited", Callable(self, "_on_OverheadDetector_body_exited"))
	
	#Global path assignment:

	Global.main_character = self  # Store player globally


	if gun:
		Global.player_gun_path = gun.get_path()  # Store the node path instead of a reference
		print_debug("PlayerGun path stored globally:", Global.player_gun_path)
	else:
		printerr("Error: PlayerGun not found!")
	
	# Defer level setup so that the scene is fully ready.
	call_deferred("_level_ready")



func _level_ready():
	finish_plate = get_node_or_null("../finish")
	if finish_plate != null:
		finish_sprite = finish_plate.get_node_or_null("AnimatedSprite2D")
		win_area = finish_plate.get_node_or_null("Area2D")
		if win_area != null:
			win_area.connect("body_entered", Callable(self, "_on_win_area_body_entered"))
	
	inventory_labels = {
		"egg": $"../Camera2D/HUD/EggCounter/EggCountLabel",
		"bread": $"../Camera2D/HUD/BreadCounter/BreadCountLabel",
	}
	
	update_inventory_labels()
	
	timer_label = $"../Camera2D/HUD/Timer/TimerLabel"
#=
			

func disable():
	is_disabled = true

func enable():
	is_disabled = false

func _on_goose_frame_changed() -> void:
	if sprite_2d.animation != "default":
		return
	var positions = [ -242, -237, -230, -226, -230, -237, -242, -237, -230, -226, -230, -237 ]
	helmet.position.y = positions[sprite_2d.frame % positions.size()]

func _on_OverheadDetector_body_entered(body):
	if body == self:
		return
	overhead_count += 1
	forced_crouch = true

func _on_OverheadDetector_body_exited(body):
	if body == self:
		return
	overhead_count = max(overhead_count - 1, 0)
	if overhead_count == 0:
		forced_crouch = false

func _on_area_body_entered(body):
	if body.is_in_group("item"):
		collect_item(body)




func collect_item(item: Object):
	sfx_collect.play()
	if item.is_in_group("egg"):
		inventory.add_item("egg", 1)
	if item.is_in_group("bread"):
		inventory.add_item("bread", 1)


	if item.has_method("collect_bread"):
		item.collect_bread()
	elif item.has_method("collect_egg"):
		item.collect_egg()
	elif item.has_method("collect_weapon"):
		item.collect_weapon()
	else:
		item.queue_free()  # Default behavior for other items

	update_inventory_labels()

func update_inventory_labels():
	for item in inventory.get_all_items().keys():
		inventory_labels[item].text = str(inventory.get_item_count(item))

func _on_hazards_body_entered(body):
	if is_disabled:
		return  # ignore death triggers
	if body == self:
		game_over(LOSE)

func _on_win_area_body_entered(body):
	if body == self:
		game_over(WIN)

func game_over(state: int):
	print(game_state)
	print(level_changing)
	if game_state != 0 or level_changing:
		return  # Prevent multiple game_over triggers

	gun.activated = false
	game_state = state
	if game_state == WIN:
		if finish_sprite:
			finish_sprite.animation = "blastoff"
			var final_target = -600
			var tween = get_tree().create_tween()
			tween.tween_property(finish_sprite, "position:y", final_target, 10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tween.tween_callback(func(): finish_sprite.hide())
		else:
			printerr("Finish sprite not found!")
		
		inventory.commit_inventory()
		
		if goose:
			goose.hide()
			sfx_blastoff.play()
			# Wait for the blastoff sound to play before changing level
			level_changing = true
			await get_tree().create_timer(11.0).timeout
			change_to_next_level()
		else:
			printerr("Goose node not found!")
	else:
		inventory.commit_inventory()
		# For LOSE state, show game over screen as before
		var game_over_screen: CanvasLayer = game_over_screen_scene.instantiate()
		game_over_screen.inventory = inventory
		get_tree().get_root().add_child(game_over_screen)
		game_over_screen.set_game_over_state(state)
		# Store the current level index in the game over screen
		if game_over_screen.has_method("set_level_index"):
			game_over_screen.set_level_index(Global.current_level_index)

func change_to_next_level():
	var current_level_index = Global.current_level_index
	var next_level_index = current_level_index + 1
	
	
	print_debug("Changing from level index", current_level_index, "to", next_level_index)
	
	if Global.has_level(next_level_index):
		inventory.current_level = next_level_index
		inventory.commit_inventory()
		await Global.change_level(next_level_index)
	else:
		print_debug("No more levels! Game complete!")
		# Show a game completion screen or return to main menu
		var game_over_screen = game_over_screen_scene.instantiate()
		get_tree().get_root().add_child(game_over_screen)
		game_over_screen.set_game_over_state(WIN)

func _physics_process(delta: float) -> void:
	if level_changing:
		return
	if is_disabled:
		velocity = Vector2.ZERO
		return  # skip movement and input
		
	if not is_on_floor():
		var gravity_force = get_gravity()
		var base_fall_multiplier = 900.0 / abs(JUMP_VELOCITY)
		if velocity.y > 0:
			var falling_multiplier = base_fall_multiplier
			if Input.is_action_pressed("down"):
				falling_multiplier *= 1.5
			velocity += gravity_force * delta * falling_multiplier
		else:
			velocity += gravity_force * delta
	else:
		jumpcount = 0
	
	if game_state == 0:
		_handle_timer(delta)
		_handle_movement(delta)
		move_and_slide()	
	if hazards_tilemap:
		var offset = Vector2(-75, 90)
		var adjusted_position = position - offset
		var tile_position = hazards_tilemap.local_to_map(hazards_tilemap.to_local(adjusted_position))
		if hazards_tilemap.get_cell_tile_data(0, tile_position):
			game_over(LOSE)
	
	var desired_anim = _handle_animation()
	if sprite_2d.animation != desired_anim:
		sprite_2d.animation = desired_anim

func _handle_movement(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1.0)
			sfx_swoosh.play()
			$Sprite2D2.show()
			await get_tree().create_timer(0.2).timeout
			$Sprite2D2.hide()
		elif jumpcount < 2:
			velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1.0)
			jumpcount += 1
			sfx_jump.play()
	
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, 12)
	
	if direction < 0:
		sprite_2d.flip_h = true
		helmet.position.x = 126
		
	elif direction > 0:
		helmet.position.x = 180
		sprite_2d.flip_h = false

func _handle_timer(delta: float):
	time -= delta
	time = max(time, 0.0)
	if timer_label:
		timer_label.text = str(int(time))
	
	if time <= 0:
		game_over(LOSE)

func _handle_animation() -> String:
	var desired_anim = "default"
	
	if Input.is_action_just_pressed("help"):
		if signs:
			signs.visible = !signs.visible
	
	if Input.is_action_just_pressed("restart"):
		# Only handle restart if we're not in a game over state
		if game_state == 0:
			Global.restart_game()
		return desired_anim

	if Input.is_action_pressed("down") or forced_crouch:
		hitbox_normal.disabled = true
		hitbox_crouch.disabled = false
		helmet.position.y = -170   
		desired_anim = "crouch_idle"
		if abs(velocity.x) > 1 and velocity.y == 0:
			desired_anim = "sneak"
		if velocity.y < -1:
			desired_anim = "crouch_jump"
		if velocity.y > 1:
			desired_anim = "crouch_glide"
	else:
		hitbox_normal.disabled = false
		hitbox_crouch.disabled = true

		if abs(velocity.x) > 0 or abs(velocity.y) > 0:
			helmet.position.y = -242 
			if abs(velocity.x) > 1 and velocity.y == 0:
				desired_anim = "walk"
			elif velocity.y > 1:
				desired_anim = "glide"
			elif velocity.y < -1:
				desired_anim = "jump"
			else:
				desired_anim = "default"
		else:
			desired_anim = "default"
	
	return desired_anim

func toggle_helmet() -> void:
	if helmet:
		helmet.visible = !helmet.visible
		print_debug("Helmet visibility toggled to: ", helmet.visible)
	else:
		printerr("Helmet node not found")
