extends Node

const CELL_SIZE: int = 64

var _grid: Dictionary = {}

### Coordinates

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / CELL_SIZE),
		floori(world_pos.y / CELL_SIZE)
	)

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func cell_center(cell: Vector2i) -> Vector2:
	return cell_to_world(cell) + Vector2(CELL_SIZE, CELL_SIZE) * 0.5

### Snapping

func snap_to_grid(world_pos: Vector2) -> Vector2:
	return cell_to_world(world_to_cell(world_pos))

### Placement verification

func is_cell_empty(cell: Vector2i) -> bool:
	return not _grid.has(cell)

func get_cell_occupant(cell: Vector2i) -> Node:
	return _grid.get(cell, null)

### Placement and removal

func place(cell: Vector2i, building: Node) -> bool:
	if not is_cell_empty(cell):
		return false
	_grid[cell] = building
	building.position = cell_center(cell)
	return true

func remove(cell: Vector2i) -> void:
	_grid.erase(cell)
