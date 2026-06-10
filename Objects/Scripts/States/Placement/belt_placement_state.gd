extends PlacementState
class_name BeltPlacementState

const NAME = "beltplacement"
const BELT_SCENE = preload("res://Objects/Scenes/Facilities/belt.tscn")

var _drag_start: Vector2i = Vector2i(-1, -1)
var _preview_cells: Array[Vector2i] = []
var _is_dragging: bool = false
var _single_rotation: float = 0.0
var _single_ghost: Sprite2D = null

func exit() -> void:
	_clear_preview()
	_free_single_ghost()
	_drag_start = Vector2i(-1, -1)
	_is_dragging = false
	_single_rotation = 0.0

func update(_delta: float) -> void:
	var current_cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
	
	if Input.is_action_pressed("Confirm") and current_cell != _drag_start:
		_is_dragging = true
	
	if _is_dragging:
		_free_single_ghost()
		_update_preview(current_cell)
	else:
		_clear_preview()
		if _single_ghost == null:
			_single_ghost = _create_belt_ghost(current_cell, 0)
			context.ghost_parent.add_child(_single_ghost)
		_single_ghost.position = GridManager.cell_center(current_cell)
		_single_ghost.rotation = _single_rotation
		_single_ghost.modulate = Color(1, 1, 1, 0.5) if GridManager.is_cell_empty(current_cell) else Color(1, 0.3, 0.3, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		transitioned.emit(self, DefaultState.NAME)
		return
	if event.is_action_pressed("Rotate Building"):
		_single_rotation += PI / 2.0
		return
	if event.is_action_pressed("Confirm"):
		var cell := GridManager.world_to_cell(context.ghost_parent.get_global_mouse_position())
		_drag_start = cell
		return
	if event.is_action_released("Confirm"):
		#if _is_dragging:
		if _single_ghost:
			_preview_cells.append(GridManager.world_to_cell(_single_ghost.position))
		_place_belts()
		_is_dragging = false
		_drag_start = Vector2i(-1, -1)

func _update_preview(current_cell: Vector2i) -> void:
	_clear_preview()
	if _drag_start == Vector2i(-1, -1):
		return
	_preview_cells = _get_line(_drag_start, current_cell)
	
	for i in _preview_cells.size():
		var cell := _preview_cells[i]
		var ghost := _create_belt_ghost(cell, i)
		context.ghost_parent.add_child(ghost)

func _create_belt_ghost(cell: Vector2i, index: int) -> Sprite2D:
	var ghost := Sprite2D.new()
	ghost.texture = load("res://Assets/Sprites/Buildings/belt.png")
	ghost.add_to_group("belt_ghost")
	ghost.position = GridManager.cell_center(cell)
	ghost.rotation = _get_belt_rotation(index)
	ghost.modulate = Color(1, 1, 1, 0.5) if GridManager.is_cell_empty(cell) else Color(1, 0.3, 0.3, 0.5)
	return ghost

func _clear_preview() -> void:
	for child in context.ghost_parent.get_children():
		if child.is_in_group("belt_ghost"):
			child.free()
	_preview_cells.clear()

func _free_single_ghost() -> void:
	if _single_ghost:
		_single_ghost.free()
		_single_ghost = null

func _place_belts() -> void:
	for i in _preview_cells.size():
		var cell := _preview_cells[i]
		if not GridManager.is_cell_empty(cell):
			continue
		var belt: Belt = BELT_SCENE.instantiate()
		belt.rotation = _single_rotation if _preview_cells.size() == 1 else _get_belt_rotation(i)
		context.ghost_parent.get_tree().current_scene.add_child(belt)
		GridManager.place(cell, belt)
		belt.register()
		TutorialManager.notify_belt_placed(belt)

func _get_belt_rotation(index: int) -> float:
	var cells := _preview_cells
	if cells.size() == 0:
		return 0.0
	
	var from := cells[index]
	var to := cells[index + 1] if index + 1 < cells.size() else cells[index]
	if index == cells.size() - 1 and cells.size() > 1:
		to = cells[index]
		from = cells[index - 1]
	var direction := to - from
	return _direction_to_rotation(direction)

func _direction_to_rotation(direction: Vector2i) -> float:
	if direction == Vector2i(1, 0):		return PI / 2	# right
	if direction == Vector2i(-1, 0):	return -PI / 2	# left
	if direction == Vector2i(0, 1):		return PI		# down
	if direction == Vector2i(0, -1):	return 0.0		# up
	return 0.0

func _get_line(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	
	var difference := to - from
	if abs(difference.x) >= abs(difference.y):
		# Horizontal line
		var step := 1 if difference.x >= 0 else -1
		for x in range(from.x, to.x + step, step):
			cells.append(Vector2i(x, from.y))
	else:
		# Vertical line
		var step := 1 if difference.y >= 0 else -1
		for y in range(from.y, to.y + step, step):
			cells.append(Vector2i(from.x, y))
	return cells
