extends PopupPanel

@onready var goose: CharacterBody2D = $"..".goose
@export var smooth_speed: float = 0.2

var juice_indices: Array = [
	"apple",
	"orange",
	"grape"
]

var current_index: int = 0
var selected_juice: String

func _process(_delta: float):
	if not visible:
		return

	if Input.is_action_just_pressed("ui_right"):
		current_index  += 1
	elif Input.is_action_just_pressed("ui_left"):
		current_index  -= 1
	
	if current_index >= juice_indices.size():
			current_index = juice_indices.size() - 1
	elif current_index < 0:
		current_index = 0

	selected_juice = juice_indices[current_index]
	
	for juice_node: HBoxContainer in $juice_arranger.get_children():
		if juice_node.name == selected_juice:
			juice_node.scale = lerp(juice_node.scale, Vector2(1.125, 1.125), smooth_speed)
		else:
			juice_node.scale = lerp(juice_node.scale, Vector2.ONE, smooth_speed)

	if Input.is_action_just_pressed("ui_accept"):
		if goose.use_juice(selected_juice):
			$"..".toggle_juice_menu()
