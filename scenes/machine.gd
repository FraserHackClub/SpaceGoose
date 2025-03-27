extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	sprite.play("default")
