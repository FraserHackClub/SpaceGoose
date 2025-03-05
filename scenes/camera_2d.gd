extends Camera2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var tilemap = $"../Terrain"  # Updated tilemap path

@export var smooth_speed_x: float = 0.1
@export var smooth_speed_y: float = 0.1

const LEVEL_END_X = 13000.0
const VIEWPORT_WIDTH_X = 560.0
#WARN ING, SUPPOSEDLY ALL Y-VALUES ARE RELATIVE TO THE CENTER OF THE TILEMAP, NOT THE WORLD!
# Default camera zoom settings:
@export var default_zoom: Vector2 = Vector2(1, 1)
@export var min_zoom_factor: float = 0.3

# Altitudes at which the camera transitions back to regular zoom
@export var upper_transition_altitude: float = -1000 # Defines when zoom stops increasing above y=0
@export var lower_transition_altitude: float = 2500   # Defines when zoom stops increasing below y=0

# Level boundaries in world coordinates (computed from the TileMap)
var level_left: float
var level_top: float
var level_right: float
var level_bottom: float

func _ready():
	if tilemap:
		var used_rect = tilemap.get_used_rect()
		var cell_size: Vector2 = Vector2(16, 16)
		level_left   = used_rect.position.x * cell_size.x
		level_top    = used_rect.position.y * cell_size.y
		level_right  = (used_rect.position.x + used_rect.size.x) * cell_size.x
		level_bottom = (used_rect.position.y + used_rect.size.y) * cell_size.y
		###print("Level Bottom is: ", level_bottom)

		# Set initial camera position to the goose.
		###position = goose.position
		###print("Initial camera position set to: ", position)
	###else:
		###print("Terrain TileMap not found at '../Terrain'.")

func _process(delta: float) -> void:
	if not is_instance_valid(goose):
		return

	var viewport_size = get_viewport_rect().size

	# -------------------------------
	# Horizontal (X) Follow
	# -------------------------------
	var target_x = min(max(0.0, goose.position.x), (LEVEL_END_X - VIEWPORT_WIDTH_X))
	var new_x = lerp(position.x, target_x, smooth_speed_x)

	# -------------------------------
	# Vertical (Y) and Dynamic Zoom
	# -------------------------------
	var effective_ground: float = 1000
	  # In respect to the position of Tilemap. Ground is fixed at y = 0 supposedly, but adjust such that this is the actual "ground" of the level

	var new_zoom: Vector2
	var new_y: float

	if goose.position.y < upper_transition_altitude:
		# Player is far above ground: Max zoom-out to fit player and y=0
		#new_zoom = Vector2(min_zoom_factor, min_zoom_factor) #TRY ALTERNATIVE
		new_zoom = Vector2(1, 1)
		new_y = lerp(position.y, goose.position.y, smooth_speed_y)
		###print("DEBUG: Upper Zoom-Out Mode. New Zoom:", new_zoom, " | New Y:", new_y)
	elif goose.position.y > lower_transition_altitude:
		# Player is far below ground: Max zoom-out to fit player and y=0
		#new_zoom = Vector2(min_zoom_factor, min_zoom_factor) #TRY ALTERNATIVE
		new_y = lerp(position.y, goose.position.y, smooth_speed_y)
		new_zoom = Vector2(1, 1)
		###print("DEBUG: Lower Zoom-Out Mode. New Zoom:", new_zoom, " | New Y:", new_y)
	else:
		# Player is within zoom region: Adjust zoom to fit y=0 and player
		var distance_from_ground = abs(goose.position.y - effective_ground)
		var t = clamp(distance_from_ground / max(abs(upper_transition_altitude), lower_transition_altitude), 0.0, 1.0)
		var desired_zoom = lerp(default_zoom.y, min_zoom_factor, t)
		new_zoom = Vector2(desired_zoom, desired_zoom)
		new_y = lerp(position.y, goose.position.y, smooth_speed_y)
		###print("DEBUG: Zoom Adjustment Mode. New Zoom:", new_zoom, " | New Y:", new_y)

	###print("DEBUG: Goose X:", goose.position.x, " | Target X:", target_x, " | New X:", new_x)

	# Smoothly interpolate the camera's zoom.
	zoom = zoom.lerp(new_zoom, smooth_speed_y)

	# Apply the new camera position.
	position.x = new_x
	position.y = new_y
