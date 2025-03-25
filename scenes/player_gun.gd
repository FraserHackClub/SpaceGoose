extends Node2D

@onready var barrel_marker: Marker2D = $BarrelMarker2D
@onready var SPRITE: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sfx_gunshoot: AudioStreamPlayer = $Gun_Shoot
@onready var sfx_gunreload: AudioStreamPlayer = $Gun_Reload

var BULLET = preload("res://scenes/bullet.tscn")
var Bulletamount = 30
var is_reloading = false  # Prevents shooting & animation override
var activated = false  # Controls gun visibility and function

func _ready():
	if Global.bullet_counter:
		print_debug("BulletCountLabel found at:", Global.bullet_counter.get_path())
	else:
		printerr("BulletCountLabel not assigned! Check Main Scene.")

	# Initially hide and disable gun processing
	self.hide()
	self.set_process(false)
	self.set_physics_process(false)

func _process(_delta: float) -> void:
	if not activated:
		self.hide()
		return  # Prevents execution if gun is not activated

	# Ensure gun is visible and active when activated
	if not self.visible:
		print_debug("Gun is now active and visible!")
	self.show()

	look_at(get_global_mouse_position())

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -0.75
	else:
		scale.y = 0.75

	if Input.is_action_just_pressed("Reload") and not is_reloading:
		await _reload()

	if Input.is_action_just_pressed("Shoot") and not is_reloading:
		_shoot()

	if not is_reloading:
		_handle_animation()

	# Update bullet counter on UI
	if Global.bullet_counter:
		Global.bullet_counter.text = str(Bulletamount)

	#print_debug("Gun Process Running | Activated:", activated, "| Visible:", self.visible)

func _pickedup() -> void:
	print_debug("_pickedup() function called!")  # Verify function call
	activated = true

	# Enable visibility and processing
	self.show()
	self.set_process(true)
	self.set_physics_process(true)

	#print_debug("Gun picked up! Activated:", activated, "| Visible:", self.visible)

func _reload() -> void:
	if not activated:
		print_debug("Cannot reload, gun is not active!")
		return

	is_reloading = true
	print_verbose("Setting animation to Reloading")
	sfx_gunreload.play()
	SPRITE.animation = "AK47_Reloading"
	SPRITE.play()  # Ensure the animation plays

	var reload_time = 1.4  
	print_verbose("Waiting for reload animation:", reload_time, "seconds")

	await get_tree().create_timer(reload_time).timeout  # Wait for the animation to finish
	
	Bulletamount = 30

	print_verbose("Setting animation to Default")
	SPRITE.animation = "AK47_Default"
	SPRITE.play()

	is_reloading = false
	print_debug("Reload complete!")

func shake(node: Node2D, duration: float = 1.0, intensity: float = 5.0):
	var original_position = node.position  # Store original position
	var shake_time = duration
	while shake_time > 0:
		shake_time -= 0.05  # Decrease shake time per iteration
		node.position = original_position + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		await get_tree().create_timer(0.05).timeout  # Wait for a short time before shaking again
	node.position = original_position  # Reset position after shaking

func _shoot():
	if not activated:
		print_debug("Cannot shoot, gun is not active!")
		return

	if Bulletamount > 0:
		sfx_gunshoot.play()
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = barrel_marker.global_position
		bullet_instance.rotation = rotation
		Bulletamount -= 1
	else:
		shake($AnimatedSprite2D2, 0.3, 5.0)  # Time in seconds, Intensity

func _handle_animation():
	if is_reloading:
		print_verbose("Skipping animation override during reload")  # Debugging
		return  
	SPRITE.animation = "AK47_Default"
