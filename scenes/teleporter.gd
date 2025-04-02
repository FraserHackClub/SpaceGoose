extends Node2D

@export var teleport_destination: Vector2
@export var camera_section_length: float = 16281.0
@export var camera_section_height: float = 900.0
@export var camera_offset: Vector2
@export var sublevel_index: float = 0.0

@onready var teleported = false

func _ready():
	add_to_group("teleporter")
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	var camera = Global.camera_2d
	if camera:

		camera.teleport_to_section(
			teleport_destination,
			Vector2(camera_section_length, camera_section_height),
			camera_offset,
			sublevel_index
		)

	body.global_position = teleport_destination
	teleported = true
