extends Node2D
class_name Belt

var belt_item: BeltItem = null
var is_delivering: bool = false
@export var items_per_minute: float = 30.0

func _ready() -> void:
	var ips := get_items_per_second()
	$AnimatedSprite2D.speed_scale = ips
	$AnimatedSprite2D.play("default")

func register() -> void:
	var cell := GridManager.world_to_cell(global_position)
	BeltManager.register_belt(cell, self)

func get_items_per_second() -> float:
	return items_per_minute / 60.0

func get_output_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) + Util.get_facing_offset(rotation)

func get_input_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) - Util.get_facing_offset(rotation)

func cleanup() -> void:
	BeltManager.unregister_belt(GridManager.world_to_cell(global_position))
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()
