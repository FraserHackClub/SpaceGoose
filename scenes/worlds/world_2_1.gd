extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 16000.0
const TIME = 180.0
const JUMP_VELOCITY = -900.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 4
	
	rng.randomize()
	var possible_bread_spawn_locations = [
		#Vector2(768, 528),

		
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	var egg_spawn_locations = [	Vector2(8895, 609),
	Vector2(8995, 609),
	Vector2(9137, 609),
	Vector2(9237, 609),
	Vector2(10904, 609),
	Vector2(11904, 609),

	Vector2(12150, 609),
	Vector2(12250, 609),

	Vector2(26997, -1578),
	Vector2(27099, 90),
	Vector2(30327, 1209),
	Vector2(29068, -922),
	Vector2(40406, 1360),
	Vector2(39672, 1360),
	Vector2(40151, 889),
	Vector2(38991, 1097),

	Vector2(41979, 1432),
	Vector2(42048, 1432),
	Vector2(42117, 1432),
	Vector2(42186, 1432),
	Vector2(42255, 1432),
	Vector2(42324, 1432),
	Vector2(42393, 1432),
	Vector2(27081, -1881),
	
	]
	var duck_spawn_locations = [Vector2(767, 634),
		Vector2(1000, 634),

		Vector2(1767, 634),

		Vector2(8200, 634),
		Vector2(7900, 634),

		Vector2(9200, 634),
		Vector2(10000, 634),

		Vector2(11717, 634),
		
		
		
		
		
		
		
		Vector2(22545, 889),
		Vector2(22755, 889),
		Vector2(22965, 889),
		Vector2(23175, 889),
		Vector2(23385, 889),
		
		
		Vector2(30819, 650),
	
		Vector2(31239, 650),
	
		Vector2(31659, 650),

		Vector2(32079, 650),

		Vector2(32499, 650),

		Vector2(33129, 650),


		Vector2(33759, 650),

		Vector2(34179, 650),
		Vector2(34389, 650),
	
	
		Vector2(35019, 650),
		Vector2(35229, 650),
		Vector2(35439, 650),


		Vector2(36069, 650),
		Vector2(36279, 650),

		Vector2(36909, 650),
		
		Vector2(41495, 1640),
		Vector2(40610, 1640),
		Vector2(38868, 1640)
	

		]
	var weapon_pickup_locations = [Vector2(27055, -1797)]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	#Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
