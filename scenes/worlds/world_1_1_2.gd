extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 100000 #Test purposes, actual level length misaligned
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
		Vector2(768, 528),

	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 5)
	var egg_spawn_locations = [
		
		
		Vector2(6054, 970), 
		
		Vector2(13790, 576), 
		
		Vector2(21784, 682), 
		
		Vector2(23378, -5026), 
		
		Vector2(23369, -488), 
		
		#Vector2(36791, 551), 
		#Vector2(30809, 503), 
	
		Vector2(12757, -160), 
	]
	var duck_spawn_locations = [Vector2(5570, 647), 
	
	Vector2(6360, 647),
	
	Vector2(30247, 182),
	
	Vector2(20606, -36),
	]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(32966, 325), "win_zone")

	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
