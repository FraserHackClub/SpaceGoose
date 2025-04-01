extends Control

@export var smooth_speed: float = 0.2
@onready var pointer: Node2D = $pointer
@onready var main: Node = $".."
@onready var score_label = $Score/ScoreLabel
@onready var levelselect_theme: AudioStreamPlayer = $levelselect_theme

var popup_scene: PackedScene = preload("res://scenes/insufficient_score_popup.tscn")
var popup_window: PopupPanel

var inventory: Inventory

var current_index: int = 0
var call_action: bool = false
var sub_selector_active: bool = false  # New flag to detect if sublevel selection is active

var positions = [
	Vector2(32.0, 416.0),
	Vector2(288.0, 272.0),
	Vector2(384.0, 508.0),
	Vector2(592.0, 376.0),

	Vector2(802.0, 542.0)

]

@onready var planets = [
	$Earth,
	$Moon,
	$Mars,
	$Asteroids,

	$Spaceship

]

# Dictionary to map planets to their respective sublevels
var planet_sublevels = {
	0: [0, 1, 2],       # Earth -> Level indexes: 0, 1, 2
	1: [3, 4, 5],          # Moon -> Level indexes: 3, 4
	2: [6, 7],    # Mars -> Level indexes: 5, 6, 7, 8
	3: [8],         # Asteroids -> Level indexes: 9, 10
	#4: [9, 10, 11, 12] #SPACESHIP
}

func _ready() -> void:
	levelselect_theme.play()
	inventory = preload("res://Inventory.gd").new()
	inventory.fetch_inventory()
	current_index = inventory.current_level
	
	if current_index >= positions.size():
		current_index = -1
	elif current_index < 0:
		current_index = 0
	
	pointer.action = click_action
	pointer.position = positions[current_index]
	score_label.text = str(inventory.score)

func _process(_delta: float) -> void:
	if call_action:
		call_action = false
		sub_selector_active = true  # Now enter sublevel selection mode
	elif sub_selector_active:
		if current_index in planet_sublevels:  # Make sure the planet has defined sublevels
			var sublevels = planet_sublevels[current_index]

			for i in range(1, 10):  # Listen for number keys 1 to 9
				if Input.is_action_just_pressed("board_" + str(i)):
					var sublevel_index = i - 1  # 1 becomes 0, 2 becomes 1, etc.

					if sublevel_index >= sublevels.size():
						continue  # Ignore if the number is out of range for this planet

					var global_index = sublevels[sublevel_index]  # Get the actual index from the list

					if global_index >= len(Global.level_score_reqs):
						continue  # Ignore if it's an invalid level index

					if inventory.score >= Global.level_score_reqs[global_index]:
						$Start_sound.play()
						await get_tree().create_timer(0.3).timeout
						main.load_level(global_index)  # Load the calculated level index
						queue_free()
					else:
						$Wrong_sound.play()
						popup_window = popup_scene.instantiate()
						add_child(popup_window)
						popup_window.set_score(inventory.score, Global.level_score_reqs[global_index])
					sub_selector_active = false
					return  # Exit early to prevent further input processing

		if Input.is_action_just_pressed("ui_cancel"):
			sub_selector_active = false  # Cancel the sublevel selection

	elif get_node_or_null("Popup"):
		pass
	else:
		if Input.is_action_just_pressed("ui_right"):
			if current_index < positions.size() - 1:
				current_index  += 1
				$Select_sound.play()
		elif Input.is_action_just_pressed("ui_left"):

			current_index  -= 1
			$Select_sound.play()
		
		if current_index >= positions.size():
			current_index = -1
		elif current_index < 0:
			current_index = 0

		
		pointer.position = lerp(pointer.position, positions[current_index], smooth_speed)
		
		for planet: TextureRect in planets:
			if planet == planets[current_index]:
				planet.scale = lerp(planet.scale, Vector2(1.05, 1.05), smooth_speed)
			else:
				planet.scale = lerp(planet.scale, Vector2(1.0, 1.0), smooth_speed)
		
		if Input.is_action_just_pressed("ui_accept"):
			pointer.click()
		elif Input.is_action_just_pressed("ui_cancel"):
			main.load_menu()
			queue_free()

func click_action() -> void:
	call_action = true
