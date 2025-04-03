extends Node2D

const duck_scene: PackedScene = preload("res://scenes/duck.tscn")
const bread_scene: PackedScene = preload("res://scenes/bread.tscn")
const egg_scene: PackedScene = preload("res://scenes/egg.tscn")
const finish_scene: PackedScene = preload("res://scenes/finish.tscn")
const player_scene: PackedScene = preload("res://scenes/main_character.tscn")
const weaponpickup_scene: PackedScene = preload("res://scenes/WeaponPickup.tscn")

const LEVEL_LENGTH = 55000.0
const TIME = 1000
const JUMP_VELOCITY = -900.0

var rng = RandomNumberGenerator.new()
signal level_ready

@onready var current_scene = self
@onready var inventory = preload("res://Inventory.gd").new()

func _ready() -> void:
	# DEBUGGING - Resetting Global level index for debug purposes
	Global.current_level_index = 11
	print_debug("Starting level setup for level index: ", Global.current_level_index)
	
	rng.randomize()
	
	# Initialize player first
	Global.spawn_player(player_scene, current_scene, Vector2(0, 638), TIME, JUMP_VELOCITY)
	print_debug("Player spawned and Global.main_character set: ", str(Global.main_character))
	
	# Ensure player is properly set before proceeding
	if Global.main_character == null:
		print_debug("Error: Global.main_character is not set before spawning enemies!")
		return

	
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
		Vector2(61170, -1650),
		Vector2(61570, -1650),
		Vector2(61970, -1650),
		Vector2(62370, -1650),
		Vector2(62770, -1650),
		Vector2(63170, -1650),
		Vector2(63570, -1650),
		Vector2(63970, -1650),
		Vector2(64370, -1650),
		Vector2(64770, -1650),
		Vector2(65170, -1650),
		Vector2(65570, -1650),
		Vector2(65970, -1650),
		Vector2(66370, -1650),
		Vector2(66770, -1650),
		Vector2(67170, -1650),
		Vector2(67570, -1650),
		Vector2(67970, -1650),
		Vector2(68370, -1650),
		Vector2(68770, -1650),
		Vector2(69170, -1650),
		Vector2(69570, -1650),
		Vector2(69970, -1650),
		Vector2(70370, -1650),
		Vector2(70770, -1650),
		Vector2(71170, -1650),
		Vector2(71570, -1650),
		Vector2(71970, -1650),
		Vector2(72370, -1650),
		Vector2(72770, -1650),
		Vector2(73170, -1650),
		Vector2(73570, -1650),
		Vector2(73970, -1650),
		Vector2(74370, -1650),
		Vector2(74770, -1650),
		Vector2(75170, -1650),
		Vector2(75570, -1650),
		Vector2(75970, -1650),
		Vector2(76370, -1650),
		Vector2(76770, -1650),
		Vector2(77170, -1650),
		Vector2(77570, -1650),
		Vector2(77970, -1650),
		Vector2(78370, -1650),
		Vector2(78770, -1650),
		Vector2(79170, -1650),
		Vector2(79570, -1650),
		Vector2(79970, -1650),
		Vector2(80370, -1650),

		# Starting at 52423 and incrementing by 1500
		Vector2(55423, -1249),
		Vector2(55823, -1249),
		Vector2(56223, -1249),
		Vector2(56623, -1249),
		Vector2(57023, -1249),
		Vector2(57423, -1249),
		Vector2(57823, -1249),
		Vector2(58223, -1249),
		Vector2(58623, -1249),
		Vector2(59023, -1249),
		Vector2(59423, -1249),
		Vector2(59823, -1249),
		Vector2(60223, -1249),
		Vector2(60623, -1249),
		Vector2(61023, -1249),
		Vector2(61423, -1249),
		Vector2(61823, -1249),
		Vector2(62223, -1249),
		Vector2(62623, -1249),
		Vector2(63023, -1249),
		Vector2(63423, -1249),
		Vector2(63823, -1249),
		Vector2(64223, -1249),
		Vector2(64623, -1249),
		Vector2(65023, -1249),
		Vector2(65423, -1249),
		Vector2(65823, -1249),
		Vector2(66223, -1249),
		Vector2(66623, -1249),
		Vector2(67023, -1249),
		Vector2(67423, -1249),
		Vector2(67823, -1249),
		Vector2(68223, -1249),
		Vector2(68623, -1249),
		Vector2(69023, -1249),
		Vector2(69423, -1249),
		Vector2(69823, -1249),
		Vector2(70223, -1249),
		Vector2(70623, -1249),
		Vector2(71023, -1249),
		Vector2(71423, -1249),
		Vector2(71823, -1249),
		Vector2(72223, -1249),
		Vector2(72623, -1249),
		Vector2(73023, -1249),
		Vector2(73423, -1249),
		Vector2(73823, -1249),
		Vector2(74223, -1249),
		Vector2(74623, -1249),
		Vector2(75023, -1249),
		Vector2(75423, -1249),
		Vector2(75823, -1249),
		Vector2(76223, -1249),
		Vector2(76623, -1249),
		Vector2(77023, -1249),
		Vector2(77423, -1249),
		Vector2(77823, -1249),
		Vector2(78223, -1249),

		
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
	#print_debug("Ducks spawned at positions: ", duck_spawn_locations)
	
	# Spawn camera after player
	Global.spawn_camera(current_scene, LEVEL_LENGTH)
	print_debug("Camera spawned with level length: ", LEVEL_LENGTH)
	
	emit_signal("level_ready")
	print_debug("Level setup completed and signal 'level_ready' emitted.")
