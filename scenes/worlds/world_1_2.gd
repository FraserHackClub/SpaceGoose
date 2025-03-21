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
const LEVEL_LENGTH = 11500
const TIME = 120.0
const JUMP_VELOCITY = -1400

@onready var current_scene = self

@onready var inventory = preload("res://Inventory.gd").new()


signal level_ready

func _ready() -> void:
	var possible_bread_spawn_locations = [
		Vector2(530, 400),
		Vector2(1480, 512),
		Vector2(2150,400),
		Vector2(2760, 400),
		Vector2(3272, 180),
		Vector2(4090, 294),
		Vector2(4484, 510),
		Vector2(4877, 291),
		Vector2(5540, 400),
		Vector2(5910, 176),
		Vector2(6474, 320),
		Vector2(7314,394),
		Vector2(8614, 456),
		Vector2(9254, 380),
		Vector2(9892, 460),
		Vector2(10658, 486)
	]
	var weapon_pickup_locations = [Vector2(8670, -851)]
	rng.randomize()
	var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 10)
	var duck_spawn_locations = [Vector2(3172,400), Vector2(8390,384), Vector2(10416,384)]
	var egg_spawn_locations = [Vector2(3172,400), Vector2(8390,384), Vector2(10416,384)]
	var basket_spawn_locations = [Vector2(810,430), Vector2(7444, 416), Vector2(7864, -65)]
	var dripstone_spawn_locations = [Vector2(7484, 40), Vector2(7674, 40), Vector2(7784, 40), Vector2(7912, 62), Vector2(8040,60), Vector2(8168,56), Vector2(8296,62), Vector2(7576, 46)]
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_enemies(dripstone_scene, current_scene, dripstone_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(11150, 460), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, inventory, JUMP_VELOCITY)
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
		helmet.visible = !helmet.visible
		print("Helmet visibility toggled to: ", helmet.visible)
	else:
		print("Could not find goose or helmet node")
