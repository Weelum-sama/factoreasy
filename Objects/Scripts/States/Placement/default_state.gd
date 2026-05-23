extends PlacementState
class_name DefaultState

const NAME = "default"

func enter() -> void:
	Util.set_current_placement_mode(Util.PLACEMENTMODE.NONE)

func update(_delta: float) -> void:
	if context.hold_candidate != null:
		context.hold_timer += _delta
		if context.hold_timer >= PlacementContext.HOLD_DURATION:
			_pick_up_building(context.hold_candidate)
			context.hold_candidate = null
			context.hold_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Toggle Select"):
		transitioned.emit(self, SelectionState.NAME)
		return
	
	if Input.is_action_just_pressed("Quick Select"):
		var occupant := context.get_building_from_mouse()
		if occupant:
			_quick_select(occupant)
	
	if Input.is_action_pressed("Confirm"):
		var occupant := context.get_building_from_mouse()
		if occupant:
			context.hold_candidate = occupant
	else:
		context.hold_candidate = null
		context.hold_timer = 0.0

func _pick_up_building(building: Node) -> void:
	var cell := GridManager.world_to_cell(building.global_position)
	print("building rotation: ", (building as Node2D).rotation)
	GridManager.remove(cell)
	if building is ProducingFacility:
		context.facility_scene = load("res://Objects/Scenes/Facilities/producing_facility.tscn")
		context.pending_data = building.facility_data
	elif building is ConsumingFacility:
		context.consuming_facility_scene = load("res://Objects/Scenes/Consuming Facilities/consuming_facility.tscn")
		context.pending_data = building.facility_data
	elif building is OreNode:
		context.ore_node_scene = load("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
		context.pending_data = building.data
	context.create_ghost(context.pending_data)
	building.queue_free()
	context.pending_rotation = building.rotation
	transitioned.emit(self, FacilityPlacementState.NAME)

func _quick_select(building: Node) -> void:
	if building is ProducingFacility:
		context.facility_scene = load("res://Objects/Scenes/Facilities/producing_facility.tscn")
		context.pending_data = building.facility_data
	elif building is ConsumingFacility:
		context.consuming_facility_scene = load("res://Objects/Scenes/Consuming Facilities/consuming_facility.tscn")
		context.pending_data = building.facility_data
	elif building is OreNode:
		context.ore_node_scene = load("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
		context.pending_data = building.data
	else:
		return
	context.create_ghost(context.pending_data)
	context.pending_rotation = building.rotation
	transitioned.emit(self, FacilityPlacementState.NAME)
