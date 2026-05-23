extends PlacementState
class_name FacilityPlacementState

const NAME = "facilityplacement"

func enter() -> void:
	Util.set_current_placement_mode(Util.PLACEMENTMODE.FACILITY)
	context.create_ghost(context.pending_data)
	context.pending_rotation = 0.0

func exit() -> void:
	context.destroy_ghost()
	context.pending_data = null
	context.facility_scene = null
	context.consuming_facility_scene = null
	context.ore_node_scene = null

func update(_delta: float) -> void:
	if context.ghost == null:
		return
	var mouse := context.ghost_parent.get_global_mouse_position()
	var snapped : = GridManager.snap_to_grid(mouse)
	var cell := GridManager.world_to_cell(mouse)
	context.ghost.visible = true
	context.ghost.position = snapped + Vector2(GridManager.CELL_SIZE * 0.5, GridManager.CELL_SIZE * 0.5)
	context.ghost.modulate = Color(1, 1, 1, 0.6) if GridManager.is_cell_empty(cell) else Color(1, 0.3, 0.3, 0.6)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Confirm"):
		_try_place()
	elif Input.is_action_just_released("Cancel"):
		transitioned.emit(self, DefaultState.NAME)
	if Input.is_action_just_pressed("Rotate Building"):
		if context.ghost:
			context.ghost.rotate(PI / 2.0)

func _try_place() -> void:
	var cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	if context.pending_data is OreNodeData:
		_place_ore_node(cell)
	else:
		_place_facility(cell)

func _place_facility(cell: Vector2i) -> void:
	if context.facility_scene == null:
		push_error("No facility scene set")
		return
	
	var building: BaseFacility = context.facility_scene.instantiate()
	building.facility_id = context.pending_data.id
	building.rotation = context.ghost.rotation
	context.ghost_parent.get_tree().current_scene.add_child(building)
	if not GridManager.place(cell, building):
		building.queue_free()

func _place_ore_node(cell: Vector2i) -> void:
	if not GridManager.is_cell_empty(cell):
		return
	var node: OreNode = context.ore_node_scene.instantiate()
	node.data = context.pending_data
	node.rotation = context.ghost.rotation
	context.ghost_parent.get_tree().current_scene.add_child(node)
	if not GridManager.place(cell, node):
		return
	GameState.consume_node_from_inventory(context.pending_data.id)
