extends Control

var current_index: int = 0

@onready var bread: AnimatedSprite2D = $Bread
@export var smooth_speed: float = 0.2
@export var play: Callable
@export var gamble: Callable


var y_positions = [236.0, 396.0]
var actions: Array

func _ready() -> void:
	bread.position.y = y_positions[current_index]
	bread.position.x = 696.0
	actions = [
		play, gamble
	]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		current_index  = 1
	elif Input.is_action_just_pressed("ui_up"):
		current_index = 0
	
	bread.position.y = lerp(bread.position.y, y_positions[current_index], smooth_speed)
	
	if Input.is_action_just_pressed("ui_accept"):
		actions[current_index].call()
		queue_free()
