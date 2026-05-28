extends PlacementState
class_name GroupMovementState

const NAME = "groupmovement"

var _ghosts: Array[Sprite2D] = []
var _group_rotation: int = 0

func enter() -> void:
	_group_rotation = 0
	var centroid := Vector2i.ZERO
	_set_selected_buildings_visible(false)
	for building in context.selected_buildings:
		centroid += GridManager.world_to_cell(building.global_position)
	centroid /= context.selected_buildings.size()
	
	context.group_move_offsets.clear()
	
	for building in context.selected_buildings:
		var cell := GridManager.world_to_cell(building.global_position)
		context.group_move_offsets.append(cell - centroid)
	
	for i in context.selected_buildings.size():
		var building := context.selected_buildings[i]
		var ghost := Sprite2D.new()
		var data: FacilityData = null
		if building is OreNode:
			data = building.data
		elif building is Belt:
			ghost.texture = load("res://Assets/Sprites/Buildings/belt.png")
		elif building is BaseFacility:
			data = GameState.facility_registry.get(building.facility_id)
		if data and data.texture:
			ghost.texture = data.texture
		ghost.rotation = building.rotation
		ghost.modulate = Color(1, 1, 1, 0.5)
		context.ghost_parent.add_child(ghost)
		_ghosts.append(ghost)

func exit() -> void:
	for ghost in _ghosts:
		if is_instance_valid(ghost):
			ghost.free()
	_ghosts.clear()
	context.group_move_offsets.clear()
	_group_rotation = 0
	_set_selected_buildings_visible()

func update(_delta: float) -> void:
	var cursor_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	for i in _ghosts.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		_ghosts[i].position = GridManager.cell_center(target_cell)
		
		var occupant := GridManager.get_cell_occupant(target_cell)
		var is_free := occupant == null or context.selected_buildings.has(occupant)
		
		_ghosts[i].modulate = Color(1, 0.3, 0.3, 0.5) if not is_free else Color(1, 1, 1, 0.5)

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
		var target_cell := cursor_cell + context.group_move_offsets[i]
		var occupant := GridManager.get_cell_occupant(target_cell)
		if occupant != null and not context.selected_buildings.has(occupant):
			return
	
	for i in context.selected_buildings.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		var building := context.selected_buildings[i]
		if building is Belt:
			building.move_to(target_cell)
		else:
			building.move_to(target_cell)
		building.rotation = _ghosts[i].rotation
		building.modulate = Color.WHITE
	
	context.selected_buildings.clear()
	if context.entered_from_selection:
		transitioned.emit(self, SelectionState.NAME)
	else:
		transitioned.emit(self, DefaultState.NAME)

func _cancel_group_move() -> void:
	for ghost in _ghosts:
		if is_instance_valid(ghost):
			ghost.free()
	_ghosts.clear()
	context.group_move_offsets.clear()
	_group_rotation = 0
	
	if context.entered_from_selection:
		transitioned.emit(self, SelectionState.NAME)
	else:
		transitioned.emit(self, DefaultState.NAME)

func _set_selected_buildings_visible(visible: bool = true) -> void:
	for building in context.selected_buildings:
		if not is_instance_valid(building):
			continue
		building.modulate = Color.WHITE if visible else Color(1, 1, 1, 0)

func _rotate_group() -> void:
	_group_rotation = (_group_rotation + 1) % 4
	for i in context.group_move_offsets.size():
		context.group_move_offsets[i] = context.rotate_offset_90(context.group_move_offsets[i])
	for ghost in _ghosts:
		ghost.rotation += PI / 2.0
