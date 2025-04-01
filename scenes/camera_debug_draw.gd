#extends Node2D

#func _draw() -> void:
	#var cam := get_parent() as Camera2D
	#if cam == null:
		#return

	#var viewport_w = cam.VIEWPORT_WIDTH * cam.zoom.x
	#var viewport_h = cam.VIEWPORT_HEIGHT * cam.zoom.y

	#var bounds_rect = Rect2(Vector2(cam.LEVEL_START_X, cam.LEVEL_START_Y), Vector2(cam.LEVEL_LENGTH, cam.LEVEL_HEIGHT))
	#var camera_rect = Rect2(cam.position, Vector2(viewport_w, viewport_h))

	#draw_rect(bounds_rect, Color(1, 0, 0, 0.4), false)  # Red: level bounds
	#draw_rect(camera_rect, Color(0, 1, 0, 0.3), false)  # Green: camera rect
