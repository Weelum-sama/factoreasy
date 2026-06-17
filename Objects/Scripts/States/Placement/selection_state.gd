extends PlacementState
class_name SelectionState

const NAME = "selection"

var _drag_start: Vector2 = Vector2.ZERO
var _drag_start_cell: Vector2i = Vector2i.ZERO
var _unselect: bool = false

func update(_delta: float) -> void:
	if context.selection_box_active:
		context.ghost_parent.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	_unselect = Input.is_key_pressed(KEY_CTRL)
	
	if event.is_action_pressed("Toggle Select") or event.is_action_released("Cancel"):
		context.clear_selection()
		Util.cancelled_copy_selection.emit()
		transitioned.emit(self, DefaultState.NAME)
		return
	
	if event.is_action_pressed("Confirm"):
		_drag_start = context.ghost_parent.get_global_mouse_position()
		_drag_start_cell = GridManager.world_to_cell(_drag_start)
		
		context.selection_box_start = _drag_start
		context.selection_box_active = true
		return
	
	if event.is_action_released("Confirm"):
		context.selection_box_active = false
		context.ghost_parent.queue_redraw()
		
		var drag_end := context.ghost_parent.get_global_mouse_position()
		var drag_end_cell := GridManager.world_to_cell(drag_end)
		var cell_diff := (_drag_start_cell - drag_end_cell).abs()
		
		if cell_diff.x <= 1 and cell_diff.y <= 1:
			var building := GridManager.get_cell_occupant(_drag_start_cell)
			if building:
				if _unselect or context.selected_buildings.has(building):
					_unselect_building(building)
				else:
					_select_building(building)
			return
		
		_apply_box_select(_drag_start, drag_end)
		return
	
	if event.is_action_pressed("Select All"):
		_select_all_buildings()
		return
	
	if not context.selected_buildings.is_empty():
		if event.is_action_pressed("Move Selection"):
			context.entered_from_selection = true
			var belts: Array[Belt]
			for building in context.selected_buildings:
				if building is Belt:
					belts.append(building)
			if not belts.is_empty():
				BeltManager.moving_belts.emit(belts)
			transitioned.emit(self, GroupMovementState.NAME)
			
		if event.is_action_pressed("Copy Selection"):
			if not _can_copy_selection():
				Util.cannot_copy_selection.emit(context.missing_ore_nodes)
				context.missing_ore_nodes.clear()
				return
			context.entered_from_selection = true
			context.is_copy_mode = true
			Util.copied_selection.emit()
			transitioned.emit(self, GroupMovementState.NAME)
		
		if event.is_action_pressed("Stash"):
			for building in context.selected_buildings:
				building.cleanup()
				BeltManager.cancel_deliveries_to(building)
			context.selected_buildings.clear()
			transitioned.emit(self, DefaultState.NAME)

func _apply_box_select(start: Vector2, end: Vector2) -> void:
	var rect := Rect2(start, Vector2.ZERO).expand(end)
	for building in GridManager.get_all_cell_occupants():
		var node := building as Node2D
		if not rect.has_point(node.global_position):
			continue
		if _unselect:
			_unselect_building(building)
		elif not context.selected_buildings.has(building):
			_select_building(building)

func _unselect_building(building: Node) -> void:
	context.selected_buildings.erase(building)
	building.modulate = Color.WHITE

func _select_building(building: Node) -> void:
	context.selected_buildings.append(building)
	building.modulate = Color.SKY_BLUE

func _select_all_buildings() -> void:
	context.clear_selection()
	context.selected_buildings = GridManager.get_all_cell_occupants()
	for building in context.selected_buildings:
		building.modulate = Color.SKY_BLUE

func _can_copy_selection() -> bool:
	var ores := {}
	for building in context.selected_buildings:
		if building is OreNode:
			var ore_node := building as OreNode
			ores[ore_node.data.id] = ores.get(ore_node.data.id, 0) + 1
	for ore_node in ores:
		if ores[ore_node] > GameState.node_inventory[ore_node]:
			context.missing_ore_nodes[ore_node] = ores.get(ore_node, 0)
	if not context.missing_ore_nodes.is_empty():
		return false
	context.missing_ore_nodes.clear()
	return true

func exit() -> void:
	context.missing_ore_nodes.clear()
