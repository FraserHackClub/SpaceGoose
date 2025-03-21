extends Node

@onready var level_container = $LevelContainer
var current_level = null

func _ready():
	# Debugging - print the node path to verify it exists
	print("Node path: ", get_path())
	print("Children: ", get_children())
	Global.toggle_fps_display()
	# Make sure the level container exists
	if has_node("LevelContainer"):
		print("LevelContainer found")
	else:
		push_error("LevelContainer not found!")
		# Try to create it if missing
		var container = Node.new()
		container.name = "LevelContainer"
		add_child(container)
		level_container = container
	
	# Load initial level
	load_level(0)

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
		return true
	return false
