extends Camera2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var camera_2d: Camera2D = self

@export var smooth_speed: float = 0.1
@export var LEVEL_LENGTH: float = 5120.0

var VIEWPORT_WIDTH: float = 1152.0
var VIEWPORT_HEIGHT: float = 648.0

func _ready():
	# Update viewport size before using it
	update_viewport_size()
	# Ensure camera starts at the correct position
	position.x = clamp(goose.position.x, VIEWPORT_WIDTH / 2, LEVEL_LENGTH - VIEWPORT_WIDTH / 2)

func _process(_delta: float) -> void:
	if is_instance_valid(goose):
		var target_x = clamp(goose.position.x, VIEWPORT_WIDTH / 2, LEVEL_LENGTH - VIEWPORT_WIDTH / 2)
		position.x = lerp(position.x, target_x, smooth_speed)

func update_viewport_size():
	# Get the actual viewport size
	VIEWPORT_WIDTH = get_viewport_rect().size.x
	VIEWPORT_HEIGHT = get_viewport_rect().size.y
