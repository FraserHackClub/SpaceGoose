extends Control

var current_index: int = 0

@onready var bread: TextureRect = $Bread
@export var smooth_speed: float = 0.2

var y_positions = [170.0, 330.0]
var actions = [
	play, gambling
]

func _ready() -> void:
	bread.position.y = y_positions[current_index]
	bread.position.x = 626.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		current_index  = 1
	elif Input.is_action_just_pressed("ui_up"):
		current_index = 0
	
	bread.position.y = lerp(bread.position.y, y_positions[current_index], smooth_speed)
	
	if Input.is_action_just_pressed("ui_accept"):
		actions[current_index].call()

func play() -> void:
	print("Starting game...")

func gambling() -> void:
	print("Wasting monies")
