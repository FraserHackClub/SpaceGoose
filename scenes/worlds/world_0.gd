# Template level setup script

extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
#const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 5056.0
const TIME = 60.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	var possible_bread_spawn_locations = [
		# Populate with *possible* spawn locations for bread
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 5)
	var egg_spawn_locations = [
		# Populate with spawn locations for eggs
	]
	var duck_spawn_locations = [
		# Populate with spawn locations for ducks
	]
	
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	
#	Swap out the coords on the following line for  
	Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 439), "win_zone")
	
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
