extends Camera2D

# --- Exported Settings ---
@export var smooth_speed: float = 0.8
@export var x_smooth_speed: float = 5.0
@export var vertical_deadzone_height: float = 500
@export var custom_camera_offset: Vector2 = Vector2(500, -400)
@onready var texture_rect = $HUD/TransitionSlider
@onready var transition_in_progress := false
# Viewport base size (before zoom)
const VIEWPORT_WIDTH = 1152.0
const VIEWPORT_HEIGHT = 648.0

# --- Dynamic bounds (updated via teleport) ---
var LEVEL_LENGTH: float = 5079.0
var LEVEL_HEIGHT: float = 1972.0

# --- State ---
var sublevel_index: float = 0.0
var teleported_this_frame: bool = false

# --- References ---
@onready var goose: CharacterBody2D = $"../goose"

func _ready() -> void:
	texture_rect.modulate.a = 0.0  # <-- THIS LINE ensures it starts transparent

	Global.camera_2d = self
	Global.bullet_counter = $HUD/BulletCounter/BulletCountLabel

	offset = custom_camera_offset


	if is_instance_valid(goose):
		_set_camera_start_position()

func _set_camera_start_position() -> void:
	var vpw = VIEWPORT_WIDTH * zoom.x
	var vph = VIEWPORT_HEIGHT * zoom.y
	position = Vector2(
		clamp(goose.position.x + (vpw * 0.5), 0.0, LEVEL_LENGTH - vpw),
		clamp(goose.position.y - (vph * 0.5), 0.0, LEVEL_HEIGHT - vph)
	)

func _process(delta: float) -> void:
	
	if transition_in_progress:
		return  # ✅ freeze camera logic during fade transitions

	if teleported_this_frame:
		print("⏸️ Skipping camera logic this frame due to teleport")
		teleported_this_frame = false
		return

	if not is_instance_valid(goose):
		return

	
	if teleported_this_frame:
		print("⏸️ Skipping camera logic this frame due to teleport")
		teleported_this_frame = false
		return

	if not is_instance_valid(goose):
		return

	offset = custom_camera_offset

	var vpw = VIEWPORT_WIDTH * zoom.x
	var vph = VIEWPORT_HEIGHT * zoom.y

	var target_x = clamp(goose.position.x - (vpw * 0.25), 0.0, LEVEL_LENGTH - vpw)
	var target_y = position.y

	#print("🧭 Camera Position: ", position)
	#print("🎯 Goose Position: ", goose.position)
	#print("📐 Level Bounds: ", LEVEL_LENGTH, LEVEL_HEIGHT)

	# --- Level 0 & 1: Horizontal only ---
	if Global.current_level_index == 0 or Global.current_level_index == 1 or Global.current_level_index == 2:
		custom_camera_offset = Vector2(500, 0)
		position.x = lerp(position.x, target_x, x_smooth_speed * delta)
		return

	# --- Level 2 (dynamic vertical behavior) ---
	if Global.current_level_index == 3 or Global.current_level_index == 4 or Global.current_level_index == 5:
		var effective_center_y = position.y + custom_camera_offset.y
		var top_edge = effective_center_y - vertical_deadzone_height / 2
		var bottom_edge = effective_center_y + vertical_deadzone_height / 2

#------------------------------

		#if goose.position.y < top_edge:
			#target_y = goose.position.y + vertical_deadzone_height / 2
		#elif goose.position.y > bottom_edge:
			#target_y = goose.position.y - vertical_deadzone_height / 2

		if goose.position.y < top_edge:
			target_y = goose.position.y - (vph / 2) + vertical_deadzone_height / 2 - custom_camera_offset.y
		elif goose.position.y > bottom_edge:
			target_y = goose.position.y + (vph / 2) - vertical_deadzone_height / 2 - custom_camera_offset.y

		# Clamp to section bounds
		target_y = clamp(target_y, 0.0, LEVEL_HEIGHT - vph)

		position.x = lerp(position.x, target_x, x_smooth_speed * delta)
		position.y = lerp(position.y, target_y, smooth_speed * delta)
	

func teleport_to_section(destination: Vector2, new_bounds: Vector2, new_offset: Vector2, new_sublevel_index: float) -> void:
	#print("🚀 TELEPORTING CAMERA")
	print("New Bounds: ", new_bounds)
	print("New Offset: ", new_offset)
	print("Teleport Destination: ", destination)
	
	goose.disable()
	await fade_in(1.0)  # wait for fade to black
	
	await get_tree().create_timer(2.0).timeout
	# These bounds are now in *world-space*
	LEVEL_LENGTH = destination.x + new_bounds.x
	LEVEL_HEIGHT = destination.y + new_bounds.y
	custom_camera_offset = new_offset
	sublevel_index = new_sublevel_index

	position = destination - custom_camera_offset
	teleported_this_frame = true
	await get_tree().create_timer(2.0).timeout
	await fade_out(1.0)  # fade back to game
	goose.enable()

func fade_in(duration := 1.0):
	transition_in_progress = true
	texture_rect.show()
	texture_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_out(duration := 1.0):
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 0.0, duration)
	await tween.finished
	texture_rect.hide()
	transition_in_progress = false
