
extends Camera2D

@export var smoothing: float = 0.1
@export var fixed_y_position: float = 300.0


var shake_strength: float = 0.0
@export var shake_decay: float = 10.0
@export var shake_max_offset: float = 10.0

func _ready():
	global_position.y = fixed_y_position

func _physics_process(delta):
	if !get_parent():
		return
		
	var target_x = get_parent().global_position.x
	var new_x = lerp(global_position.x, target_x, smoothing)
	
	var shake_offset = Vector2.ZERO
	if shake_strength > 0:
		shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		) * shake_max_offset
		
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	
	offset = shake_offset
	global_position = Vector2(new_x, fixed_y_position)

func add_shake(amount: float = 0.5):
	shake_strength = max(shake_strength, amount)  #
