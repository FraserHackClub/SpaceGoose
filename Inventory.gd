class_name Inventory

const INVENTORYFILEPATH: String = "user://inventory.json"
var inventory_file: FileAccess

var previous_content: String

var items: Dictionary
var score: int
var current_level: int

func _init():
	inventory_file = FileAccess.open(INVENTORYFILEPATH, FileAccess.READ_WRITE)
	if (not FileAccess.file_exists(INVENTORYFILEPATH)) or (not inventory_file.get_as_text()):
		if inventory_file:
			inventory_file.close()
		inventory_file = FileAccess.open(INVENTORYFILEPATH, FileAccess.WRITE)
		inventory_file.close()
		inventory_file = FileAccess.open(INVENTORYFILEPATH, FileAccess.READ_WRITE)
		populate_inventory()
	
	set_inventory(JSON.parse_string(inventory_file.get_as_text()))
	print(get_item_count("egg"))
	
	if get_item_count("egg") <= 0:
		populate_inventory()
	
	commit_inventory()

func populate_inventory():
	set_inventory(Global.default_inventory)
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
	inventory_file.resize(0)
	inventory_file.store_string(JSON.stringify(get_inventory()))
	inventory_file.flush()
