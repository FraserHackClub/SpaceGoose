extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900.0
const DUCKING_MULTIPLIER = 0.75

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var hitbox_normal = $CollisionShape2D
@onready var hitbox_crouch = $CollisionShape2D_Duck
@onready var inventory_labels = {
	"egg": $"../HUD/EggCounter/EggCountLabel",
	"bread": $"../HUD/BreadCounter/BreadCountLabel",
}

var jumpcount = 0

var inventory = {
	"egg": 0,
	"bread": 0,
}


func _ready():
	sprite_2d.animation = "default"
	update_inventory_labels()
	$Sprite2D2.hide()
	$PickupArea.connect("body_entered", _on_area_body_entered)

func _on_area_body_entered(body):
	# Powerups
	if body.is_in_group("item"): # Assuming items are in the "item" group
		collect_item(body)

func collect_item(item: Object):
	if item.is_in_group("egg"):
		inventory["egg"] += 1
	if item.is_in_group("bread"):
		inventory["bread"] += 1
	update_inventory_labels()

func update_inventory_labels():
	for item in inventory.keys():
		inventory_labels[item].text = str(inventory[item])
	

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
	var desired_anim = "default"
	
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * (1.5 if Input.is_action_pressed("down") else 1)
	else:
		jumpcount = 0

	# Handle jumping.
	if Input.is_action_just_pressed("jump") and jumpcount < 2:
		velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
		jumpcount += 1

	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
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
		velocity.x = direction * SPEED * (DUCKING_MULTIPLIER if Input.is_action_pressed("down") else 1)
	else:
		velocity.x = move_toward(velocity.x, 0, 12)

	move_and_slide()

	# Flip sprite based on direction.
	if direction < 0:
		sprite_2d.flip_h = true
	elif direction > 0:
		sprite_2d.flip_h = false
