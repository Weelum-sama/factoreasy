extends Node2D
class_name BaseFacility

@export var facility_id: String = ""

var _data_cache: FacilityData = null

var input_buffer: Dictionary = {}
var output_buffer: Dictionary = {}

func get_data() -> FacilityData:
	if _data_cache == null:
		_data_cache = GameState.facility_registry.get(facility_id)
	return _data_cache

func _ready() -> void:
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
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()
