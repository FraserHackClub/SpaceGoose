extends Node2D




const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 55000.0
const TIME = 600.0
const JUMP_VELOCITY = -900.0

var rng = RandomNumberGenerator.new()

signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#GLOBAL RESET DEBUGGING SCRIPT!
	Global.current_level_index = 13
	
	rng.randomize()
	var possible_bread_spawn_locations = [
		Vector2(768, 528),
		Vector2(1600, 336),
		Vector2(1600, 528),
		Vector2(2496, 528),
		Vector2(2816, 528),
		Vector2(2976, 528),
		Vector2(5024, 208),
		Vector2(4705, 208),
		Vector2(4512, 208),
		Vector2(4448, 272),
		Vector2(4384, 336),
		
	]
	#var bread_spawn_locations = Global.get_random_element(possible_bread_spawn_locations, rng, 20)
	#var egg_spawn_locations = [Vector2(1650, 526), Vector2(4640, 526), Vector2(27008, -1616), Vector2(2440, 1007), Vector2(11010, 563), Vector2(28992, 1094), Vector2(39661, 1377), Vector2(40157, 897), Vector2(40406, 1376), Vector2(42097, 1519)]
	var duck_spawn_locations = [
		
		Vector2(66000, 3935),
		Vector2(66189, 3935),
		Vector2(72017, 4654),
		
		
		Vector2(72417, 4654),
		Vector2(72517, 4654),
		Vector2(72617, 4654),
		Vector2(72717, 4654),
		Vector2(72817, 4654),
		Vector2(72917, 4654),
		Vector2(73017, 4654),
		Vector2(73117, 4654),
		Vector2(73217, 4654),
		Vector2(73317, 4654),
		Vector2(73417, 4654),
		Vector2(73517, 4654),
		Vector2(73617, 4654),
		Vector2(73717, 4654),
		Vector2(73817, 4654),
		Vector2(73917, 4654),
		Vector2(74017, 4654),
		Vector2(74117, 4654),
		Vector2(74217, 4654),
		Vector2(74317, 4654),
		Vector2(74417, 4654),
		Vector2(74517, 4654),
		Vector2(74617, 4654),
		Vector2(74717, 4654),
		Vector2(74817, 4654),
		Vector2(74917, 4654),
		Vector2(75017, 4654),
		Vector2(75117, 4654),
		Vector2(75217, 4654),
		Vector2(75317, 4654),
		Vector2(75417, 4654),
		Vector2(75517, 4654),
		Vector2(75617, 4654),
		Vector2(75717, 4654),
		Vector2(75817, 4654),
		Vector2(75917, 4654),
		Vector2(76017, 4654),
		Vector2(76117, 4654),
		Vector2(76217, 4654),
		Vector2(76317, 4654),
		Vector2(76417, 4654),
		Vector2(76517, 4654),
		Vector2(76617, 4654),
		Vector2(76717, 4654),
		Vector2(76817, 4654),
		Vector2(76917, 4654),
		Vector2(77017, 4654),
		Vector2(77117, 4654),
		Vector2(77217, 4654),
		Vector2(77317, 4654),
		Vector2(77417, 4654),
		Vector2(77517, 4654),
		Vector2(77617, 4654),
		Vector2(77717, 4654),
		Vector2(77817, 4654),
		Vector2(77917, 4654),
		Vector2(78017, 4654),
		Vector2(78117, 4654),
		Vector2(78217, 4654),
		Vector2(78317, 4654),
		Vector2(78417, 4654),
		Vector2(78517, 4654),
		Vector2(78617, 4654),
		Vector2(78717, 4654),
		Vector2(78817, 4654),
		Vector2(78917, 4654),
		Vector2(79017, 4654),
		Vector2(79117, 4654),
		Vector2(79217, 4654),
		Vector2(79317, 4654),
		Vector2(79402, 4654),





		Vector2(59195, 2717),
		Vector2(61472, 2717),
		Vector2(63749, 2717),
		Vector2(66026, 2717),
		Vector2(68303, 2717),
		Vector2(70580, 2717),

		Vector2(68717, 4655),
		Vector2(69117, 4655),
		Vector2(69517, 4655),
		Vector2(69917, 4655),
		Vector2(70317, 4655),
		Vector2(70717, 4655),
		Vector2(71117, 4655),
		Vector2(71494, 4655),

		Vector2(71843, 3831),
		Vector2(65671, 3935),
		Vector2(65847, 3935),

		

		Vector2(57365, 5010),
		Vector2(57765, 5010),
		Vector2(58165, 5010),
		Vector2(58565, 5010),
		Vector2(58965, 5010),
		Vector2(59365, 5010),
		Vector2(59765, 5010),
		Vector2(60165, 5010),
		Vector2(60565, 5010),
		Vector2(60965, 5010),
		Vector2(61365, 5010),
		Vector2(61765, 5010),
		Vector2(62165, 5010),
		Vector2(62565, 5010),
		Vector2(62965, 5010),
		Vector2(63365, 5010),
		Vector2(63765, 5010),
		Vector2(64165, 5010),
		Vector2(64565, 5010),
		Vector2(64965, 5010),
		Vector2(65365, 5010),
		Vector2(65765, 5010),
		Vector2(66165, 5010),
		Vector2(66565, 5010),
		Vector2(66965, 5010),
		Vector2(67365, 5010),
		Vector2(67765, 5010),
		Vector2(68165, 5010),
		Vector2(68565, 5010),
		Vector2(68965, 5010),
		Vector2(69365, 5010),
		Vector2(69765, 5010),
		Vector2(70165, 5010),
		Vector2(70565, 5010),
		Vector2(70965, 5010),
		Vector2(71365, 5010),
		Vector2(71765, 5010),
		Vector2(72165, 5010),
		Vector2(72565, 5010),
		Vector2(72965, 5010),
		Vector2(73365, 5010),
		Vector2(73765, 5010),
		Vector2(74165, 5010),
		Vector2(74565, 5010),
		Vector2(74965, 5010),
		Vector2(75365, 5010),
		Vector2(75765, 5010),
		Vector2(76165, 5010),
		Vector2(76565, 5010),
		Vector2(76965, 5010),
		Vector2(77365, 5010),
		Vector2(77765, 5010),
		Vector2(78165, 5010),
		Vector2(78565, 5010),
		Vector2(78965, 5010),
		Vector2(79365, 5010),
		Vector2(79765, 5010),
		Vector2(80165, 5010),
		Vector2(80565, 5010),
		Vector2(80691, 5010),

		
		
		
		
		
		]
	var weapon_pickup_locations = [Vector2(954, 567)]
	#var weapon_pickup_locations = [Vector2(1328, 496)]
	#Global.spawn_items(bread_scene, current_scene,  bread_spawn_locations)
	Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(weaponpickup_scene, current_scene,  weapon_pickup_locations)
	#Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	#Global.spawn_entity(finish_scene, current_scene, Vector2(4862, 900), "win_zone")
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY) # + , Jump_velosity
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	#Global.update_helmet_visibility()
	emit_signal("level_ready")
	
#func _process(delta: float) -> void:
	#pass#print(Global.main_character.global_position)
	
