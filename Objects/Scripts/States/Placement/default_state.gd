extends PlacementState
class_name DefaultState

func update(_delta: float):
	if context.hold_candidate != null:
		context.hold_timer += _delta
		if context.hold_timer >= PlacementContext.HOLD_DURATION:
			_pick_up_building(context.hold_candidate)
			context.hold_candidate = null
			context.hold_timer = 0.0

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("Toggle Select"):
		transitioned.emit(self, "selectionstate")
		return
	
	if Input.is_action_pressed("Confirm"):
		var occupant := context.get_building_from_mouse()
		if occupant:
			context.hold_candidate = occupant
	else:
		context.hold_candidate = null
		context.hold_timer = 0.0

func _pick_up_building(building: Node):
	var cell := GridManager.world_to_cell(building.global_position)
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
	context.ghost.rotation = building.rotation
	building.queue_free()
	transitioned.emit(self, "facilityplacementstate")
