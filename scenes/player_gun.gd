extends Node2D

@onready var barrel_marker: Marker2D = $BarrelMarker2D
@onready var SPRITE: AnimatedSprite2D = $AnimatedSprite2D2
@onready var bullet_counter: Label = $"../../HUD/BulletCounter/BulletCountLabel"



var BULLET = preload("res://scenes/bullet.tscn")
var Bulletamount = int(30)


var is_reloading = false  # Prevents shooting & animation override

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -0.75
	else:
		scale.y = 0.75

	if Input.is_action_just_pressed("reload") and not is_reloading:
		await _reload()
	
	if Input.is_action_just_pressed("shoot") and not is_reloading:
		_shoot()

	if not is_reloading:
		_handle_animation()
	bullet_counter.text = str(Bulletamount)
func _reload() -> void:
	is_reloading = true
	print("Setting animation to Reloading")
	
	SPRITE.animation = "AK47_Reloading"
	SPRITE.play()  # Ensure the animation actually plays

	# Manually set the reload animation duration (adjust to match your animation length)
	var reload_time = 1.4  
	print("Waiting for reload animation:", reload_time, "seconds")

	await get_tree().create_timer(reload_time).timeout  # Wait for the animation to finish
	
	Bulletamount = int(30)

	print("Setting animation to Default")
	SPRITE.animation = "AK47_Default"
	SPRITE.play()  # Ensure default animation plays

	is_reloading = false
	print("Reload complete!")

func shake(node: Node2D, duration: float = 1.0, intensity: float = 5.0):
	var original_position = node.position  # Store original position
	var shake_time = duration
	while shake_time > 0:
		shake_time -= 0.05  # Decrease shake time per iteration
		node.position = original_position + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		await get_tree().create_timer(0.05).timeout  # Wait for a short time before shaking again
	node.position = original_position  # Reset position after shaking

func _shoot():
	if Bulletamount > 0:
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = barrel_marker.global_position
		bullet_instance.rotation = rotation
		Bulletamount -= 1
	else:
		shake($AnimatedSprite2D2, 0.3, 5.0) #Time in seconds, Intensity

func _handle_animation():
	if is_reloading:
		print("Skipping animation override during reload")  # Debugging
		return  
	SPRITE.animation = "AK47_Default"
