extends PlacementState
class_name SelectionState

func exit() -> void:
	context.clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Toggle Select") or Input.is_action_just_pressed("Cancel"):
		transitioned.emit(self, "defaultstate")
		return
	
	if Input.is_action_just_released("Confirm"):
		var building := context.get_building_from_mouse()
		if building:
			if context.selected_buildings.has(building):
				context.selected_buildings.erase(building)
				building.modulate = Color.WHITE
			else:
				context.selected_buildings.append(building)
				building.modulate = Color.SKY_BLUE
	
	if Input.is_action_just_pressed("Select All"):
		context.clear_selection()
		context.selected_buildings = GridManager.get_all_cell_occupants()
		for building in context.selected_buildings:
			building.modulate = Color.SKY_BLUE
	
	if not context.selected_buildings.is_empty():
		if Input.is_action_just_pressed("Move Selection"):
			transitioned.emit(self, "groupmovementstate")
		if Input.is_action_just_pressed("Stash"):
			for building in context.selected_buildings:
				GridManager.remove(GridManager.world_to_cell(building.global_position))
				building.queue_free()
			context.selected_buildings.clear()
			transitioned.emit(self, "defaultstate")
