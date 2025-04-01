extends CharacterBody2D

@export var SPEED: float = 1200.0
@export var max_lifetime: float = 3.0

var time_since_spawn: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	time_since_spawn += delta
	
	if time_since_spawn >= max_lifetime:
		queue_free()

# Check if the area belongs to a duck
func _on_area_2d_area_entered(touchedarea: Node):
	print_debug("Fireball hit something:", touchedarea.name, "\nGroups:", touchedarea.get_groups())

	var enemy: Node = touchedarea.get_parent()  # Get the parent node (the full entity)
	
	if not (touchedarea.has_method("start_falling") or enemy.has_method("start_method")):
		return
	
	if enemy:
		print_verbose("Parent detected:", enemy.name, " | Groups:", enemy.get_groups())

	if enemy and (enemy.is_in_group("enemy") or enemy.is_in_group("meteors") or enemy.is_in_group("basket") or enemy.is_in_group("item")):  
		print_verbose("Enemy detected:", enemy.name)
		enemy.start_falling("fireball")
	elif touchedarea and (touchedarea.is_in_group("enemy") or touchedarea.is_in_group("meteors") or touchedarea.is_in_group("basket") or touchedarea.is_in_group("item")):
		print_verbose("Enemy detected:", touchedarea.name)
		touchedarea.start_falling("fireball")
	elif touchedarea and touchedarea.name == "Terrain":
		print_verbose("Terrain detected, removing fireball")
	else:
		print_verbose("Not an enemy. Fireball  will not trigger 'start_falling'.")
