extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionShape2D
@onready var hitbox_crouch = $CollisionShape2D_Duck

var jumpcount = 0

func _ready():
	$Sprite2D2.hide()

func _physics_process(delta: float) -> void:
	var desired_anim = "default"
	
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumpcount = 0

	# Handle jumping.
	if Input.is_action_just_pressed("jump") and jumpcount < 2:
		velocity.y = JUMP_VELOCITY
		jumpcount += 1

	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY
		$Sprite2D2.show()
		await get_tree().create_timer(0.2).timeout
		$Sprite2D2.hide()

	# Optionally override the animation based on vertical movement.
	# (This block should only override if you really want these states to take precedence.)
	if velocity.y > 1:
		desired_anim = "glide"
	elif velocity.y < -1:
		desired_anim = "jump"
	
		# Determine if we're crouching.
	if Input.is_action_pressed("down"):
		hitbox_normal.disabled = true
		hitbox_crouch.disabled = false
		desired_anim = "duck"
		if (velocity.x > 1 or velocity.x < -1) and (velocity.y == 0):
			desired_anim = "sneak"
	else:
		hitbox_normal.disabled = false
		hitbox_crouch.disabled = true
		desired_anim = "default"

	# Only change the animation if it isn't already playing.
	if sprite_2d.animation != desired_anim:
		sprite_2d.animation = desired_anim

	# Handle horizontal movement.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)

	move_and_slide()

	# Flip sprite based on direction.
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false
