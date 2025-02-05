extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -900.0
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionShape2D
@onready var hitbox_crouch = $CollisionShape2D_Duck
var jumpcount = 0


func _ready():
	sprite_2d.animation = "default"
	$Sprite2D2.hide()
	
func _process(delta):
	if Input.is_action_pressed("down"):
		# When crouching, disable the normal hitbox and enable the crouch hitbox.
		hitbox_normal.disabled = true
		hitbox_crouch.disabled = false

	else:
		# When not crouching, enable the normal hitbox and disable the crouch hitbox.
		hitbox_normal.disabled = false
		hitbox_crouch.disabled = true



func _physics_process(delta: float) -> void:
	sprite_2d.animation = "default"
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		jumpcount = 0
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumpcount < 2:
		velocity.y = JUMP_VELOCITY
		jumpcount += 1
	
	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY
		$Sprite2D2.show()
		await get_tree().create_timer(0.2).timeout
		$Sprite2D2.hide()	
		
	if Input.is_action_pressed("down"):
		sprite_2d.animation = "duck"
		# When crouching, disable the normal hitbox and enable the crouch hitbox.

		
		
	if velocity.y > 1:
		sprite_2d.animation = "glide"
	elif velocity.y < -1:
		sprite_2d.animation = "jump"

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)

	move_and_slide()
	
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false
	
