extends Node2D
class_name Belt

var belt_item: BeltItem = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func register() -> void:
	var cell := GridManager.world_to_cell(global_position)
	BeltManager.register_belt(cell, self)

func get_output_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) + Util.get_facing_offset(rotation)

func get_input_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) - Util.get_behind_offset(rotation)

func cleanup() -> void:
	BeltManager.unregister_belt(GridManager.world_to_cell(global_position))
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()
