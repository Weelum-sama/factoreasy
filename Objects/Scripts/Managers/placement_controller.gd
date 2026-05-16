extends Node2D

@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"

var _ghost: Sprite2D = null
var _pending_data: FacilityData = null
var _facility_scene: PackedScene
var placement_active: bool = false

func _ready() -> void:
	var toolbar := get_tree().root.find_child("ToolBarUI", true, false)
	toolbar.placement_requested.connect(start_placement)

func _process(delta: float) -> void:
	if not placement_active or _ghost == null:
		return
	
	var mouse := get_global_mouse_position()
	var snapped := GridManager.snap_to_grid(mouse)
	var cell := GridManager.cell_to_world(mouse)
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
	_pending_data = data
	placement_active = true
	_ghost = Sprite2D.new()
	if data.texture:
		_ghost.texture = data.texture
	add_child(_ghost)

func _try_place() -> void:
	if _pending_data == null:
		return
	var cell := GridManager.world_to_cell(get_global_mouse_position())
	var building: ProducingFacility = _facility_scene.instantiate()
	building.facility_data = _pending_data
	get_tree().current_scene.add_child(building)
	if not GridManager.place(cell, building):
		building.queue_free() # could not place
		return
	
	# In case of resource node
	if building.has_method("get_resource_id"):
		if not GameState.consume_node_from_inventory(building.get_resource_id()):
			GridManager.remove(cell)
			building.queue_free()
			return

func _cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	_facility_scene = null
