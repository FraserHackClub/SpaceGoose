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

func _ready() -> void:
	# DEBUGGING - Resetting Global level index for debug purposes
	Global.current_level_index = 5
	print_debug("Starting level setup for level index: ", Global.current_level_index)
	
	rng.randomize()
	
	# Initialize player first
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY)
	print_debug("Player spawned and Global.main_character set: ", str(Global.main_character))
	
	# Ensure player is properly set before proceeding
	if Global.main_character == null:
		print_debug("Error: Global.main_character is not set before spawning enemies!")
		return

	# Spawn camera after player
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	print_debug("Camera spawned with level length: ", LEVEL_LENGTH)
	
	# Spawn eggs
	var egg_spawn_locations = [Vector2(59752, 1801), Vector2(63811, 1785), Vector2(63911, 1785), Vector2(64336, 1807), Vector2(64633, 1860), Vector2(66692, 1194), Vector2(67444, 1207), Vector2(60036, 1842), Vector2(54136, -300), Vector2(67490, 1001), Vector2(68021, 1234)]
	Global.spawn_items(egg_scene, current_scene, egg_spawn_locations)
	print_debug("Eggs spawned at positions: ", egg_spawn_locations)
	
	# Spawn weapon pickups
	var weapon_pickup_locations = [Vector2(575, 615)]
	Global.spawn_items(weaponpickup_scene, current_scene, weapon_pickup_locations)
	print_debug("Weapon pickups spawned at positions: ", weapon_pickup_locations)
	
	# Spawn enemies (Ducks) after everything else
	var duck_spawn_locations = [Vector2(57770, -1650),
		Vector2(60770, -1650),
		Vector2(63770, -1650),
		Vector2(65270, -1650),
		Vector2(66770, -1650),
		Vector2(68270, -1650),
		Vector2(69770, -1650),
		
		Vector2(72770, -1650),
		Vector2(74270, -1650),
		
		Vector2(77270, -1650),
		Vector2(78770, -1650),
		Vector2(80270, -1650),

		# Starting at 52423 and incrementing by 1500
		Vector2(52423, -1249),

		Vector2(55423, -1249),
		Vector2(56923, -1249),
		Vector2(58423, -1249),
		Vector2(59923, -1249),
		Vector2(61423, -1249),
		
		Vector2(65923, -1249),
		Vector2(67423, -1249),
		Vector2(68923, -1249),
		Vector2(70423, -1249),
		Vector2(71923, -1249),
		Vector2(73423, -1249),
		
		Vector2(77923, -1249),
		
		Vector2(80923, -1249),
		
		Vector2(52777, 1215),  # CHECK AGAIN?
		Vector2(54000, 1215),
		
		Vector2(55107, 894),
		Vector2(56800, 894),
		
		Vector2(52484, 775),
		
		Vector2(54672, -201),
		Vector2(56000, -201),
		
		Vector2(53560, -976),
		Vector2(57000, -976),
		Vector2(59000, -976),
		Vector2(62000, -976),
		Vector2(64000, -976),
		Vector2(66000, -976),
		Vector2(69000, -976),
		
		Vector2(58594, 735),  # CHECK AGAIN?!
		
		Vector2(57756, 1303),
		
		Vector2(74400, 1869),
		Vector2(76000, 1869),
		Vector2(78000, 1869),
		Vector2(80000, 1869),
		
		Vector2(68626, 515)
	]


	
	Global.spawn_enemies(duck_scene, current_scene, duck_spawn_locations)
	print_debug("Ducks spawned at positions: ", duck_spawn_locations)
	
	emit_signal("level_ready")
	print_debug("Level setup completed and signal 'level_ready' emitted.")
