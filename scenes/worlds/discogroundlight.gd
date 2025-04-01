extends PointLight2D

var colors = [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.MAGENTA,
	Color.CYAN
]

var current_color_index = 0
var change_interval = 0.5 # seconds
var time_passed = 0.0

func _process(delta):
	time_passed += delta
	if time_passed >= change_interval:
		time_passed = 0.0
		current_color_index = (current_color_index + 1) % colors.size()
		color = colors[current_color_index]
