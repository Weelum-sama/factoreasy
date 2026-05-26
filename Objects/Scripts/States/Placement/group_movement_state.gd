extends PlacementState
class_name GroupMovementState

const NAME = "groupmovement"

func enter() -> void:
	var center_point := Vector2i.ZERO
	var building_count = context.selected_buildings.size()
	for building in context.selected_buildings:
		center_point += GridManager.world_to_cell(building.global_position)
	center_point /= context.selected_buildings.size()
	
	context.group_move_offsets.clear()
	context.group_move_origins.clear()
	context.group_origin_rotations.clear()
	
	for building in context.selected_buildings:
		var cell := GridManager.world_to_cell(building.global_position)
		context.group_move_offsets.append(cell - center_point)
		context.group_move_origins.append(cell)
		context.group_origin_rotations.append(building.rotation)
		GridManager.remove(cell)

func exit() -> void:
	context.group_move_offsets.clear()
	context.group_move_origins.clear()
	context.group_origin_rotations.clear()

func update(_delta: float) -> void:
	var cursor_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	for i in context.selected_buildings.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		var building := context.selected_buildings[i]
		building.position = GridManager.cell_center(target_cell)
		building.modulate = Color(1, 0.3, 0.3, 0.5) if not GridManager.is_cell_empty(target_cell) else Color(1, 1, 1, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Building"):
		_rotate_group()
	if event.is_action_released("Confirm"):
		_try_place_group()
	if event.is_action_pressed("Cancel"):
		_cancel_group_move()

func _try_place_group() -> void:
	var cursor_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	for i in context.selected_buildings.size():
		if not GridManager.is_cell_empty(cursor_cell + context.group_move_offsets[i]):
			return
	for i in context.selected_buildings.size():
		GridManager.place(cursor_cell + context.group_move_offsets[i], context.selected_buildings[i])
		context.selected_buildings[i].modulate = Color.WHITE
	context.clear_selection()
	transitioned.emit(self, SelectionState.NAME)

func _cancel_group_move() -> void:
	for i in context.selected_buildings.size():
		GridManager.place(context.group_move_origins[i], context.selected_buildings[i])
		context.selected_buildings[i].rotation = context.group_origin_rotations[i]
		context.selected_buildings[i].modulate = Color.SKY_BLUE
	transitioned.emit(self, SelectionState.NAME)

func _rotate_group() -> void:
	for i in context.group_move_offsets.size():
		context.group_move_offsets[i] = context.rotate_offset_90(context.group_move_offsets[i])
	for building in context.selected_buildings:
		building.rotation += PI / 2.0
