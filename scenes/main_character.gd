extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0
const DUCKING_MULTIPLIER = 0.75

const WIN = 1
const LOSE = 2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionShape2D
@onready var hitbox_crouch = $CollisionShape2D_Duck

@onready var game_over_screen_scene = load("res://scenes/game_over_screen.tscn")
@onready var hazards_tilemap: TileMap = get_node_or_null("/root/Node/Hazards")
@onready var finish_plate = null
@onready var win_area = null
@onready var finish_sprite = null


@onready var goose = get_node_or_null("/root/Node/goose")

var jumpcount = 0
var game_state = 0

func _ready():
	sprite_2d.animation = "default"
	$Sprite2D2.hide()

	finish_plate = get_node_or_null("/root/Node/finish")
	if finish_plate != null:
		finish_sprite = finish_plate.get_node_or_null("AnimatedSprite2D")
		win_area = finish_plate.get_node_or_null("Area2D")
		if win_area != null:
			win_area.connect("body_entered", _on_win_area_body_entered)

func _on_hazards_body_entered(body):
	if body == self:
		game_over(LOSE)

func _on_win_area_body_entered(body):
	if body == self:
		game_over(WIN)

func game_over(state: int):
	game_state = state
	if game_state == WIN:
		if finish_sprite:
			var target_y = finish_sprite.position.y - 1000  
			var tween = get_tree().create_tween()
			tween.tween_property(finish_sprite, "position:y", target_y, 10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
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
			var tile_position = hazards_tilemap.local_to_map(hazards_tilemap.to_local(position))
			if hazards_tilemap.get_cell_tile_data(0, tile_position):
				game_over(LOSE)

	var desired_anim = _handle_animation()
	if sprite_2d.animation != desired_anim:
		sprite_2d.animation = desired_anim

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
	
	if Input.is_action_pressed("down"):
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

	return desired_anim
