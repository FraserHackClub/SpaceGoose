extends Node

@export var bread_scene: PackedScene = preload("res://scenes/bread.tscn")  
@export var cell_size: Vector2 = Vector2(16, 16) 
@onready var tilemap: TileMap = $Terrain  

const MAX_BREAD = 5

func _ready() -> void:
	randomize()
	if tilemap == null:
		push_error("TileMap node not found! Check your node hierarchy and naming.")
		return
	if bread_scene == null:
		push_error("Bread scene not assigned! Please assign a PackedScene in the Inspector or via preload.")
		return
	spawn_bread()

func spawn_bread() -> void:
	for i in range(MAX_BREAD):
		var spawn_position: Vector2 = get_random_spawn_position()
		if spawn_position != Vector2.ZERO:
			var bread_instance = bread_scene.instantiate()
			bread_instance.position = spawn_position
			add_child(bread_instance)

func get_random_spawn_position() -> Vector2:
	var used_rect: Rect2 = tilemap.get_used_rect()
	var cell_x: int = randi() % int(used_rect.size.x) + int(used_rect.position.x)
	var cell_y: int = randi() % int(used_rect.size.y) + int(used_rect.position.y)
	var cell: Vector2 = Vector2(cell_x, cell_y)
	return map_to_world(cell) + cell_size * 0.5

func map_to_world(cell: Vector2) -> Vector2:

	return cell * cell_size
