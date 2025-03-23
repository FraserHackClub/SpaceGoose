extends Control

@export var smooth_speed: float = 0.2
@onready var pointer: AnimatedSprite2D = $pointer
@onready var main: Node = $".."
@onready var score_label = $Score/ScoreLabel

var popup_scene: PackedScene = preload("res://scenes/insufficient_score_popup.tscn")
var popup_window: PopupPanel

var inventory: Inventory

var current_index: int = 0
var clicking_phase: int = 0
var call_action: bool = false

var positions = [
	Vector2(32.0, 416.0),
	Vector2(288.0, 272.0),
	Vector2(448.0, 572.0)
]

@onready var planets = [
	$Earth,
	$Moon,
	$Mars
]

func _ready() -> void:
	inventory.fetch_inventory()
	current_index = inventory.current_level
	pointer.position = positions[current_index]
	score_label.text = str(inventory.score)

func _process(_delta: float) -> void:
	if clicking_phase > 0:
		match clicking_phase:
			1:
				pointer.position = lerp(pointer.position, Vector2(positions[current_index].x + 32, positions[current_index].y - 32), smooth_speed)
			2:
				pointer.position = lerp(pointer.position, positions[current_index], smooth_speed)
		
		if round(pointer.position.x) == round(positions[current_index].x + 32):
			clicking_phase = 2
		elif round(pointer.position.x) == round(positions[current_index].x):
			clicking_phase = 0
	elif call_action:
		if inventory.score >= Global.level_score_reqs[current_index]:
			call_action = false
			$Start_sound.play()
			main.load_level(current_index)
			queue_free()
		else:
			call_action = false
			$Wrong_sound.play()
			popup_window = popup_scene.instantiate()
			add_child(popup_window)
			popup_window.set_score(inventory.score, Global.level_score_reqs[current_index])
	elif get_node_or_null("Popup"):
		pass
	else:
		if Input.is_action_just_pressed("ui_right"):
			current_index  += 1
			$Select_sound.play()
		elif Input.is_action_just_pressed("ui_left"):
			current_index  -= 1
			$Select_sound.play()
		
		if current_index >= positions.size():
			current_index = positions.size() - 1
		elif current_index < 0:
			current_index = 0
		
		pointer.position = lerp(pointer.position, positions[current_index], smooth_speed)
		
		for planet: TextureRect in planets:
			if planet == planets[current_index]:
				planet.scale = lerp(planet.scale, Vector2(1.05, 1.05), smooth_speed)
			else:
				planet.scale = lerp(planet.scale, Vector2(1.0, 1.0), smooth_speed)
		
		if Input.is_action_just_pressed("ui_accept"):
			$Click_sound.play()
			call_action = true
			clicking_phase = 1
		elif Input.is_action_just_pressed("ui_cancel"):
			main.load_menu()
			queue_free()
