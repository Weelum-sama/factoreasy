extends Node

### Buildings
var unlocked_buildings: Dictionary = {
	"extractor":	true,
	"conveyor":		true,
	"sink":			true,
	"smelter":		false,
	"constructor":	false,
}

signal building_unlocked(building_id: String)

func unlock_building(building_id: String) -> void:
	if unlocked_buildings.has(building_id):
		unlocked_buildings[building_id] = true
		building_unlocked.emit("building_unlocked" ,building_id)

func is_building_unlocked(building_id: String) -> bool:
	return unlocked_buildings.get(building_id)

### Nodes

var unlocked_nodes: Dictionary = {
	"iron_ore_node":		true,
	"copper_ore_node":		false,
}

var node_inventory: Dictionary = {
	"iron_ore_node":		2,
	"copper_ore_node":		0,
}

signal inventory_changed(resource_id: String, new_count: int)

func add_node_to_inventory(resource_id: String, amount: int = 1) -> void:
	node_inventory[resource_id] = node_inventory.get(resource_id, 0) + amount
	inventory_changed.emit(resource_id, node_inventory[resource_id])

func consume_node_from_inventory(resource_id: String, amount: int = 1) -> bool:
	if node_inventory.get(resource_id, 0) <= 0:
		return false
	node_inventory[resource_id] -= amount
	inventory_changed.emit(resource_id, node_inventory[resource_id])
	return true
