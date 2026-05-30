extends BaseFacility
class_name Extractor

func tick() -> void:
	_try_exctract()

func _try_exctract() -> void:
	var cell := GridManager.world_to_cell(global_position)
	
	var behind_cell : Vector2i = cell + Util.get_behind_offset(rotation)
	var occupant : Node = GridManager.get_cell_occupant(behind_cell)
	
	if occupant is OreNode:
		if output_buffer.values().any(func(v): return v >= MAX_BUFFER):
			_set_state(Util.FACILITYSTATE.CLOGGED)
			return
		var item : Item = occupant.extract_item()
		output_buffer[item] = output_buffer.get(item, 0) + 1
		_set_state(Util.FACILITYSTATE.PRODUCING)
	else:
		_set_state(Util.FACILITYSTATE.IDLE)
