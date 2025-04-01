extends Node

@onready var level_container = $LevelContainer
@onready var menu_scene: PackedScene = preload("res://scenes/worlds/menu.tscn")
@onready var level_selector_scene: PackedScene = preload("res://scenes/worlds/level_selector.tscn")
var inventory = preload("res://Inventory.gd").new()


var current_level = null
var menu: Control
var level_selector: Control
var paused: bool = false

func _ready():
	# Debugging - print the node path to verify it exists
	print_debug("Node path: ", get_path(), "\nChildren: ", get_children())
	
	# Make sure the level container exists
	if has_node("LevelContainer"):
		print_debug("LevelContainer found")
	else:
		push_error("LevelContainer not found!")
		# Try to create it if missing
		var container = Node.new()
		container.name = "LevelContainer"
		add_child(container)
		level_container = container
	
	load_menu()

func load_menu() -> void:
	if is_level(): remove_levels()
	inventory.fetch_inventory()
	menu = menu_scene.instantiate()
	if menu:
		menu.play = play
		menu.select_level = select_level
		add_child(menu)

func is_level():
	return level_container.get_child_count() > 0

func remove_levels():
	for child in level_container.get_children():
		child.queue_free()
	await get_tree().process_frame


func play() -> void:
	inventory.fetch_inventory()
	load_level(inventory.current_level)

func select_level() -> void:
	if is_level():
		remove_levels()
	
	level_selector = level_selector_scene.instantiate()
	add_child(level_selector)

func load_level(level_index):
	inventory.fetch_inventory()
	# Clear existing level
	if is_level():
		remove_levels()
		await get_tree().process_frame
	# Load new level
	var level_scene = load(Global.level_paths[level_index])
	if level_scene:
		current_level = level_scene.instantiate()
		await get_tree().process_frame
		level_container.call_deferred("add_child", current_level)
		Global.current_level_index = level_index
		inventory.current_level = level_index
		print(inventory.current_level)
		inventory.commit_inventory()
		print(inventory.get_inventory())
		return true
	return false

func _process(_delta: float):
	if Input.is_action_just_pressed("pause") and is_level():
		toggle_pause()

func toggle_pause(value = null):
	var camera = level_container.get_children()[0].get_node_or_null("Camera2D")
	if camera:
		if camera.playing_cutscene:
			return
	
	paused = value if value != null else !paused
	
	for child in level_container.get_children():
		child.get_tree().paused = paused
