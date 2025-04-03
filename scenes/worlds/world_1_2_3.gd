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
const LEVEL_LENGTH = 41810
const TIME = 500.0
const JUMP_VELOCITY = -1400

@onready var current_scene = self


signal level_ready

func _ready() -> void:
	var possible_bread_spawn_locations = [
		Vector2(530, -1000),
	]
	#var weapon_pickup_locations = [Vector2(8670, -851)]
	rng.randomize()
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	#var duck_spawn_locations = [Vector2(3172,400),]
	var egg_spawn_locations = [Vector2(17690,11014), 
	
	]
	var basket_spawn_locations = [Vector2(17683,11110), Vector2(17883, 11110), Vector2(18155, 11110)]
	var galactic_spawns = [Vector2(29311, 10892),Vector2(18710, 10955)]
	var duck_spawn_locations = [Vector2(3201, 399), Vector2(28902, 5600), Vector2(20291, 10911), Vector2(42070, 320)]
	#var dripstone_spawn_locations = [Vector2(7484, 40), Vector2(7674, 40), Vector2(7784, 40), Vector2(7912, 62), Vector2(8040,60), Vector2(8168,56), Vector2(8296,62), Vector2(7576, 46)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	#Global.spawn_items(galactic_scene,current_scene, galactic_spawns)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(42642, 240), "win_zone")
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	#Global.spawn_enemies(dripstone_scene, current_scene, dripstone_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	# Toggle helmet visibility after a short delay to ensure player is fully loaded
	await get_tree().create_timer(0.1).timeout
	toggle_helmet()
	
	emit_signal("level_ready")
# Simple function to toggle the helmet visibility
func toggle_helmet() -> void:
	var goose = get_node_or_null("goose")
	if not goose:
		# Try finding the goose in a common container like LevelContainer
		goose = get_node_or_null("LevelContainer/goose")
	
	if goose and goose.has_node("Helmet"):
		var helmet = goose.get_node("Helmet")
		helmet.visible = true
		print("Helmet visibility set to: ", helmet.visible)
	else:
		print("Could not find goose or helmet node")
