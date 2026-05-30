extends Node2D
class_name BaseFacility

@export var facility_id: String = ""

var _data_cache: FacilityData = null

var input_buffer: Dictionary = {}
var output_buffer: Dictionary = {}

const MAX_BUFFER: int = 99

var facility_state: Util.FACILITYSTATE = Util.FACILITYSTATE.IDLE

signal state_changed(new_state: Util.FACILITYSTATE)

func _set_state(new_state: Util.FACILITYSTATE) -> void:
	if facility_state == new_state:
		return
	facility_state = new_state
	state_changed.emit(new_state)

func get_data() -> FacilityData:
	if _data_cache == null:
		_data_cache = GameState.facility_registry.get(facility_id)
	return _data_cache

func _ready() -> void:
	z_index = 2
	TickManager.tick_occurred.connect(tick)

func tick() -> void:
	pass

func receive_item(item: Item, amount: int = 1) -> bool:
	input_buffer[item] = input_buffer.get(item, 0) + amount
	return true

func take_item(item: Item) -> bool:
	if output_buffer.get(item, 0) <= 0:
		return false
	output_buffer[item] -= 1
	return true

func has_output() -> bool:
	for item in output_buffer:
		if output_buffer[item] > 0:
			return true
	return false

func peek_output() -> Item:
	for item in output_buffer:
		if output_buffer[item] > 0:
			return item
	return null

func cleanup() -> void:
	BeltManager.cancel_deliveries_to(self)
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()

func get_valid_input_cells() -> Array[Vector2i]:
	var cell := GridManager.world_to_cell(global_position)
	var data := get_data()
	if data.input_directions.is_empty():
		return [cell + Vector2i(1, 0), cell + Vector2i(-1, 0),
				cell + Vector2i(0, 1), cell + Vector2i(0, -1)]
	var results: Array[Vector2i] = []
	for d in data.input_directions:
		results.append(cell + Util.rotate_offset(d, rotation))
	return results

func get_valid_output_cells() -> Array[Vector2i]:
	var cell := GridManager.world_to_cell(global_position)
	var data := get_data()
	if not data:
		var empty: Array[Vector2i] = [Vector2i.ZERO]
		return empty
	if data.output_directions.is_empty():
		return [cell + Vector2i(1, 0), cell + Vector2i(-1, 0),
				cell + Vector2i(0, 1), cell + Vector2i(0, -1)]
	var results: Array[Vector2i] = []
	for d in data.output_directions:
		results.append(cell + Util.rotate_offset(d, rotation))
	return results

func move_to(new_cell: Vector2i) -> void:
	var old_cell := GridManager.world_to_cell(global_position)
	GridManager.remove(old_cell)
	GridManager.place(new_cell, self)

func can_receive_item() -> bool:
	var total := 0
	for count in input_buffer.values():
		total += count
	return total < MAX_BUFFER

func can_produce() -> bool:
	var total := 0
	for count in output_buffer.values():
		total += count
	return total < MAX_BUFFER
