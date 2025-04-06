extends Camera2D



# --- Exported Settings ---
@export var smooth_speed: float = 0.9
@export var x_smooth_speed: float = 5.0
@export var vertical_deadzone_height: float = 300
@export var custom_camera_offset: Vector2 = Vector2(500, -400)
@onready var texture_rect = $HUD/TransitionSlider
@onready var transition_in_progress := false
# Viewport base size (before zoom)
const VIEWPORT_WIDTH = 1152.0
const VIEWPORT_HEIGHT = 648.0

# --- Dynamic bounds (changed IF updated via teleport) ---
var LEVEL_LENGTH: float = 500000.0
var LEVEL_HEIGHT: float = 100000
# --- State ---
var sublevel_index: float = 0.0
var teleported_this_frame: bool = false
var playing_cutscene: bool = false

# --- Level-specific Camera Configuration ---
var level_camera_settings = {
	1: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	2: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	3: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	4: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 70000.0, "custom_camera_offset": Vector2(800, -1800) },
	5: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 70000.0, "custom_camera_offset": Vector2(800, -1800) },
	6: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 150000.0, "custom_camera_offset": Vector2(800, -1800) },
	7: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 70000.0, "custom_camera_offset": Vector2(800, -1800) },
	8: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 100000.0, "custom_camera_offset": Vector2(800, -1800) },
	9: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	10: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	11: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
	12: { "LEVEL_LENGTH": 100000.0, "LEVEL_HEIGHT": 16000.0, "custom_camera_offset": Vector2(800, -1800) },
}

# --- References ---
#@onready var goose: CharacterBody2D = $"../goose"
@onready var goose: CharacterBody2D = get_node_or_null("../goose")
@onready var grapejuice_timericon: TextureRect = $"HUD/GrapeJuiceTimer/TimerIcon"
@onready var camera_2d: Camera2D = $"."
@onready var level: Node2D = $".."
@onready var juice_menu_scene: PackedScene = preload("res://scenes/worlds/juice_menu.tscn")
@onready var main: Node = get_node_or_null("/root/Main")
var juice_menu: PopupPanel 

func toggle_pause(value = null):
	if main:
		main.toggle_pause(value)

func toggle_juice_menu():
	if juice_menu.visible:
		juice_menu.hide()
	else:
		juice_menu.show()
	
	toggle_pause(juice_menu.visible)

func _ready():
	juice_menu = juice_menu_scene.instantiate()
	juice_menu.hide()
	add_child(juice_menu)
	
	texture_rect.modulate.a = 0.0  # Ensure it starts transparent

	Global.camera_2d = self
	Global.bullet_counter = $HUD/BulletCounter/BulletCountLabel

	offset = custom_camera_offset

	if Global.current_level_index in level_camera_settings:
		apply_level_settings(Global.current_level_index)

	if not is_instance_valid(goose):  # Check if goose exists
		print("❌ Goose (player) not found. Waiting for player to be spawned.")
		await get_tree().create_timer(0.1).timeout  # Small delay before checking again
		goose = get_node_or_null("../goose")  # Try finding the player again
	
	if is_instance_valid(goose):
		print("✅ Goose (player) found. Setting initial camera position.")
		_set_camera_start_position()

func _set_camera_start_position() -> void:
	var vpw = VIEWPORT_WIDTH * zoom.x
	var vph = VIEWPORT_HEIGHT * zoom.y
	position = Vector2(
		clamp(goose.position.x + (vpw * 0.5), 0.0, LEVEL_LENGTH - vpw),
		clamp(goose.position.y - (vph * 0.5), 0.0, LEVEL_HEIGHT - vph)
	)

func _process(delta: float) -> void:
	grapejuice_timericon.modulate = goose.modulate
	
	if transition_in_progress:
		return  # ✅ freeze camera logic during fade transitions
	if Input.is_action_just_pressed("juice") and not playing_cutscene:
		toggle_juice_menu()
		
	if Input.is_action_just_pressed("restart") and not playing_cutscene:
		_on_restartbtn_pressed()
	
	if playing_cutscene:
		juice_menu.hide()
		$"HUD/status-indicator".animation = "stop"
		$"HUD/btn-container".hide()
	elif get_tree().paused:
		$"HUD/status-indicator".animation = "pause"
		$"HUD/btn-container".show()
	else:
		$"HUD/status-indicator".animation = "default"
		$"HUD/btn-container".hide()
	

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
	if Global.current_level_index == 0:
		custom_camera_offset = Vector2(750, 250)
		position.x = lerp(position.x, target_x, x_smooth_speed * delta)
		return

	# --- Level 2 (dynamic vertical behavior) ---
	if Global.current_level_index == 1 or Global.current_level_index == 2 or Global.current_level_index == 3 or Global.current_level_index == 4 or Global.current_level_index == 5 or Global.current_level_index == 6 or Global.current_level_index == 7 or Global.current_level_index == 8 or Global.current_level_index == 9 or Global.current_level_index == 10 or Global.current_level_index == 11 or Global.current_level_index == 12 or Global.current_level_index == 13 or Global.current_level_index == 14 or Global.current_level_index == 15:
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
	

func apply_level_settings(level_index: int) -> void:
	var settings = level_camera_settings.get(level_index, null)
	if settings:
		LEVEL_LENGTH = settings.get("LEVEL_LENGTH", LEVEL_LENGTH)
		LEVEL_HEIGHT = settings.get("LEVEL_HEIGHT", LEVEL_HEIGHT)
		custom_camera_offset = settings.get("custom_camera_offset", custom_camera_offset)




func teleport_to_section(destination: Vector2, new_bounds: Vector2, new_offset: Vector2, new_sublevel_index: float) -> void:
	print("New Bounds: ", new_bounds)
	print("New Offset: ", new_offset)
	print("Teleport Destination: ", destination)
	
	goose.disable()
	await fade_in(1.0)  # wait for fade to black
	
	await get_tree().create_timer(2.0).timeout

	# Update bounds and offset as usual
	LEVEL_LENGTH = destination.x + new_bounds.x
	LEVEL_HEIGHT = destination.y + new_bounds.y
	custom_camera_offset = new_offset
	sublevel_index = new_sublevel_index

	# Check if the new sublevel has specific settings
	if Global.current_level_index in level_camera_settings:
		apply_level_settings(Global.current_level_index)  # Make sure to apply them here too

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


func _on_exitbtn_pressed() -> void:
	if get_node_or_null("/root/Main"):
		level.get_tree().paused = false
		get_node_or_null("/root/Main").load_menu()


func _on_restartbtn_pressed() -> void:
	if goose.game_state == 0:
		level.get_tree().paused = false
		Global.restart_game()
