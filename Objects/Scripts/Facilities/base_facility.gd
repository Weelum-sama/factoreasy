extends Placeable
class_name BaseFacility

@export var facility_id: String = ""

var _data_cache: FacilityData = null

var input_buffer: Dictionary = {}
var output_buffer: Dictionary = {}

const MAX_BUFFER: int = 99

var facility_state: Util.FACILITYSTATE = Util.FACILITYSTATE.IDLE

var _current_recipe: Recipe = null

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

### Multi cell helpers

func is_multi_cell() -> bool:
	var data := get_data()
	if data == null:
		return false
	return data.building_width > 1 or data.building_height > 1

func get_footprint() -> Array[Vector2i]:
	var data := get_data()
	var w := data.building_width if data else 1
	var h := data.building_height if data else 1
	return GridManager.compute_footprint(GridManager.world_to_cell(global_position), w, h, rotation)

func cleanup() -> void:
	if is_multi_cell():
		GridManager.remove_footprint(get_footprint())
		queue_free()
	else :
		super.cleanup()

### Body

func _ready() -> void:
	add_to_group("facilities")
	TickManager.tick_occurred.connect(tick)

func tick() -> void:
	pass

func receive_item(item: Item, amount: int = 1) -> bool:
	if not can_receive_item(item):
		return false
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

func can_receive_item(item: Item = null) -> bool:
	if get_data().building_id == "sink":
		return true
	if item != null and get_data() is ProcessingFacilityData:
		if not is_input_valid(item):
			return false
	
	if _current_recipe != null:
		var belongs := false
		for ingredient in _current_recipe.input:
			if ingredient.item == item:
				belongs = true
				break
		if not belongs:
			return false
	
	var amount: int = input_buffer.get(item, 0)
	return amount < MAX_BUFFER

func can_produce() -> bool:
	var total := 0
	for count in output_buffer.values():
		total += count
	return total < MAX_BUFFER

func is_input_valid(item: Item) -> bool:
	var data := get_data() as ProcessingFacilityData
	if data == null:
		return false
	for recipe in data.recipes:
		for ingredient in recipe.input:
			if ingredient.item == item:
				return true
	return false

func set_current_recipe() -> void:
	var data := get_data() as ProcessingFacilityData
	if data == null:
		_current_recipe = null
		return
	
	# Find best recipe for buffer inputs
	var best_recipe: Recipe = null
	var best_score: int = 0
	for recipe in data.recipes:
		var score := 0
		for ingredient in recipe.input:
			if input_buffer.get(ingredient.item, 0) > 0:
				score += 1
			if score > best_score:
				best_score = score
				best_recipe = recipe
	_current_recipe = best_recipe

func get_current_recipe() -> Recipe:
	return _current_recipe
