extends Node2D
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const dripstone_scene: PackedScene = preload("res://scenes/dripstone.tscn")
const basket_scene: PackedScene = preload("res://scenes/basket.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

var rng = RandomNumberGenerator.new()
const TIME = 120.0
const JUMP_VELOCITY = -1400.0
const LEVEL_LENGTH = 13170
signal level_ready

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
	Global.spawn_player(player_scene, current_scene, Vector2(0, 550), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	Global.spawn_entity(finish_scene, current_scene, Vector2(13009, 165), "win_zone")
	emit_signal("level_ready")
