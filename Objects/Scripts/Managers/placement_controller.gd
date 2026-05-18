extends Node2D

var _ghost: Sprite2D = null

# Facility
var _facility_scene: PackedScene = null
var _pending_facility_data: FacilityData = null

# Ore Node
var _pending_ore_data: OreNodeData = null
var _ore_node_scene: PackedScene = null

var current_mode: Util.PLACEMENTMODE = Util.PLACEMENTMODE.NONE

func _ready() -> void:
	var toolbar := get_tree().root.find_child("ToolBarUI", true, false)
	var nodebar := get_tree().root.find_child("OreNodeBarUI", true, false)
	toolbar.placement_requested.connect(start_placement)
	nodebar.placement_requested.connect(start_ore_placement)
	GameState.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	if current_mode == Util.PLACEMENTMODE.ORE_NODE:
		if _pending_ore_data and resource_id == _pending_ore_data.id and new_count <= 0:
			_cancel_placement()

func _unhandled_input(event: InputEvent) -> void:
	if current_mode == Util.PLACEMENTMODE.NONE or _ghost == null:
		return
	
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
	if Input.is_action_just_pressed("Confirm"):
		_try_place()
	if Input.is_action_just_pressed("Cancel"):
		_cancel_placement()

func start_placement(data: FacilityData) -> void:
	_cancel_placement()
	_facility_scene = load("res://Objects/Scenes/Facilities/producing_facility.tscn")
	_pending_facility_data = data
	current_mode = Util.PLACEMENTMODE.FACILITY
	_ghost = Sprite2D.new()
	if data.texture:
		_ghost.texture = data.texture
	add_child(_ghost)

func start_ore_placement(data: OreNodeData) -> void:
	_cancel_placement()
	_ore_node_scene = load("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
	_pending_ore_data = data
	current_mode = Util.PLACEMENTMODE.ORE_NODE
	_ghost = Sprite2D.new()
	if data.texture:
		_ghost.texture = data.texture
	add_child(_ghost)

func _try_place() -> void:
	var cell := GridManager.world_to_cell(get_global_mouse_position())
	match current_mode:
		Util.PLACEMENTMODE.FACILITY:
			_place_facility(cell)
		Util.PLACEMENTMODE.ORE_NODE:
			_place_ore_node(cell)

# Facilities can be placed without exiting
func _place_facility(cell: Vector2i) -> void:
	var building: ProducingFacility = _facility_scene.instantiate()
	building.facility_data = _pending_facility_data
	get_tree().current_scene.add_child(building)
	if not GridManager.place(cell, building):
		building.queue_free()

# Ore nodes can be placed without exiting unless inventory is empty
func _place_ore_node(cell: Vector2i) -> void:
	if not GridManager.is_cell_empty(cell):
		return
	var node: OreNode = _ore_node_scene.instantiate()
	node.data = _pending_ore_data
	get_tree().current_scene.add_child(node)
	GameState.consume_node_from_inventory(_pending_ore_data.id)
	if not GridManager.place(cell, node):
		GameState.add_node_to_inventory(_pending_ore_data.id) # Give back if placement failed

func _cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	_facility_scene = null
	_pending_facility_data = null
	_ore_node_scene = null
	_pending_ore_data = null
	current_mode = Util.PLACEMENTMODE.NONE
