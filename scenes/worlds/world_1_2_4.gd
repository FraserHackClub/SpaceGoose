extends Node2D
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const dripstone_scene: PackedScene = preload("res://scenes/dripstone.tscn")
const basket_scene: PackedScene = preload("res://scenes/basket.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")
const galactic_scene: PackedScene = preload("res://scenes/galacticBasket.tscn")

var rng = RandomNumberGenerator.new()
const LEVEL_LENGTH = 70000
const TIME = 240
const JUMP_VELOCITY = -1400
signal level_ready
@onready var inventory = preload("res://Inventory.gd").new()
func _ready() -> void:
	
	var current_scene = self
	Global.current_level_index = 6

	#var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	var duck_spawn_locations = [Vector2(23283,-17204),
	Vector2(34808,-17204),
	
	Vector2(37493,-13241),
	Vector2(41251,-13241),
	
	
	
	]
	var egg_spawn_locations = [Vector2(17690,11014), 
	]
	var galactic_spawn_locations = [Vector2(17996, 35829), Vector2(17093, 35831), Vector2(36571, 11498)]
	var basket_spawn_locations = [Vector2(17683,11110), Vector2(17883, 11110), Vector2(18155, 11110)]
	#var dripstone_spawn_locations = [Vector2(7484, 40), Vector2(7674, 40), Vector2(7784, 40), Vector2(7912, 62), Vector2(8040,60), Vector2(8168,56), Vector2(8296,62), Vector2(7576, 46)]
	Global.spawn_player(player_scene, current_scene, Vector2(385, 25000), TIME, JUMP_VELOCITY)
	
	
	
	#Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_items(galactic_scene,current_scene,galactic_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(52098, -913), "win_zone")
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	#Global.spawn_enemies(dripstone_scene, current_scene, dripstone_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	# Toggle helmet visibility after a short delay to ensure player is fully loaded
	
	#print(Global.LEVEL_LENGTH)
	
	emit_signal("level_ready")
# Simple function to toggle the helmet visibility
