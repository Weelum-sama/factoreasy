extends BaseFacility
class_name Extractor

func tick() -> void:
	_try_exctract()

func _try_exctract() -> void:
	var cell := GridManager.world_to_cell(global_position)
	
	var behind_cell := cell + _get_behind_offset()
	var occupant := GridManager.get_cell_occupant(behind_cell)
	
	if occupant is OreNode:
		var item : Item = occupant.extract_item()
		output_buffer[item] = output_buffer.get(item, 0) + 1

func _get_facing_offset() -> Vector2i:
	var angle := fmod(rotation - PI / 2 + TAU, TAU)
	if angle < PI / 4 or angle >= 7 * PI / 4:
		return Vector2i(1, 0)
	elif angle < 3 * PI / 4:
		return Vector2i(0, 1)
	elif angle < 5 * PI / 4:
		return Vector2i(-1, 0)
	else:
		return Vector2i(0, -1)

func _get_behind_offset() -> Vector2i:
	var facing := _get_facing_offset()
	return Vector2i(-facing.x, -facing.y)
