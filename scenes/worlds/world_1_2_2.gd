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
const TIME = 300.0
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
	
	Vector2(12132, -628),
	Vector2(12260, -628),
	Vector2(12388, -628),
	Vector2(12516, -628),
	Vector2(12644, -628),
	Vector2(12772, -628),
	Vector2(12900, -628),
	Vector2(13028, -628),
	Vector2(13156, -628),
	Vector2(13284, -628),
	Vector2(13412, -628),
	Vector2(13540, -628),
	Vector2(13668, -628),
	Vector2(13796, -628),
	Vector2(13924, -628),
	Vector2(14052, -628),
	Vector2(14180, -628),
	Vector2(14308, -628),
	Vector2(14436, -628),
	Vector2(14564, -628),
	Vector2(14692, -628),
	Vector2(14820, -628),
	Vector2(14948, -628),
	Vector2(15076, -628),
	Vector2(15204, -628),
	Vector2(15332, -628),
	Vector2(15460, -628),
	Vector2(15588, -628),
	Vector2(15716, -628),
	Vector2(15844, -628),
	Vector2(15972, -628),
	Vector2(16100, -628),
	Vector2(16228, -628),
	Vector2(16356, -628),
	Vector2(16484, -628),
	Vector2(16612, -628),
	Vector2(16740, -628),
	Vector2(16868, -628),
	Vector2(16996, -628),
	Vector2(17124, -628),
	Vector2(17252, -628),
	Vector2(17380, -628),
	Vector2(17508, -628),
	Vector2(17636, -628),
	Vector2(17764, -628),
	Vector2(17892, -628),
	Vector2(18020, -628),
	Vector2(18148, -628),
	Vector2(18276, -628),
	Vector2(18404, -628),
	Vector2(18532, -628),
	Vector2(18660, -628),
	Vector2(18788, -628),
	Vector2(18916, -628),
	Vector2(19044, -628),
	Vector2(19172, -628),
	Vector2(19300, -628),
	Vector2(19428, -628),
	Vector2(19556, -628),
	Vector2(19684, -628),
	Vector2(19812, -628),
	Vector2(19940, -628),
	Vector2(20068, -628),
	Vector2(20196, -628),
	Vector2(20324, -628),
	Vector2(20452, -628),
	Vector2(20580, -628),
	Vector2(20708, -628),
	Vector2(20836, -628),
	Vector2(20964, -628),
	Vector2(21092, -628),
	Vector2(21220, -628),
	Vector2(21348, -628),
	Vector2(21476, -628),
	Vector2(21604, -628),
	Vector2(21732, -628),
	Vector2(21860, -628),
	Vector2(21988, -628),
	Vector2(22116, -628),
	Vector2(22244, -628),
	Vector2(22372, -628),
	Vector2(22500, -628),
	Vector2(22628, -628),
	Vector2(22756, -628),
	Vector2(22884, -628),
	Vector2(23012, -628),
	Vector2(23140, -628),
	Vector2(23268, -628),
	Vector2(23396, -628),
	Vector2(23524, -628),
	Vector2(23652, -628),
	Vector2(23780, -628),
	Vector2(23908, -628),
	Vector2(24036, -628),
	Vector2(24164, -628),
	Vector2(24292, -628),
	Vector2(24420, -628),
	Vector2(24548, -628),
	Vector2(24676, -628),
	Vector2(24804, -628),
	Vector2(24932, -628),
	Vector2(25060, -628),
	Vector2(25188, -628),
	Vector2(25316, -628),
	Vector2(25444, -628),
	Vector2(25572, -628),
	Vector2(25700, -628),
	Vector2(25828, -628),
	Vector2(25956, -628),
	Vector2(26084, -628),
	Vector2(26212, -628),
	Vector2(26340, -628),
	Vector2(26468, -628),
	Vector2(26596, -628),
	Vector2(26724, -628),
	Vector2(26852, -628),
	Vector2(26980, -628),
	Vector2(27108, -628),
	Vector2(27236, -628),
	Vector2(27364, -628),
	Vector2(27492, -628),
	Vector2(27620, -628),
	Vector2(27748, -628),
	Vector2(27876, -628),
	Vector2(28004, -628),
	Vector2(28132, -628),
	Vector2(28260, -628),
	Vector2(28388, -628),
	Vector2(28516, -628),
	Vector2(28644, -628),
	Vector2(28772, -628),
	Vector2(28900, -628),
	Vector2(29028, -628),
	Vector2(29156, -628),
	Vector2(29284, -628),
	Vector2(29412, -628),
	Vector2(29540, -628),
	Vector2(29668, -628),
	Vector2(29796, -628),
	Vector2(29924, -628),
	Vector2(30052, -628),
	Vector2(30180, -628),
	Vector2(30308, -628),
	Vector2(30436, -628),
	Vector2(30564, -628),
	Vector2(30692, -628),
	Vector2(30820, -628),
	Vector2(30948, -628),
	Vector2(31076, -628),
	Vector2(31204, -628),
	Vector2(31332, -628),
	Vector2(31460, -628),
	Vector2(31588, -628),
	Vector2(31716, -628),
	Vector2(31844, -628),
	Vector2(31869, -628),
	Vector2(32400, -628)


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
