extends Node



# Restart game and load main scene
#func restart_game():
	#get_tree().change_scene_to_file("res://main.tscn")  # ✅ Replace with your main scene path
		# Hide the death screen before restarting (if needed)
		
func restart_game():
	get_tree().reload_current_scene()
	# If the death screen is persistent, reset its state
	if has_node("GameOverScreen"):
		get_node("GameOverScreen").reset()
