extends Node2D


var _ghost: Sprite2D = null
var building_scene: PackedScene = null
var placement_active: bool = false

func _process(delta: float) -> void:
	if not placement_active:
		return
	if _ghost == null:
		return
	
	var mouse := get_global_mouse_position()
	var snapped: Vector2 = GridManager.snap_to_grid(mouse)
	var cell: Vector2 = GridManager.cell_to_world(mouse)
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

func start_placement(scene: PackedScene) -> void:
	_cancel_placement()
	building_scene = scene
	_ghost = Sprite2D.new()
	# TODO: assign ghost.texture from scene metadata or a preview texture
	add_child(_ghost)

func _try_place() -> void:
	var cell: Vector2 = GridManager.world_to_cell(get_global_mouse_position())
	var building := building_scene.instantiate()
	get_tree().current_scene.add_child(building)
	if not GridManager.place(cell, building):
		building.queue_free() # could not place
	
	# In case of resource node
	if building.has_method("get_resource_id"):
		var consumed := GameState.consume_node_from_inventory(building.get_resource_id())
		if not consumed:
			GridManager.remove(cell)
			building.queue_free()
			return

func _cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	building_scene = null
