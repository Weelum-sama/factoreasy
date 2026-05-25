extends PlacementState
class_name SelectionState

const NAME = "selection"

var is_selecting: bool = false
var buildings_to_select: Array[Node] = []

func enter() -> void:
	Util.set_current_placement_mode(Util.PLACEMENTMODE.SELECTION)

func update(_delta: float) -> void:
	if not is_selecting:
		return
	var building := context.get_building_from_mouse()
	if not building:
		return
	if not buildings_to_select.has(building):
		buildings_to_select.append(building)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Toggle Select") or Input.is_action_just_pressed("Cancel"):
		context.clear_selection()
		transitioned.emit(self, DefaultState.NAME)
		return
	
	if Input.is_action_just_pressed("Confirm"):
		buildings_to_select.clear()
		is_selecting = true
		return
	
	if Input.is_action_just_released("Confirm"):
		is_selecting = false
		for building in buildings_to_select:
			if building:
				if context.selected_buildings.has(building):
					unselect_building(building)
				else:
					select_building(building)
		return
	
	if Input.is_action_just_pressed("Select All"):
		select_all_buildings()
		return
	
	if not context.selected_buildings.is_empty():
		if Input.is_action_just_pressed("Move Selection"):
			transitioned.emit(self, GroupMovementState.NAME)
		if Input.is_action_just_pressed("Stash"):
			for building in context.selected_buildings:
				building.cleanup()
			context.selected_buildings.clear()
			transitioned.emit(self, DefaultState.NAME)

func unselect_building(building: Node) -> void:
	context.selected_buildings.erase(building)
	building.modulate = Color.WHITE

func select_building(building: Node) -> void:
	context.selected_buildings.append(building)
	building.modulate = Color.SKY_BLUE

func select_all_buildings() -> void:
	context.clear_selection()
	context.selected_buildings = GridManager.get_all_cell_occupants()
	for building in context.selected_buildings:
		building.modulate = Color.SKY_BLUE
