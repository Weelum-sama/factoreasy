extends BaseFacility
class_name Extractor

func tick() -> void:
	_try_exctract()

func _try_exctract() -> void:
	var cell := GridManager.world_to_cell(global_position)
	
	var behind_cell := cell + Util.get_behind_offset(rotation)
	var occupant := GridManager.get_cell_occupant(behind_cell)
	
	if occupant is OreNode:
		var item : Item = occupant.extract_item()
		output_buffer[item] = output_buffer.get(item, 0) + 1
