extends Node2D
<<<<<<< Updated upstream
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const dripstone_scene: PackedScene = preload("res://scenes/dripstone.tscn")
const basket_scene: PackedScene = preload("res://scenes/basket.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

var rng = RandomNumberGenerator.new()
const TIME = 180.0
const JUMP_VELOCITY = -1400.0
const LEVEL_LENGTH = 13170
signal level_ready

@onready var inventory = preload("res://Inventory.gd").new()

func _ready() -> void:
	var current_scene = self
	var possible_bread_spawn_locations = [
		Vector2(768, 500),
		Vector2(1008, 370),
		Vector2(1403, 243),
		Vector2(1977, 239),
		Vector2(2122, 307),
		Vector2(2886, 371),
		Vector2(3635, 254),
		Vector2(4060, 313),
		Vector2(4815, 361),
		Vector2(5175, 554),
		Vector2(5829, 522),
		Vector2(6233, 524),
		Vector2(8214, 556),
		Vector2(8471, 558),
		Vector2(8984, 552),
		Vector2(9892, 251),
		Vector2(10390, 253),
		Vector2(12680, 253)
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	var duck_spawn_locations = [
		Vector2(1735, 84),
		Vector2(2686,464),
		Vector2(3060, 464),
		Vector2(7110, 817),
		Vector2(6647, 817),
		Vector2(8044, 464),
		Vector2(9760, 224),
		Vector2(12389, 225)
	]
	var weapon_pickup_locations = [Vector2(492, 500)]
	var egg_spawn_locations = [Vector2(2818, 485), Vector2(-676, 409)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 550), TIME, inventory, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	Global.spawn_entity(finish_scene, current_scene, Vector2(13009, 165), "win_zone")
	emit_signal("level_ready")
=======




const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 16000.0
const TIME = 180.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 2
	
	rng.randomize()
	var possible_bread_spawn_locations = [
		Vector2(768, 528),
		Vector2(1600, 336),
		Vector2(1600, 528),
		Vector2(2496, 528),
		Vector2(2816, 528),
		Vector2(2976, 528),
		Vector2(5024, 208),
		Vector2(4705, 208),
		Vector2(4512, 208),
		Vector2(4448, 272),
		Vector2(4384, 336),
		
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 526), Vector2(27008, -1616), Vector2(2440, 1007), Vector2(11010, 563), Vector2(28992, 1094), Vector2(39661, 1377), Vector2(40157, 897), Vector2(40406, 1376), Vector2(42097, 1519)]
	var duck_spawn_locations = [Vector2(3079, 624), Vector2(22930,836), Vector2(29725,2870), Vector2(27151,-1335), Vector2(40914, 1635), Vector2(39839, 1635), Vector2(39035, 1635), Vector2(42043, 1564)]
	var weapon_pickup_locations = [Vector2(27055, -1797)]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
>>>>>>> Stashed changes
