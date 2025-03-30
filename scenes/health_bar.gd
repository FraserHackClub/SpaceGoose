extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var health_label: Label

func _ready() -> void:
	# Configure progress bar
	progress_bar.min_value = 0
	progress_bar.max_value = 500  # Set max value to 500
	progress_bar.value = 500  # Start at full health (500)
	
	# Set progress bar colors
	progress_bar.modulate = Color(1, 0.2, 0.2)  # Red for boss health
	
	# Load the Pixeloid font
	var pixeloid_font: FontFile = load("res://assets/PixeloidMono.ttf")  # Make sure the path is correct
	
	# Create a label to display the health number
	health_label = Label.new()
	health_label.text = "500"
	health_label.add_theme_font_override("font", pixeloid_font)  # Corrected usage
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	health_label.add_theme_color_override("font_color", Color(1, 1, 1))  # White text
	health_label.add_theme_font_size_override("font_size", 16)  # Adjust font size as needed
	
	# Add the label as a child of the progress bar so it appears on top
	progress_bar.add_child(health_label)
	
	# Position the label in the center of the progress bar
	health_label.size = progress_bar.size
	health_label.position = Vector2(0, 0)
	
	# Find the boss and connect to its health_changed signal
	var boss = get_parent()
	if boss and boss.has_signal("health_changed"):
		boss.connect("health_changed", Callable(self, "_on_boss_health_changed"))

func _on_boss_health_changed(new_health: int, max_health: int) -> void:
	# Update the progress bar max value if it changed (golden mode)
	if progress_bar.max_value != max_health:
		progress_bar.max_value = max_health
		
		# Change color to gold if max health is greater than 500
		if max_health > 500:
			progress_bar.modulate = Color(1.0, 0.84, 0.0)  # Brighter gold color
	
	# Update the progress bar value
	progress_bar.value = new_health
	
	# Update the label text to show the actual health number
	health_label.text = str(new_health)
