extends Node2D




const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const cameramen_scene: PackedScene = preload("res://scenes/cameramen.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 14000.0
const TIME = 180.0
const JUMP_VELOCITY = -900.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.KeyID = 0.0
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 8
	
	rng.randomize()
	var possible_bread_spawn_locations = [
		Vector2(10500, 189),
		Vector2(6057, 190),
		Vector2(6454, 347),
		Vector2(7420, 185),
		Vector2(9090, -134),
		Vector2(1735, -120),
		Vector2(2460, 301),
		Vector2(11259, -100),
		Vector2(4113, 380),
		Vector2(4448, 272),
		Vector2(4384, 336),
		
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	var egg_spawn_locations = [
		
		Vector2(46420, 335),
		Vector2(47564, 378),
		Vector2(43374, -374),
		Vector2(41113, -57),
		Vector2(34741, 291),
		Vector2(28829, -174),
		Vector2(26148, 160),
		Vector2(9691, -150),
		Vector2(11215, 126),
		
		] #Vector2(9844, -171), Vector2(9844, -171), Vector2(11268, 67)
	var duck_spawn_locations = [Vector2(34122,550)]
	#var weapon_pickup_locations = [Vector2(27055, -1797)]
	var cameramen_spawn_locations = [Vector2(1462, 530), Vector2(4893,530)] #, Vector2(34122,567),
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY) # + , Jump_velosity
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)

	Global.spawn_enemies(cameramen_scene, current_scene, cameramen_spawn_locations)
	#Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
