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
const TIME = 300
const JUMP_VELOCITY = -1400.0
const LEVEL_LENGTH = 30000
signal level_ready

@onready var inventory = preload("res://Inventory.gd").new()

func _ready() -> void:
	var current_scene = self
	var possible_bread_spawn_locations = [
		Vector2(854, 284),
		Vector2(1008, 370),
		Vector2(2104, 361),
		Vector2(3916, 390),
		Vector2(4972, 338),
		Vector2(7900, 410),
		Vector2(8727, 198),
		Vector2(10698, 300),
		Vector2(12128, 243),
		Vector2(5175, 554),
		Vector2(12807, 201),
		Vector2(15119, 215),
		Vector2(8214, 556),
		Vector2(8471, 558),
		Vector2(15942, 362),
		Vector2(17343, 298),
		Vector2(19702, 219),
		Vector2(21565, 465),
		Vector2(22858, 281),
		Vector2(24107, 89),
		Vector2(25578, 197),
		Vector2(27044, 59),
		Vector2(28553, 118),
		Vector2(29374, 417),
		Vector2(30433, 308),
		Vector2(31288, 139),
		Vector2(34363, 218),
		Vector2(37642, 205),
		Vector2(39517, 164),
		
		
	]
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	var duck_spawn_locations = [
		Vector2(5862, 382),
		Vector2(9602, 456),
		Vector2(14466, 337),
		Vector2(20467, 368),
		Vector2(26275, 320),
		Vector2(28886, 480),
		Vector2(35779, 418),
		Vector2(40531, 509)
	]
	var basket_spawn_locations = [Vector2(5824, 415), Vector2(7394, 141), Vector2(20434, 399), Vector2(36700, 100)]
	var galactic_spawn_locations = [Vector2(6794, 488), Vector2(41492, -123), Vector2(33616, 602)]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 550), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	Global.spawn_items(galactic_scene, current_scene, galactic_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	Global.spawn_entity(finish_scene, current_scene, Vector2(29380, 360), "win_zone")
	emit_signal("level_ready")
