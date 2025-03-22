extends Node

@onready var global = get_node("/root/Global")  # Correct reference to Global


func _ready():
	print("DEBUG SCRIPT LOADED!")  # <-- If this doesn't print, the script isn't in the scene tree.
	
	if Global:
		print("Global is detected.")
	else:
		print("Global is missing!")
	print("Global reference:", Global)


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_action_pressed("skip"):  # "skip" must be in Input Map
			print("Skip key pressed!")
			
			var next_index = Global.current_level_index + 1
			if next_index >= Global.level_paths.size():
				next_index = 0  # Loop back to the first level

			print("Skipping to level:", next_index)
			var success = Global.change_level(next_index)

			if success:
				print("Level changed successfully to:", next_index)
			else:
				print("Failed to switch levels.")
