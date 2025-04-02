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
	
	Vector2(12132, -713),
	Vector2(12260, -713),
	Vector2(12388, -713),
	Vector2(12516, -713),
	Vector2(12644, -713),
	Vector2(12772, -713),
	Vector2(12900, -713),
	Vector2(13028, -713),
	Vector2(13156, -713),
	Vector2(13284, -713),
	Vector2(13412, -713),
	Vector2(13540, -713),
	Vector2(13668, -713),
	Vector2(13796, -713),
	Vector2(13924, -713),
	Vector2(14052, -713),
	Vector2(14180, -713),
	Vector2(14308, -713),
	Vector2(14436, -713),
	Vector2(14564, -713),
	Vector2(14692, -713),
	Vector2(14820, -713),
	Vector2(14948, -713),
	Vector2(15076, -713),
	Vector2(15204, -713),
	Vector2(15332, -713),
	Vector2(15460, -713),
	Vector2(15588, -713),
	Vector2(15716, -713),
	Vector2(15844, -713),
	Vector2(15972, -713),
	Vector2(16100, -713),
	Vector2(16228, -713),
	Vector2(16356, -713),
	Vector2(16484, -713),
	Vector2(16612, -713),
	Vector2(16740, -713),
	Vector2(16868, -713),
	Vector2(16996, -713),
	Vector2(17124, -713),
	Vector2(17252, -713),
	Vector2(17380, -713),
	Vector2(17508, -713),
	Vector2(17636, -713),
	Vector2(17764, -713),
	Vector2(17892, -713),
	Vector2(18020, -713),
	Vector2(18148, -713),
	Vector2(18276, -713),
	Vector2(18404, -713),
	Vector2(18532, -713),
	Vector2(18660, -713),
	Vector2(18788, -713),
	Vector2(18916, -713),
	Vector2(19044, -713),
	Vector2(19172, -713),
	Vector2(19300, -713),
	Vector2(19428, -713),
	Vector2(19556, -713),
	Vector2(19684, -713),
	Vector2(19812, -713),
	Vector2(19940, -713),
	Vector2(20068, -713),
	Vector2(20196, -713),
	Vector2(20324, -713),
	Vector2(20452, -713),
	Vector2(20580, -713),
	Vector2(20708, -713),
	Vector2(20836, -713),
	Vector2(20964, -713),
	Vector2(21092, -713),
	Vector2(21220, -713),
	Vector2(21348, -713),
	Vector2(21476, -713),
	Vector2(21604, -713),
	Vector2(21732, -713),
	Vector2(21860, -713),
	Vector2(21988, -713),
	Vector2(22116, -713),
	Vector2(22244, -713),
	Vector2(22372, -713),
	Vector2(22500, -713),
	Vector2(22628, -713),
	Vector2(22756, -713),
	Vector2(22884, -713),
	Vector2(23012, -713),
	Vector2(23140, -713),
	Vector2(23268, -713),
	Vector2(23396, -713),
	Vector2(23524, -713),
	Vector2(23652, -713),
	Vector2(23780, -713),
	Vector2(23908, -713),
	Vector2(24036, -713),
	Vector2(24164, -713),
	Vector2(24292, -713),
	Vector2(24420, -713),
	Vector2(24548, -713),
	Vector2(24676, -713),
	Vector2(24804, -713),
	Vector2(24932, -713),
	Vector2(25060, -713),
	Vector2(25188, -713),
	Vector2(25316, -713),
	Vector2(25444, -713),
	Vector2(25572, -713),
	Vector2(25700, -713),
	Vector2(25828, -713),
	Vector2(25956, -713),
	Vector2(26084, -713),
	Vector2(26212, -713),
	Vector2(26340, -713),
	Vector2(26468, -713),
	Vector2(26596, -713),
	Vector2(26724, -713),
	Vector2(26852, -713),
	Vector2(26980, -713),
	Vector2(27108, -713),
	Vector2(27236, -713),
	Vector2(27364, -713),
	Vector2(27492, -713),
	Vector2(27620, -713),
	Vector2(27748, -713),
	Vector2(27876, -713),
	Vector2(28004, -713),
	Vector2(28132, -713),
	Vector2(28260, -713),
	Vector2(28388, -713),
	Vector2(28516, -713),
	Vector2(28644, -713),
	Vector2(28772, -713),
	Vector2(28900, -713),
	Vector2(29028, -713),
	Vector2(29156, -713),
	Vector2(29284, -713),
	Vector2(29412, -713),
	Vector2(29540, -713),
	Vector2(29668, -713),
	Vector2(29796, -713),
	Vector2(29924, -713),
	Vector2(30052, -713),
	Vector2(30180, -713),
	Vector2(30308, -713),
	Vector2(30436, -713),
	Vector2(30564, -713),
	Vector2(30692, -713),
	Vector2(30820, -713),
	Vector2(30948, -713),
	Vector2(31076, -713),
	Vector2(31204, -713),
	Vector2(31332, -713),
	Vector2(31460, -713),
	Vector2(31588, -713),
	Vector2(31716, -713),
	Vector2(31844, -713),
	Vector2(31869, -713),
	Vector2(32400, -713)

	]
	Global.spawn_player(player_scene, current_scene, Vector2(0, 0), TIME, JUMP_VELOCITY)
	Global.spawn_items(bread_scene, current_scene, bread_spawn_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(basket_scene, current_scene, basket_spawn_locations)
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_entity(finish_scene, current_scene, Vector2(40352, 138), "win_zone")
	#Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
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
