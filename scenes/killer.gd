extends Node2D
@onready var sprite = $Sprite2D
@onready var area = $Area2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == null:
		return
	
	if body is CharacterBody2D and body == Global.main_character:
		body.game_over(2)
