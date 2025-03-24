extends Node2D

const SPEED: float = 3000.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Check if the area belongs to a duck
func _on_area_2d_area_entered(touchedarea: Node):
	print_debug("Bullet hit something:", touchedarea.name, "\nGroups:", touchedarea.get_groups())

	var enemy: Node = touchedarea.get_parent()  # Get the parent node (the full entity)

	if enemy:
		print_verbose("Parent detected:", enemy.name, " | Groups:", enemy.get_groups())

	if enemy and (enemy.is_in_group("enemy") or enemy.is_in_group("meteors")):  
		print_verbose("Enemy detected:", enemy.name)
		enemy.start_falling("bullet")
		queue_free()  # Destroy the bullet
	elif touchedarea and (touchedarea.is_in_group("enemy") or touchedarea.is_in_group("meteors")):
		print_verbose("Enemy detected:", touchedarea.name)
		touchedarea.start_falling("bullet")
		queue_free()  # Destroy the bullet
	elif touchedarea and touchedarea.name == "Terrain":
		print_verbose("Terrain detected, breaking bullet")
		queue_free()
	else:
		print_verbose("Not an enemy. Bullet will not trigger 'start_falling'.")
