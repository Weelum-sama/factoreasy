extends Node2D

var context: PlacementContext

@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	z_index = 3
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

func _draw() -> void:
	if not context.selection_box_active:
		return
	var mouse := get_global_mouse_position()
	var rect := Rect2(context.selection_box_start, Vector2.ZERO).expand(mouse)
	draw_rect(rect, Color(0.5, 0.8, 1.0, 0.15), true) # Fill
	draw_rect(rect, Color(0.5, 0.8, 1.0, 0.8), false) # Border

func start_placement(data: FacilityData) -> void:
	context.pending_data = data
	if data is OreNodeData:
		context.ore_node_scene = context.ORE_NODE_SCENE
	else:
		context.facility_scene = data.scene
	if state_machine.current_state is FacilityPlacementState:
		state_machine.current_state.switch_requested.emit()
		return
	state_machine.on_child_transition(state_machine.current_state, FacilityPlacementState.NAME)

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	if context.pending_data and resource_id == context.pending_data.id and new_count <= 0:
		if state_machine.current_state is FacilityPlacementState:
			state_machine.on_child_transition(state_machine.current_state, DefaultState.NAME)
