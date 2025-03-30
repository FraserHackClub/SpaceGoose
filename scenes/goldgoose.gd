extends CharacterBody2D

@onready var goose: CharacterBody2D = $"../goose"
@onready var nest: AnimatedSprite2D = $"../Nest/AnimatedSprite2D"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D



func _on_collision_shape_2d_body_entered(body: Node) -> void:
	# Check if the colliding body is the goose and if it has a gold egg
	if body == goose and goose.inventory.has_gold_egg:
		# Change the nest animation to "egg"
		nest.animation = "egg"
		# Change the gold goose's animation to "after"
		animated_sprite.animation = "after"
