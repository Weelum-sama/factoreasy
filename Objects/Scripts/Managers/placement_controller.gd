extends Node2D

var context: PlacementContext

const PRODUCING_FACILITY_SCENE = preload("res://Objects/Scenes/Facilities/producing_facility.tscn")
const CONSUMING_FACILITY_SCENE = preload("res://Objects/Scenes/Consuming Facilities/consuming_facility.tscn")
const ORE_NODE_SCENE = preload("res://Objects/Scenes/Ore Nodes/ore_node.tscn")

@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	context = PlacementContext.new()
	context.ghost_parent = self
	
	# Pass context to all states before state machine initialises
	for state in state_machine.states.values():
		state.context = context
	
	var toolbar := get_tree().root.find_child("ToolBarUI", true, false)
	var nodebar := get_tree().root.find_child("OreNodeBarUI", true, false)
	toolbar.placement_requested.connect(start_placement)
	nodebar.placement_requested.connect(start_placement)
	GameState.inventory_changed.connect(_on_inventory_changed)

func start_placement(data: FacilityData) -> void:
	context.pending_data = data
	if data is OreNodeData:
		context.ore_node_scene = ORE_NODE_SCENE
	else:
		context.facility_scene = data.scene
	state_machine.on_child_transition(state_machine.current_state, FacilityPlacementState.NAME)

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	if context.pending_data and resource_id == context.pending_data.id and new_count <= 0:
		if state_machine.current_state is FacilityPlacementState:
			state_machine.on_child_transition(state_machine.current_state, DefaultState.NAME)
