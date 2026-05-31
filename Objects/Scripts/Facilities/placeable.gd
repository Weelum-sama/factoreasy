extends Node2D
class_name Placeable

func move_to(new_cell: Vector2i) -> void:
	var old_cell := GridManager.world_to_cell(global_position)
	GridManager.remove(old_cell)
	GridManager.place(new_cell, self)

func cleanup() -> void:
	var cell := GridManager.world_to_cell(global_position)
	GridManager.remove(cell)
	queue_free()

func get_facing_offset() -> Vector2i:
	return Util.get_facing_offset(rotation)
