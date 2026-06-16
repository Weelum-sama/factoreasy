extends PlacementState
class_name GroupMovementState

const NAME = "groupmovement"

var _ghosts: Array[Sprite2D] = []
var _group_rotation: int = 0

func enter() -> void:
	super.enter()
	_group_rotation = 0
	var centroid := Vector2i.ZERO
	_set_selected_buildings_visible(context.is_copy_mode)
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
		if data and data.texture and building is not Belt:
			ghost.texture = data.texture if context.entered_from_selection else data.preview_texture
		ghost.rotation = building.rotation
		ghost.modulate = Color(1, 1, 1, 0.5)
		# Position at the mouse before appending
		var mouse := context.ghost_parent.get_viewport().get_mouse_position()
		var snapped := GridManager.snap_to_grid(mouse)
		ghost.position = snapped + Vector2(GridManager.CELL_SIZE * 0.5, GridManager.CELL_SIZE * 0.5)
		context.ghost_parent.add_child(ghost)
		_ghosts.append(ghost)
		if not context.entered_from_selection:
			_play_pick_up_tween(_ghosts[0])

func exit() -> void:
	for ghost in _ghosts:
		if is_instance_valid(ghost):
			ghost.free()
	_ghosts.clear()
	context.group_move_offsets.clear()
	_group_rotation = 0
	
	context.is_copy_mode = false
	
	if not context.entered_from_selection:
		return
	for building in context.selected_buildings:
		building.modulate = Color.SKY_BLUE

func update(_delta: float) -> void:
	var cursor_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	for i in _ghosts.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		_ghosts[i].position = GridManager.cell_center(target_cell)
		
		var building := context.selected_buildings[i]
		var is_free := true
		if building is BaseFacility and (building as BaseFacility).is_multi_cell():
			var bf := building as BaseFacility
			var data := bf.get_data()
			var fp := GridManager.compute_footprint(target_cell, data.building_width, data.building_height, _ghosts[i].rotation)
			
			for fp_cell in fp:
				var occupant := GridManager.get_cell_occupant(fp_cell)
				if context.is_copy_mode:
					if not GridManager.is_cell_in_bounds(fp_cell) or (occupant != null):
						is_free = false
						break
				else:
					if not GridManager.is_cell_in_bounds(fp_cell) or (occupant != null and not context.selected_buildings.has(occupant)):
						is_free = false
						break
		else:
			var occupant := GridManager.get_cell_occupant(target_cell)
			var in_bounds := GridManager.is_cell_in_bounds(target_cell)
			if context.is_copy_mode:
				is_free = in_bounds and (occupant == null)
			else:
				is_free = in_bounds and (occupant == null or context.selected_buildings.has(occupant))
		
		_ghosts[i].modulate = Color(1, 1, 1, 0.5) if is_free else Color(1, 0.3, 0.3, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Building"):
		_rotate_group()
	if event.is_action_released("Confirm"):
		_try_place_group()
	if event.is_action_released("Cancel"):
		_cancel_group_move()
	if event.is_action_pressed("Stash") and not context.entered_from_selection:
		for building in context.selected_buildings:
				building.cleanup()
				BeltManager.cancel_deliveries_to(building)
		context.selected_buildings.clear()
		transitioned.emit(self, DefaultState.NAME)

func _try_place_group() -> void:
	var cursor_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	# Validate all target cells
	for i in context.selected_buildings.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		var building := context.selected_buildings[i]
		if building is BaseFacility and (building as BaseFacility).is_multi_cell():
			var bf := building as BaseFacility
			var data := bf.get_data()
			var fp := GridManager.compute_footprint(target_cell, data.building_width, data.building_height, _ghosts[i].rotation)
			for fp_cell in fp:
				var occupant := GridManager.get_cell_occupant(fp_cell)
				if context.is_copy_mode:
					if occupant != null or not GridManager.is_cell_in_bounds(target_cell):
						return
				else:
					if occupant != null and not context.selected_buildings.has(occupant):
						return
					if not GridManager.is_cell_in_bounds(fp_cell):
						return
		else:
			var occupant := GridManager.get_cell_occupant(target_cell)
			if context.is_copy_mode:
				if occupant != null or not GridManager.is_cell_in_bounds(target_cell):
					return
			else:
				if occupant != null and not context.selected_buildings.has(occupant):
					return
				if not GridManager.is_cell_in_bounds(target_cell):
					return
	
	# Remove all from current positions (skip in copy mode)
	if not context.is_copy_mode:
		for building in context.selected_buildings:
			if building is BaseFacility and (building as BaseFacility).is_multi_cell():
				GridManager.remove_footprint((building as BaseFacility).get_footprint())
			elif building is Belt:
				var cell := GridManager.world_to_cell(building.global_position)
				GridManager.remove(cell)
				BeltManager.unregister_belt(cell)
			else:
				GridManager.remove(GridManager.world_to_cell(building.global_position))
	
	if not _can_place_copy():
		Util.cannot_copy_selection.emit(context.missing_ore_nodes)
		context.missing_ore_nodes.clear()
		return
	
	# Place at new positions
	for i in context.selected_buildings.size():
		var target_cell := cursor_cell + context.group_move_offsets[i]
		var building := context.selected_buildings[i] if not context.is_copy_mode else _instantiate_copy(context.selected_buildings[i])
		building.rotation = _ghosts[i].rotation
		
		if building is BaseFacility and (building as BaseFacility).is_multi_cell():
			var bf := building as BaseFacility
			var data := bf.get_data()
			var fp := GridManager.compute_footprint(target_cell, data.building_width, data.building_height, building.rotation)
			GridManager.place_footprint(fp, target_cell, building)
		elif building is Belt:
			var old_cell := GridManager.world_to_cell(building.global_position)
			var delta := target_cell - old_cell
			if building.belt_item != null:
				building.belt_item.previous_cell += delta
				building.belt_item.current_cell += delta
			BeltManager.update_delivery_cells(old_cell, delta)
			GridManager.place(target_cell, building)
			BeltManager.register_belt(target_cell, building)
		else:
			GridManager.place(target_cell, building)
			if context.is_copy_mode and building is OreNode:
				GameState.consume_node_from_inventory(building.data.id)
		building.modulate = Color.WHITE
	
	if _selected_buildings_contains_belt() and not context.is_copy_mode:
		BeltManager.stop_moving_belts.emit()
	# Quick move should also notify tutorial manager
	if not context.entered_from_selection:
		var building := context.selected_buildings[0]
		_play_put_down_tween(building)
		if building is BaseFacility:
			TutorialManager.notify_facility_placed(building)
		elif building is Belt:
			TutorialManager.notify_belt_placed(building)
	if context.is_copy_mode:
		return
	context.selected_buildings.clear()
	transitioned.emit(self, DefaultState.NAME)

func _cancel_group_move() -> void:
	if _selected_buildings_contains_belt():
		BeltManager.stop_moving_belts.emit()
	for ghost in _ghosts:
		if is_instance_valid(ghost):
			ghost.free()
	_ghosts.clear()
	context.group_move_offsets.clear()
	_group_rotation = 0
	_set_selected_buildings_visible()
	
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

func _selected_buildings_contains_belt() -> bool:
	for building in context.selected_buildings:
		if building is Belt:
			return true
	return false

func _instantiate_copy(building: Node) -> Node2D:
	if building is OreNode:
		var node: OreNode = PlacementContext.ORE_NODE_SCENE.instantiate()
		node.data = building.data
		node.rotation = building.rotation
		add_child(node)
		return node
	elif building is Belt:
		var belt_scene := preload("res://Objects/Scenes/Facilities/belt.tscn")
		var node: Belt = belt_scene.instantiate()
		node.rotation = building.rotation
		add_child(node)
		return node
	elif building is BaseFacility:
		var facility := building as BaseFacility
		var data := GameState.facility_registry.get(facility.facility_id) as FacilityData
		if not data or not data.scene:
			return null
		var node: BaseFacility = data.scene.instantiate()
		node.facility_id = facility.facility_id
		node.rotation = building.rotation
		add_child(node)
		return node
	return null

func _can_place_copy() -> bool:
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
