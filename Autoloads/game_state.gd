extends Node

### Buildings

var unlocked_buildings: Dictionary = {
	"extractor":	true,
	"conveyor":		true,
	"sink":			true,
	"smelter":		false,
	"constructor":	false,
}

var facility_registry: Dictionary = {}

func _ready() -> void:
	_load_facility_registry()
	load_game()

func _load_facility_registry() -> void:
	var paths := [
		"res://Scripts/Resources/Facility Data/extractor_data.tres",
		"res://Scripts/Resources/Facility Data/sink_data.tres",
		"res://Scripts/Resources/Facility Data/smelter_data.tres",
	]
	for path in paths:
		if ResourceLoader.exists(path):
			var data: FacilityData = load(path)
			facility_registry[data.id] = data

func register_facility(data: FacilityData) -> void:
	facility_registry[data.id] = data

signal building_unlocked(building_id: String)

func unlock_building(building_id: String) -> void:
	if unlocked_buildings.has(building_id):
		unlocked_buildings[building_id] = true
		building_unlocked.emit(building_id)

func is_building_unlocked(building_id: String) -> bool:
	return unlocked_buildings.get(building_id)

### Nodes

var unlocked_nodes: Dictionary = {
	"iron_ore_node":		true,
	"copper_ore_node":		true,
}

var node_inventory: Dictionary = {
	"iron_ore_node":		0,
	"copper_ore_node":		0,
}

var total_nodes_owned: Dictionary = {
	"iron_ore_node":		0,
	"copper_ore_node":		0,
}

signal node_unlocked(node_id: String)
signal node_purchased(node_id: String, amount: int)
signal inventory_changed(resource_id: String, new_count: int)

func unlock_node(node_id: String) -> void:
	if unlocked_nodes.has(node_id):
		unlocked_nodes[node_id] = true
		node_unlocked.emit(node_id)

func purchase_node(resource_id: String, amount: int = 1) -> void:
	node_inventory[resource_id] = node_inventory.get(resource_id, 0) + amount
	total_nodes_owned[resource_id] = total_nodes_owned.get(resource_id, 0) + amount
	inventory_changed.emit(resource_id, node_inventory[resource_id])
	node_purchased.emit(resource_id, amount)

func add_node_to_inventory(resource_id: String, amount: int = 1) -> void:
	node_inventory[resource_id] = node_inventory.get(resource_id, 0) + amount
	inventory_changed.emit(resource_id, node_inventory[resource_id])

func consume_node_from_inventory(resource_id: String, amount: int = 1) -> bool:
	if node_inventory.get(resource_id, 0) <= 0:
		return false
	node_inventory[resource_id] -= amount
	inventory_changed.emit(resource_id, node_inventory[resource_id])
	return true

func has_node_in_inventory(node_id: String) -> bool:
	return node_inventory.get(node_id, 0) > 0

func get_total_owned_of_ore(node_id: String) -> int:
	return total_nodes_owned[node_id]

## Factory size

const FACTORY_BASE_SIZE: int = 16
const FACTORY_SIZE_PER_LEVEL: int = 4

signal factory_size_changed

func get_factory_size() -> int:
	return FACTORY_BASE_SIZE + (upgrade_levels["factory"] - 1) * FACTORY_SIZE_PER_LEVEL

func get_factory_bounds() -> Rect2i:
	var size := get_factory_size()
	var half := size / 2
	return Rect2i(-half, -half, size, size)

## Coins

var _total_coins: float = 50

signal coins_changed(new_amount: int)

func add_coins(amount: float) -> void:
	_total_coins += amount
	coins_changed.emit(_total_coins)

func get_total_coins() -> int:
	return roundi(_total_coins)

## Upgrades

var upgrade_levels: Dictionary = {
	"factory" : 1,
	"belts" : 1,
}

func upgrade_level(upgrade: String, amount: int = 1) -> void:
	upgrade_levels[upgrade] += amount
	if upgrade == "factory":
		factory_size_changed.emit()

func get_upgrade_level(upgrade: String) -> int:
	return upgrade_levels[upgrade]

## Saving / Loading

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	var data := {
		"unlocked_buildings": unlocked_buildings,
		"node_inventory": node_inventory,
		"total_nodes_owned": total_nodes_owned,
		"unlocked_nodes": unlocked_nodes,
		"total_coins": _total_coins,
		"upgrade_levels": upgrade_levels,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	var err := json.parse(file.read_as_string())
	file.close()
	if err != OK:
		push_error("Failed to parse save file")
		return
	var data: Dictionary = json.get_data()
	unlocked_buildings = data.get("unlocked_buildings", unlocked_buildings)
	node_inventory = data.get("node_inventory", node_inventory)
	total_nodes_owned = data.get("total_nodes_owned", total_nodes_owned)
	unlocked_nodes = data.get("unlocked_nodes", unlocked_nodes)
	_total_coins = data.get("total_coins", _total_coins)
	upgrade_levels = data.get("upgrade_levels", upgrade_levels)

## Pause

signal game_paused(paused: bool)
