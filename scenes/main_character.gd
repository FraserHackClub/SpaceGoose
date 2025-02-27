extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0
const DUCKING_MULTIPLIER = 0.75

const WIN = 1
const LOSE = 2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionPolygon2D
@onready var hitbox_crouch = $CollisionShape2D_Duck
# The hitbox we want to consider for terrain collision:
@onready var square_hitbox = $SquareCollisionShape2D   # <<< This is the specified hitbox

# OverheadDetector is an Area2D node added as a child to the player.
@onready var overhead_detector: Area2D = $OverheadDetector

@onready var game_over_screen_scene = load("res://scenes/game_over_screen.tscn")
@onready var hazards_tilemap: TileMap = get_node_or_null("/root/Node/Hazards")
@onready var finish_plate = null
@onready var win_area = null
@onready var finish_sprite = null

@onready var inventory_labels = {
	"egg": $"../HUD/EggCounter/EggCountLabel",
	"bread": $"../HUD/BreadCounter/BreadCountLabel",
}

@onready var goose = get_node_or_null("/root/Node/goose")

var jumpcount = 0
var game_state = 0

# Overhead detection variables
var overhead_count := 0
var forced_crouch := false
var inventory = {
	"egg": 0,
	"bread": 0,
}

func _ready():
	sprite_2d.animation = "default"
	square_hitbox.disabled = false	# Ensure the square hitbox is enabled for detection
	$Sprite2D2.hide()
	
	$ItemPickupArea.connect("body_entered", _on_area_body_entered)

	finish_plate = get_node_or_null("/root/Node/finish")
	if finish_plate != null:
		finish_sprite = finish_plate.get_node_or_null("AnimatedSprite2D")
		win_area = finish_plate.get_node_or_null("Area2D")
		if win_area != null:
			win_area.connect("body_entered", Callable(self, "_on_win_area_body_entered"))
	
	# Connect OverheadDetector signals using the new Callable syntax.
	overhead_detector.connect("body_entered", Callable(self, "_on_OverheadDetector_body_entered"))
	overhead_detector.connect("body_exited", Callable(self, "_on_OverheadDetector_body_exited"))
	
	#print("Ready: Overhead detector connected.")

func _on_OverheadDetector_body_entered(body):
	# Ignore if the body detected is the player itself.
	if body == self:
		return
	overhead_count += 1
	forced_crouch = true
	#print("OverheadDetector: Body ENTERED -> ", body.name, " | overhead_count:", overhead_count)

func _on_OverheadDetector_body_exited(body):
	# Ignore if the body detected is the player itself.
	if body == self:
		return
	overhead_count = max(overhead_count - 1, 0)
	if overhead_count == 0:
		forced_crouch = false
	#print("OverheadDetector: Body EXITED -> ", body.name, " | overhead_count:", overhead_count)

func _on_area_body_entered(body):
	# Powerups
	if body.is_in_group("item"): # Assuming items are in the "item" group
		collect_item(body)

func collect_item(item: Object):
	if item.is_in_group("egg"):
		inventory["egg"] += 1
	if item.is_in_group("bread"):
		inventory["bread"] += 1
	
	item.queue_free()
	update_inventory_labels()

func update_inventory_labels():
	for item in inventory.keys():
		inventory_labels[item].text = str(inventory[item])

func _on_hazards_body_entered(body):
	if body == self:
		game_over(LOSE)

func _on_win_area_body_entered(body):
	if body == self:
		game_over(WIN)

func game_over(state: int):
	if game_state != 0:
		return  # Prevent multiple game_over triggers

	game_state = state
	if game_state == WIN:
		if finish_sprite:
			finish_sprite.animation = "blastoff"
			var start_y = finish_sprite.position.y
			var final_target = start_y - 1000  
			var tween = get_tree().create_tween()
			tween.tween_property(finish_sprite, "position:y", final_target, 10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tween.tween_callback(func(): finish_sprite.hide())
		else:
			print("Finish sprite not found!")
		
		if goose:
			goose.hide()
		else:
			print("Goose node not found!")
	
	var game_over_screen = game_over_screen_scene.instantiate()
	get_tree().get_root().add_child(game_over_screen)
	game_over_screen.set_game_over_state(state)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * (1.5 if Input.is_action_pressed("down") else 1)
	else:
		jumpcount = 0
	
	if game_state == 0:
		_handle_movement(delta)
		move_and_slide()
		
	if hazards_tilemap:
		# Shift the player's position 20 pixels to the left
		var offset = Vector2(-75, 90)
		var adjusted_position = position - offset
		var tile_position = hazards_tilemap.local_to_map(hazards_tilemap.to_local(adjusted_position))
		if hazards_tilemap.get_cell_tile_data(0, tile_position):
			game_over(LOSE)

	var desired_anim = _handle_animation()
	if sprite_2d.animation != desired_anim:
		sprite_2d.animation = desired_anim
	
	# Debug prints for each physics frame:
	#print("Physics Process -> forced_crouch:", forced_crouch, 
		  #" | overhead_count:", overhead_count, 
		  #" | Input 'down':", Input.is_action_pressed("down"))

func _handle_movement(delta: float) -> void:
	# Jump
	if Input.is_action_just_pressed("jump") and jumpcount < 2:
		velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
		jumpcount += 1
	
	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
		$Sprite2D2.show()
		await get_tree().create_timer(0.2).timeout
		$Sprite2D2.hide()
	
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
	else:
		velocity.x = move_toward(velocity.x, 0, 12)
	
	# Flip sprite
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false

func _handle_animation() -> String:
	var desired_anim = "default"
	
	if Input.is_action_just_pressed("restart"):
		Global.restart_game()
	
	if Input.is_action_pressed("down") or forced_crouch:
		hitbox_normal.disabled = true
		hitbox_crouch.disabled = false
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
		if abs(velocity.x) > 1 and velocity.y == 0:
			desired_anim = "walk"
		elif velocity.y > 1:
			desired_anim = "glide"
		elif velocity.y < -1:
			desired_anim = "jump"
		elif velocity.x == 0 and velocity.y == 0:
			desired_anim = "default"
	
	#print("_handle_animation() -> desired_anim:", desired_anim)
	return desired_anim
