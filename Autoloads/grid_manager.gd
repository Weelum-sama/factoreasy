extends Node

const CELL_SIZE: int = 32

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

func is_cell_in_bounds(cell: Vector2i) -> bool:
	return GameState.get_factory_bounds().has_point(cell)

func is_cell_empty(cell: Vector2i) -> bool:
	if not is_cell_in_bounds(cell):
		return false
	return not _grid.has(cell)

### Retrieving cell occupants

func get_cell_occupant(cell: Vector2i) -> Node:
	return _grid.get(cell, null)

func get_all_cell_occupants() -> Array[Node]:
	var array : Array[Node] = []
	var seen: Dictionary = {}
	for occupant in _grid.values():
		if not seen.has(occupant):
			seen[occupant] = true
			array.append(occupant)
	return array

### Placement and removal

func place(cell: Vector2i, building: Node) -> bool:
	if not is_cell_empty(cell):
		return false
	_grid[cell] = building
	building.position = cell_center(cell)
	return true

func remove(cell: Vector2i) -> void:
	_grid.erase(cell)

### Multi-cell support

func compute_footprint(root: Vector2i, width: int, height: int, rotation: float) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var half_width := (width - 1) / 2
	var half_height := (height - 1) / 2
	for dy in range(-half_height, half_height + 1):
		for dx in range(-half_width, half_width + 1):
			cells.append(root + Util.rotate_offset(Vector2i(dx, dy), rotation))
	return cells

func is_area_empty(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not is_cell_empty(cell):
			return false
	return true

func place_footprint(cells: Array[Vector2i], root_cell: Vector2i, building: Node) -> bool:
	# Check if every cell is either empty or already owned by this building
	for cell in cells:
		var occupant: Node = _grid.get(cell, null)
		if occupant != null and occupant != building:
			return false
		if not is_cell_in_bounds(cell):
			return false
	
	for cell in cells:
		_grid[cell] = building
	building.position = cell_center(root_cell)
	return true

func remove_footprint(cells: Array[Vector2i]) -> void:
	for cell in cells:
		_grid.erase(cell)

### Grid

func get_full_grid() -> Dictionary:
	return _grid
