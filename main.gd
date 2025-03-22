extends Node

@onready var level_container = $LevelContainer
@onready var menu_scene: PackedScene = preload("res://scenes/worlds/menu.tscn")
var inventory = preload("res://Inventory.gd").new()


var current_level = null
var menu

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
	
	menu = menu_scene.instantiate()
	if menu:
		menu.play = play
		menu.gamble = gamble
		add_child(menu)
	


func play() -> void:
	load_level(inventory.current_level)

func gamble() -> void:
	pass

func load_level(level_index):
	# Clear existing level
	if level_container.get_child_count() > 0:
		for child in level_container.get_children():
			child.queue_free()
	
	# Load new level
	var level_scene = load(Global.level_paths[level_index])
	if level_scene:
		current_level = level_scene.instantiate()
		level_container.call_deferred("add_child", current_level)
		Global.current_level_index = level_index
		inventory.current_level = level_index
		print(inventory.current_level)
		inventory.commit_inventory()
		print(inventory.get_inventory())
		return true
	return false
