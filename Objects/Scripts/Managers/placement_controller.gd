extends Node2D

# Hovering sprite for placement preview
var _ghost: Sprite2D = null

# Placeable scenes
var _facility_scene: PackedScene = null
var _consuming_facility_scene: PackedScene = null
var _ore_node_scene: PackedScene = null

# Data for placeables
var _pending_data: FacilityData = null

# Array of buildings selected for selection mode
var selected_buildings: Array[Node] = []

# Moving placed buildings
var _hold_timer: float = 0.0
const HOLD_DURATION: float = 0.3
var _hold_candidate: Node = null

func _ready() -> void:
	# UI initialisation
	var toolbar := get_tree().root.find_child("ToolBarUI", true, false)
	var nodebar := get_tree().root.find_child("OreNodeBarUI", true, false)
	toolbar.placement_requested.connect(start_placement)
	nodebar.placement_requested.connect(start_placement)
	GameState.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	# Stop placement once final node is used up
	if Util.get_current_placement_mode() == Util.PLACEMENTMODE.ORE_NODE:
		if _pending_data and resource_id == _pending_data.id and new_count <= 0:
			_cancel_placement()

func _unhandled_input(event: InputEvent) -> void:
	# Check whether select mode is toggled
	if Input.is_action_just_pressed("Toggle Select"):
		if Util.get_current_placement_mode() == Util.PLACEMENTMODE.SELECTION:
			_exit_select_mode()
		else:
			_cancel_placement()
			
			Util.set_current_placement_mode(Util.PLACEMENTMODE.SELECTION)
		return
	
	# Quick selection
	if Input.is_action_just_pressed("Quick Select"):
		var building = _get_building_from_mouse()
		if not building:
			return
		
		if building is ProducingFacility or building is ConsumingFacility:
			start_placement(building.facility_data)
		elif building is OreNode:
			if GameState.has_node_in_inventory(building.data.id):
				start_placement(building.data)
	
	# Checking for input for moving buildings
	if Input.is_action_pressed("Confirm") and Util.get_current_placement_mode() == Util.PLACEMENTMODE.NONE:
		var occupant = _get_building_from_mouse()
		if occupant != null:
			_hold_candidate = occupant
			#_hold_timer = 0.0
	else:
		_hold_candidate = null
		_hold_timer = 0.0
	
	# Handling input based on current placement mode
	match Util.get_current_placement_mode():
		Util.PLACEMENTMODE.FACILITY:
			_handle_placement_input()
		Util.PLACEMENTMODE.ORE_NODE:
			_handle_placement_input()
		Util.PLACEMENTMODE.SELECTION:
			_handle_selection_input()

func _handle_placement_input() -> void:
	# If there's no ghost, jump out
	if _ghost == null:
		return
	
	# Retrieve mouse position and draw the ghost accordingly
	var mouse := get_global_mouse_position()
	var snapped := GridManager.snap_to_grid(mouse)
	var cell := GridManager.world_to_cell(mouse)
	_ghost.position = snapped + Vector2(GridManager.CELL_SIZE * 0.5, GridManager.CELL_SIZE * 0.5)
	
	# Visual indicator for cell validity
	if GridManager.is_cell_empty(cell):
		_ghost.modulate = Color(1, 1, 1, 0.6)
	else:
		_ghost.modulate = Color(1, 0.3, 0.3, 0.6)
	
	# Placement
	if Input.is_action_just_released("Confirm"): # On release specifically
		_try_place()
	if Input.is_action_just_pressed("Cancel"):
		_cancel_placement()
	if Input.is_action_just_pressed("Rotate Building"):
		_rotate_building()

func _handle_selection_input() -> void:
	# Retrieve building selected and stored in array
	if Input.is_action_just_pressed("Confirm"):
		var building = _get_building_from_mouse()
		if building:
			if not selected_buildings.has(building):
				selected_buildings.append(building)
			else:
				selected_buildings.erase(building)
				building.modulate = Color(1.0, 1.0, 1.0)
	
	# Select all buildings and store them in array
	if Input.is_action_just_pressed("Select All"):
		selected_buildings.clear()
		selected_buildings = GridManager.get_all_cell_occupants()
	
	# If one or more buildings are selected, shade them differently
	if not selected_buildings.is_empty():
		for building in selected_buildings:
			building.modulate = Color.SKY_BLUE
		
		# Stash selected buildings if desired
		if Input.is_action_just_pressed("Stash"):
			for building in selected_buildings:
				var cell_to_remove = GridManager.world_to_cell(building.global_position)
				GridManager.remove(cell_to_remove)
				building.queue_free()
			_exit_select_mode()
	
	# Get out of selection mode if canceled
	if Input.is_action_just_pressed("Cancel"):
		_exit_select_mode()

func start_placement(data: FacilityData) -> void:
	# Override any prior placements
	_cancel_placement()
	
	# Retrieve data for placeable
	_pending_data = data
	if data is ProducingFacilityData:
		_facility_scene = load("res://Objects/Scenes/Facilities/producing_facility.tscn")
		Util.set_current_placement_mode(Util.PLACEMENTMODE.FACILITY)
	elif data is ConsumingFacilityData:
		_consuming_facility_scene = load("res://Objects/Scenes/Consuming Facilities/consuming_facility.tscn")
		Util.set_current_placement_mode(Util.PLACEMENTMODE.FACILITY)
	elif data is OreNodeData:
		_ore_node_scene = load("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
		Util.set_current_placement_mode(Util.PLACEMENTMODE.ORE_NODE)
	
	# Instantiate ghost for placement preview
	_ghost = Sprite2D.new()
	if data.texture:
		_ghost.texture = data.texture
	add_child(_ghost)

# Attempt to place the building
func _try_place() -> void:
	var cell := GridManager.world_to_cell(get_global_mouse_position())
	match Util.get_current_placement_mode():
		Util.PLACEMENTMODE.FACILITY:
			_place_facility(cell)
		Util.PLACEMENTMODE.ORE_NODE:
			_place_ore_node(cell)

# Facilities can be placed without exiting placement mode
func _place_facility(cell: Vector2i) -> void:
	var data := _pending_data
	var building
	
	# Check what type of building is being placed
	if data is ProducingFacilityData:
		building = _facility_scene.instantiate()
	elif data is ConsumingFacilityData:
		building = _consuming_facility_scene.instantiate()
	else:
		push_error("Unknown facility data type: " + data.get_class())
		return
	
	building.facility_data = data
	building.rotation = _ghost.rotation
	
	# Place building and register in GridManager, building removed if unable to register
	get_tree().current_scene.add_child(building)
	if not GridManager.place(cell, building):
		building.queue_free()

# Ore nodes can be placed without exiting unless inventory is empty
func _place_ore_node(cell: Vector2i) -> void:
	# Jump out if cell is already occupied, ore nodes are given back when exiting tree!
	if not GridManager.is_cell_empty(cell):
		return
	
	# Retrieve data for placable
	var data := _pending_data as OreNodeData
	var node: OreNode = _ore_node_scene.instantiate()
	node.data = _pending_data
	node.rotation = _ghost.rotation
	
	# Add node to the tree and register in GridManager
	get_tree().current_scene.add_child(node)
	if not GridManager.place(cell, node):
		return
	# Consume the node from inventory if placed and registered
	GameState.consume_node_from_inventory(_pending_data.id)

# Checks mouse position and returns the node that occupies the hovered cell
func _get_building_from_mouse() -> Node:
	var mouse := get_global_mouse_position()
	var cell := GridManager.world_to_cell(mouse)
	return GridManager.get_cell_occupant(cell)

# Rotate ghost and therefore building
func _rotate_building() -> void:
	if _ghost:
		_ghost.rotate(PI/2.0)

# Getting out of select mode requires logic
func _exit_select_mode() -> void:
	Util.set_current_placement_mode(Util.PLACEMENTMODE.NONE)
	if not selected_buildings.is_empty():
		for building in selected_buildings:
			building.modulate = Color(1.0, 1.0, 1.0)
	selected_buildings.clear()

# Canceling placement and clearing data
func _cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	if Util.get_current_placement_mode() == Util.PLACEMENTMODE.SELECTION:
		_exit_select_mode()
	_facility_scene = null
	_pending_data = null
	_ore_node_scene = null
	Util.set_current_placement_mode(Util.PLACEMENTMODE.NONE)



func _process(delta: float) -> void:
	if Util._current_placement_mode == Util.PLACEMENTMODE.NONE:
		if _hold_candidate != null:
			_hold_timer += delta
			if _hold_timer >= HOLD_DURATION:
				_pick_up_building(_hold_candidate)
				_hold_candidate = null
				_hold_timer = 0.0
		return


func _pick_up_building(building: Node) -> void:
	var cell := GridManager.world_to_cell((building as Node2D).global_position)
	GridManager.remove(cell)
	
	if building is ProducingFacility:
		_facility_scene = load("res://Objects/Scenes/Facilities/producing_facility.tscn")
		_pending_data = building.facility_data
		Util.set_current_placement_mode(Util.PLACEMENTMODE.FACILITY)
	elif building is ConsumingFacility:
		_consuming_facility_scene = load("res://Objects/Scenes/Consuming Facilities/consuming_facility.tscn")
		_pending_data = building.facility_data
		Util.set_current_placement_mode(Util.PLACEMENTMODE.FACILITY)
	elif building is OreNode:
		_ore_node_scene = load("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
		_pending_data = building.data
		Util.set_current_placement_mode(Util.PLACEMENTMODE.ORE_NODE)
	
	building.queue_free()
	_ghost = Sprite2D.new()
	if _pending_data and _pending_data.texture:
		_ghost.texture = _pending_data.texture
	add_child(_ghost)
	
