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
	else:
		context.hold_candidate = null
		context.hold_timer = 0.0

func _pick_up_building(building: Node) -> void:
	var cell := GridManager.world_to_cell(building.global_position)
	GridManager.remove(cell)
	
	if building is OreNode:
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
	building.queue_free()
	transitioned.emit(self, FacilityPlacementState.NAME)

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
