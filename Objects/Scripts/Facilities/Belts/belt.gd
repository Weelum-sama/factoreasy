extends Node2D
class_name Belt

var belt_item: BeltItem = null
@export var items_per_minute: float = 30.0

var belt_state: Util.BELTSTATE = Util.BELTSTATE.WORKING

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

func set_belt_state(new_state: Util.BELTSTATE) -> void:
	if belt_state == new_state:
		return
	belt_state = new_state
	match new_state:
		Util.BELTSTATE.WORKING:
			$AnimatedSprite2D.play("default")
		Util.BELTSTATE.CLOGGED:
			$AnimatedSprite2D.pause()

func move_to(new_cell: Vector2i) -> void:
	var old_cell := GridManager.world_to_cell(global_position)
	var delta := new_cell - old_cell
	
	if belt_item != null:
		belt_item.previous_cell += delta
		belt_item.current_cell += delta
	
	BeltManager.update_delivery_cells(old_cell, delta)
	
	BeltManager.unregister_belt(old_cell)
	GridManager.remove(old_cell)
	GridManager.place(new_cell, self)
	BeltManager.register_belt(new_cell, self)

func cleanup() -> void:
	BeltManager.unregister_belt(GridManager.world_to_cell(global_position))
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()
