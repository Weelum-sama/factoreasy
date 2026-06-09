extends PlacementState
class_name DefaultState

const NAME = "default"

func update(_delta: float) -> void:
	if context.hold_candidate != null:
		context.hold_timer += _delta
		if context.hold_timer >= PlacementContext.HOLD_DURATION:
			_pick_up_building(context.hold_candidate)
			context.hold_candidate = null
			context.hold_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:	
	if event.is_action_pressed("Toggle Select"):
		transitioned.emit(self, SelectionState.NAME)
		return
		
	if event.is_action_pressed("Toggle Belt"):
		transitioned.emit(self, BeltPlacementState.NAME)
		return
	
	if event.is_action_pressed("Quick Select"):
		var occupant := context.get_building_from_mouse()
		if occupant:
			_quick_select(occupant)
	
	if event.is_action_pressed("Confirm"):
		var occupant := context.get_building_from_mouse()
		if occupant:
			context.hold_candidate = occupant
	elif event.is_action_released("Confirm"):
		var occupant: Node = context.hold_candidate
		context.hold_candidate = null
		context.hold_timer = 0.0
		_try_open_context_menu(occupant)

## Context Menus

func _try_open_context_menu(occupant: Node) -> void:
	var layer := _get_context_menu_layer()
	if layer == null:
		return
	if occupant:
		layer.open_for(occupant, context.ghost_parent.get_viewport().get_mouse_position())
	else:
		layer.close_all()

func _close_context_menus() -> void:
	var layer := _get_context_menu_layer()
	if layer:
		layer.close_all()

func _get_context_menu_layer() -> ContextMenuLayer:
	return context.ghost_parent.get_tree().root.find_child("ContextMenuLayer", true, false) as ContextMenuLayer

## Pick up and quick select

func _pick_up_building(building: Node) -> void:
	context.entered_from_selection = false
	context.selected_buildings = [building]
	transitioned.emit(self, GroupMovementState.NAME)

func _quick_select(building: Node) -> void:
	if building is OreNode:
		if not GameState.has_node_in_inventory(building.data.id):
			return
		context.pending_data = building.data
		context.ore_node_scene = context.ORE_NODE_SCENE
	elif building is Belt:
		return
	else:
		var facility := building as BaseFacility
		context.pending_data = GameState.facility_registry.get(facility.facility_id)
		context.facility_scene = context.pending_data.scene
	
	context.create_ghost(context.pending_data)
	context.pending_rotation = building.rotation
	transitioned.emit(self, FacilityPlacementState.NAME)
