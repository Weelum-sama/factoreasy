extends BaseFacility
class_name Extractor

func tick() -> void:
	_try_exctract()

func _try_exctract() -> void:
	var data := get_data() as ProcessingFacilityData
	if data == null or data.recipes.is_empty():
		return
		
	var cell := GridManager.world_to_cell(global_position)
	var behind_cell : Vector2i = cell + Util.get_behind_offset(rotation)
	var occupant : Node = GridManager.get_cell_occupant(behind_cell)
	
	if not occupant is OreNode:
		_set_state(Util.FACILITYSTATE.IDLE)
		return
	
	var ore_item := (occupant as OreNode).extract_item()
	if ore_item != data.recipes[0].output.item:
		_set_state(Util.FACILITYSTATE.IDLE)
		return
		
	if output_buffer.get(ore_item, 0) >= MAX_BUFFER:
		_set_state(Util.FACILITYSTATE.CLOGGED)
		return
		
	var item : Item = occupant.extract_item()
	output_buffer[item] = output_buffer.get(item, 0) + 1
	_set_state(Util.FACILITYSTATE.PRODUCING)
