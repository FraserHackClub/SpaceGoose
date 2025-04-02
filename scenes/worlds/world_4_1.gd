extends Node2D




const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const cameramen_scene: PackedScene = preload("res://scenes/cameramen.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 200000
const TIME = 1000
const JUMP_VELOCITY = -900.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.KeyID = 0.0
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 9
	
	rng.randomize()
	#var possible_bread_spawn_locations = [


		
	#]
	#var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	var egg_spawn_locations = [
		
		Vector2(12220, 732),
		Vector2(13410, 730),
		Vector2(14659, 711),
		Vector2(15867, 540),
		Vector2(16636, 675),
		Vector2(18768, 320),
		Vector2(20024, 512),
		Vector2(20026, 675),
		Vector2(64126, 1271),
		Vector2(64925, 1268),
		Vector2(63294, 1144),
		Vector2(62599, 1214),
		Vector2(63487, 1631),
		Vector2(64570, 741),
		Vector2(65201, 1139),
		
		] #Vector2(9844, -171), Vector2(9844, -171), Vector2(11268, 67)
	#var duck_spawn_locations = [Vector2(34122,550)]
	#var weapon_pickup_locations = [Vector2(27055, -1797)]
	#var cameramen_spawn_locations = [Vector2(1462, 530), Vector2(4893,530)] #, Vector2(34122,567),
	var weapon_pickup_locations = [Vector2(84342, 2565)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY) # + , Jump_velosity
	#Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	#Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)

	#Global.spawn_enemies(cameramen_scene, current_scene, cameramen_spawn_locations)
	#Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
