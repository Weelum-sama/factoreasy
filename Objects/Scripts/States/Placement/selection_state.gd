extends PlacementState
class_name SelectionState

const NAME = "selection"

var _drag_start: Vector2 = Vector2.ZERO
var _drag_start_cell: Vector2i = Vector2i.ZERO
var _is_single_click: bool = false
var _unselect: bool = false

func enter() -> void:
	Util.set_current_placement_mode(Util.PLACEMENTMODE.SELECTION)

func update(_delta: float) -> void:
	if context.selection_box_active:
		context.ghost_parent.queue_redraw()
		var current_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
		if current_cell != _drag_start_cell:
			_is_single_click = false

func _input(event: InputEvent) -> void:
	_unselect = Input.is_action_pressed("Unselect")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Toggle Select") or Input.is_action_just_pressed("Cancel"):
		context.clear_selection()
		transitioned.emit(self, DefaultState.NAME)
		return
	
	if Input.is_action_just_pressed("Confirm"):
		_drag_start = context.ghost_parent.get_global_mouse_position()
		_drag_start_cell = GridManager.world_to_cell(_drag_start)
		_is_single_click = true
		
		context.selection_box_start = _drag_start
		context.selection_box_active = true
		return
	
	if Input.is_action_just_released("Confirm"):
		context.selection_box_active = false
		context.ghost_parent.queue_redraw()
		var drag_end := context.ghost_parent.get_global_mouse_position()
		
		if _is_single_click:
			var building := context.get_building_from_mouse()
			if not building:
				return
			if _unselect or context.selected_buildings.has(building):
				_unselect_building(building)
			else:
				_select_building(building)
		_apply_box_select(_drag_start, drag_end)
		return
	
	if Input.is_action_just_pressed("Select All"):
		_select_all_buildings()
		return
	
	if not context.selected_buildings.is_empty():
		if Input.is_action_just_pressed("Move Selection"):
			transitioned.emit(self, GroupMovementState.NAME)
		if Input.is_action_just_pressed("Stash"):
			for building in context.selected_buildings:
				building.cleanup()
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
		else:
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
