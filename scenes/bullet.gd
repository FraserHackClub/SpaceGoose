extends Node2D

#@onready var Duck = $"../duck"

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



	


func _on_area_2d_area_entered(touchedarea):
	print("Bullet hit something:", touchedarea.name)
	print("Groups:", touchedarea.get_groups())  

	var enemy = touchedarea.get_parent()  # Get the parent node (the full duck scene)

	if enemy and enemy.is_in_group("enemies"):  # Check if the parent is actually an enemy
		print("Enemy detected:", enemy.name)
		enemy.start_falling()  # Call the function from the full enemy scene
		queue_free()  # Destroy the bullet
