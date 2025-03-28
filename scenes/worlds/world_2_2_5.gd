extends Node2D




const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 6000.0
const TIME = 60.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 5
	


	#var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	#var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 526), Vector2(27008, -1616), Vector2(2440, 1007), Vector2(11010, 563), Vector2(28992, 1094), Vector2(39661, 1377), Vector2(40157, 897), Vector2(40406, 1376), Vector2(42097, 1519)]
	#var duck_spawn_locations = [Vector2(3079, 624), Vector2(22930,836), Vector2(29725,2870), Vector2(27151,-1335), Vector2(40914, 1635), Vector2(39839, 1635), Vector2(39035, 1635), Vector2(42043, 1564)]
	#var weapon_pickup_locations = [Vector2(27055, -1797)]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	#Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	#Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	#Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, inventory) # + , Jump_velosity
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
#func _process(delta: float) -> void:
	#pass#print(Global.main_character.global_position)
	
