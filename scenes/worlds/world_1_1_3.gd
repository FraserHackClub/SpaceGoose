extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")
const juice_scene: PackedScene = preload("res://scenes/juice.tscn")

const LEVEL_LENGTH = 35000
const TIME = 210.0
const JUMP_VELOCITY = -900

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	Global.toggle_fps_display()
	var possible_bread_spawn_locations = [
		Vector2(768, -800),
		Vector2(1600, -800),
		Vector2(1600, -800),
		Vector2(2496, -800),
		Vector2(2816, -800),
		Vector2(2976, -800),
		Vector2(5024, -800),
		Vector2(4705, -800),
		Vector2(4512, -800),
		Vector2(4448, -800),
		Vector2(4384, -800)
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 5)
	var egg_spawn_locations = [Vector2(13182, 294), 
	
	Vector2(14466, 239),
	Vector2(17586, 1),
	Vector2(23057, 224),
	Vector2(24177, 965),
	Vector2(28293, -433),
	
	
	]
	var duck_spawn_locations = [Vector2(23719, 900), 
	
	Vector2(28070, 450),
	Vector2(28533, 450),
	
	Vector2(28271, -115),
	
	Vector2(24101, 975), #CHECK AGAIN?! or 29101
	
	Vector2(17005, 763),
	Vector2(18134, 763),
	
	Vector2(17587, 283),
	
	]
	var juice_locations = [Vector2(23854, 933), Vector2(24542, 936), Vector2(2692, 498)]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_juice(juice_scene, current_scene, juice_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(31440, -648), "win_zone")

	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
