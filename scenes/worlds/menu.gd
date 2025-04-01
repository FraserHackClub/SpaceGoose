extends Control

var current_index: int = 0

const JUMP_VELOCITY = -1400

@onready var pointer: Node2D = $pointer
@onready var main_theme: AudioStreamPlayer = $main_theme
@export var smooth_speed: float = 0.2
@export var play: Callable
@export var select_level: Callable

var inventory: Inventory
var y_positions = [300.0, 460.0]
var actions: Array
var call_action = false

func _ready() -> void:
	main_theme.play()
	
	inventory = preload("res://Inventory.gd").new()
	pointer.position.y = y_positions[current_index]
	pointer.position.x = 632.0
	pointer.action = click_action
	actions = [
		play, select_level
	]


func _process(_delta: float) -> void:
	if call_action:
		if $Start_sound.playing or $Goose.position.y >= -500:
			$Goose.velocity.y = JUMP_VELOCITY
			$Goose.move_and_slide()
		else:
			actions[current_index].call()
			queue_free()
	else:
		if Input.is_action_just_pressed("ui_down"):
			current_index  = 1
			$Select_sound.play()
		elif Input.is_action_just_pressed("ui_up"):
			current_index = 0
			$Select_sound.play()
		
		pointer.position.y = lerp(pointer.position.y, y_positions[current_index], smooth_speed)
		
		if Input.is_action_just_pressed("ui_accept"):
			pointer.click()

func click_action() -> void:
	call_action = true
	$Goose/Goose.animation = "jump"
	$Start_sound.play()

func _on_restart_pressed() -> void:
	inventory.populate_inventory()
