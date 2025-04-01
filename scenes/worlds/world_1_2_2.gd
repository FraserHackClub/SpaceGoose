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
const LEVEL_LENGTH = 41810
const TIME = 120.0
const JUMP_VELOCITY = -1400

@onready var current_scene = self


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
	var dripstone_spawn_locations = [
	
		Vector2(12132, -1213),
		Vector2(12260, -1213),
		Vector2(12388, -1213),
		Vector2(12516, -1213),
		Vector2(12644, -1213),
		Vector2(12772, -1213),
		Vector2(12900, -1213),
		Vector2(13028, -1213),
		Vector2(13156, -1213),
		Vector2(13284, -1213),
		Vector2(13412, -1213),
		Vector2(13540, -1213),
		Vector2(13668, -1213),
		Vector2(13796, -1213),
		Vector2(13924, -1213),
		Vector2(14052, -1213),
		Vector2(14180, -1213),
		Vector2(14308, -1213),
		Vector2(14436, -1213),
		Vector2(14564, -1213),
		Vector2(14692, -1213),
		Vector2(14820, -1213),
		Vector2(14948, -1213),
		Vector2(15076, -1213),
		Vector2(15204, -1213),
		Vector2(15332, -1213),
		Vector2(15460, -1213),
		Vector2(15588, -1213),
		Vector2(15716, -1213),
		Vector2(15844, -1213),
		Vector2(15972, -1213),
		Vector2(16100, -1213),
		Vector2(16228, -1213),
		Vector2(16356, -1213),
		Vector2(16484, -1213),
		Vector2(16612, -1213),
		Vector2(16740, -1213),
		Vector2(16868, -1213),
		Vector2(16996, -1213),
		Vector2(17124, -1213),
		Vector2(17252, -1213),
		Vector2(17380, -1213),
		Vector2(17508, -1213),
		Vector2(17636, -1213),
		Vector2(17764, -1213),
		Vector2(17892, -1213),
		Vector2(18020, -1213),
		Vector2(18148, -1213),
		Vector2(18276, -1213),
		Vector2(18404, -1213),
		Vector2(18532, -1213),
		Vector2(18660, -1213),
		Vector2(18788, -1213),
		Vector2(18916, -1213),
		Vector2(19044, -1213),
		Vector2(19172, -1213),
		Vector2(19300, -1213),
		Vector2(19428, -1213),
		Vector2(19556, -1213),
		Vector2(19684, -1213),
		Vector2(19812, -1213),
		Vector2(19940, -1213),
		Vector2(20068, -1213),
		Vector2(20196, -1213),
		Vector2(20324, -1213),
		Vector2(20452, -1213),
		Vector2(20580, -1213),
		Vector2(20708, -1213),
		Vector2(20836, -1213),
		Vector2(20964, -1213),
		Vector2(21092, -1213),
		Vector2(21220, -1213),
		Vector2(21348, -1213),
		Vector2(21476, -1213),
		Vector2(21604, -1213),
		Vector2(21732, -1213),
		Vector2(21860, -1213),
		Vector2(21988, -1213),
		Vector2(22116, -1213),
		Vector2(22244, -1213),
		Vector2(22372, -1213),
		Vector2(22500, -1213),
		Vector2(22628, -1213),
		Vector2(22756, -1213),
		Vector2(22884, -1213),
		Vector2(23012, -1213),
		Vector2(23140, -1213),
		Vector2(23268, -1213),
		Vector2(23396, -1213),
		Vector2(23524, -1213),
		Vector2(23652, -1213),
		Vector2(23780, -1213),
		Vector2(23908, -1213),
		Vector2(24036, -1213),
		Vector2(24164, -1213),
		Vector2(24292, -1213),
		Vector2(24420, -1213),
		Vector2(24548, -1213),
		Vector2(24676, -1213),
		Vector2(24804, -1213),
		Vector2(24932, -1213),
		Vector2(25060, -1213),
		Vector2(25188, -1213),
		Vector2(25316, -1213),
		Vector2(25444, -1213),
		Vector2(25572, -1213),
		Vector2(25700, -1213),
		Vector2(25828, -1213),
		Vector2(25956, -1213),
		Vector2(26084, -1213),
		Vector2(26212, -1213),
		Vector2(26340, -1213),
		Vector2(26468, -1213),
		Vector2(26596, -1213),
		Vector2(26724, -1213),
		Vector2(26852, -1213),
		Vector2(26980, -1213),
		Vector2(27108, -1213),
		Vector2(27236, -1213),
		Vector2(27364, -1213),
		Vector2(27492, -1213),
		Vector2(27620, -1213),
		Vector2(27748, -1213),
		Vector2(27876, -1213),
		Vector2(28004, -1213),
		Vector2(28132, -1213),
		Vector2(28260, -1213),
		Vector2(28388, -1213),
		Vector2(28516, -1213),
		Vector2(28644, -1213),
		Vector2(28772, -1213),
		Vector2(28900, -1213),
		Vector2(29028, -1213),
		Vector2(29156, -1213),
		Vector2(29284, -1213),
		Vector2(29412, -1213),
		Vector2(29540, -1213),
		Vector2(29668, -1213),
		Vector2(29796, -1213),
		Vector2(29924, -1213),
		Vector2(30052, -1213),
		Vector2(30180, -1213),
		Vector2(30308, -1213),
		Vector2(30436, -1213),
		Vector2(30564, -1213),
		Vector2(30692, -1213),
		Vector2(30820, -1213),
		Vector2(30948, -1213),
		Vector2(31076, -1213),
		Vector2(31204, -1213),
		Vector2(31332, -1213),
		Vector2(31460, -1213),
		Vector2(31588, -1213),
		Vector2(31716, -1213),
		Vector2(31844, -1213),
		Vector2(31869, -1213),


		Vector2(32400, -1213),
	]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(40352, 138), "win_zone")
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	Global.spawn_enemies(dripstone_scene, current_scene, dripstone_spawn_locations)
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
