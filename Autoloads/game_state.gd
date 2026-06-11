extends Node

### Buildings

const BUILDING_ORDER: Array[String] = ["extractor", "sink", "smelter", "constructor"]

var unlocked_buildings: Dictionary = {
	"extractor":	true,
	"sink":			true,
	"smelter":		false,
	"constructor":	false,
}

var facility_registry: Dictionary = {}

func _ready() -> void:
	_load_facility_registry()
	load_game()
	coins_changed.emit(_total_coins) # Makes sure affordability updates on start

func _load_facility_registry() -> void:
	var paths := [
		"res://Scripts/Resources/Facility Data/extractor_data.tres",
		"res://Scripts/Resources/Facility Data/sink_data.tres",
		"res://Scripts/Resources/Facility Data/smelter_data.tres",
		"res://Scripts/Resources/Facility Data/constructor.tres",
		
		"res://Scripts/Resources/Node Data/iron_ore_node_data.tres",
		"res://Scripts/Resources/Node Data/copper_ore_node_data.tres",
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

const NODE_ORDER: Array[String] = ["iron_ore_node", "copper_ore_node"]

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

var _total_coins: float = 10.0

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

signal grid_load_requested(grid_data: GridData)

const SAVE_PATH_STATE := "user://game_state.tres"
const SAVE_PATH_GRID  := "user://grid_data.tres"

func save_game() -> void:
	var state := GameStateData.new()
	state.unlocked_buildings = unlocked_buildings.duplicate()
	state.unlocked_nodes = unlocked_nodes.duplicate()
	state.node_inventory = node_inventory
	state.total_nodes_owned = total_nodes_owned.duplicate()
	state.total_coins = _total_coins
	state.upgrade_levels = upgrade_levels.duplicate()
	state.tutorial_progression = TutorialManager.tutorial_progression.duplicate()
	ResourceSaver.save(state, SAVE_PATH_STATE)
	
	var grid := GridData.new()
	var existing_grid := GridManager.get_full_grid()
	for cell in existing_grid:
		var occupant: Node = existing_grid[cell]
		var entry := { "cell": cell, "rotation": occupant.rotation }
		if occupant is Belt:
			entry["type"] = "belt"
		elif occupant is OreNode:
			entry["type"] = occupant.data.id
		elif occupant is BaseFacility:
			entry["type"] = occupant.facility_id
		else:
			continue
		grid.entries.append(entry)
	ResourceSaver.save(grid, SAVE_PATH_GRID)

func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH_STATE):
		var state: GameStateData = ResourceLoader.load(SAVE_PATH_STATE)
		unlocked_buildings = state.unlocked_buildings.duplicate()
		node_inventory     = state.node_inventory.duplicate()
		total_nodes_owned  = state.total_nodes_owned.duplicate()
		unlocked_nodes     = state.unlocked_nodes.duplicate()
		_total_coins       = state.total_coins
		upgrade_levels     = state.upgrade_levels.duplicate()
		if not state.tutorial_progression.is_empty():
			TutorialManager.tutorial_progression = state.tutorial_progression.duplicate()
	
	if ResourceLoader.exists(SAVE_PATH_GRID):
		var grid: GridData = ResourceLoader.load(SAVE_PATH_GRID)
		call_deferred("emit_signal", "grid_load_requested", grid)

func reset_save_data() -> void:
	if ResourceLoader.exists(SAVE_PATH_STATE):
		DirAccess.remove_absolute(SAVE_PATH_STATE)
	if ResourceLoader.exists(SAVE_PATH_GRID):
		DirAccess.remove_absolute(SAVE_PATH_GRID)

## Pause

signal game_paused(paused: bool)
