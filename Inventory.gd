class_name Inventory

const INVENTORYFILEPATH: String = "user://inventory.json"
var inventory_file: FileAccess

var items: Dictionary
var score: int
var current_level: int

func _init():
	if not FileAccess.file_exists(INVENTORYFILEPATH):
		inventory_file = FileAccess.open(INVENTORYFILEPATH, FileAccess.WRITE)
		inventory_file.store_line(JSON.stringify(Global.default_inventory))
		inventory_file.close()
	
	inventory_file = FileAccess.open(INVENTORYFILEPATH, FileAccess.READ_WRITE)
	set_inventory(JSON.parse_string(inventory_file.get_as_text()))
	
	commit_inventory()

func get_inventory() -> Dictionary:
	return {
		"items": items,
		"score": score,
		"current_level": current_level
	}

func set_inventory(inventory: Dictionary) -> void:
	items = inventory["items"]
	score = inventory["score"]
	current_level = inventory["current_level"]

func add_item(item_id: String, count: int = 1) -> void:
	items[item_id] += count

func remove_item(item_id: String, count: int = 1) -> void:
	if items.has(item_id):
		items[item_id] = max(0, items[item_id] - count)
	else:
		printerr("Item not found in inventory:", item_id)

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func get_all_items() -> Dictionary:
	return items

func commit_inventory() -> void:
	inventory_file.seek(0)
	inventory_file.store_line(JSON.stringify(get_inventory()))
	inventory_file.flush()
