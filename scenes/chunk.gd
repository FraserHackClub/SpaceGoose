extends Node2D

const CHUNK_SIZE = 32
var active_chunks = {}
var tilemap: TileMap

func _ready():
	tilemap = get_parent()
	convert_to_chunks()

func convert_to_chunks():
	if !tilemap:
		push_error("TileMap not found!")
		return
		
	var dirt_tiles = []
	var cells = tilemap.get_used_cells(0)
	

	for cell in cells:
		if is_dirt_tile(cell):
			dirt_tiles.append(cell)
	

	for cell in dirt_tiles:
		var chunk_pos = Vector2i(
			int(floor(float(cell.x) / CHUNK_SIZE)),
			int(floor(float(cell.y) / CHUNK_SIZE))
		)
		

		var chunk_key = str(chunk_pos)
		
		if !active_chunks.has(chunk_key):
			create_chunk(chunk_pos)

func is_dirt_tile(cell: Vector2i) -> bool:
	if !tilemap:
		return false
		
	var tile_data = tilemap.get_cell_tile_data(0, cell)
	if tile_data == null:
		return false
		


	return tilemap.get_cell_source_id(0, cell) >= 0

func create_chunk(chunk_pos: Vector2i):

	var chunk_key = str(chunk_pos)
	

	if active_chunks.has(chunk_key):
		return
		

	active_chunks[chunk_key] = {
		"position": chunk_pos,
		"active": true
	}
	
	print("Created chunk at: ", chunk_pos)


func _exit_tree():
	active_chunks.clear()
