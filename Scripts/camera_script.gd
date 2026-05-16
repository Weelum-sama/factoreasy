extends Camera2D

const MIN_ZOOM: Vector2 = Vector2(1.0, 1.0)
const MAX_ZOOM: Vector2 = Vector2(0.1, 0.1)
const ZOOM_INCREMENT: Vector2 = Vector2(0.02, 0.02)
const MOVE_SPEED: float = 1500

var movement_vector: Vector2

func _process(delta: float) -> void:
	_control_zoom()
	_control_position(delta)
	_control_rotation()

func _control_zoom() -> void:
	if Input.is_action_just_pressed("Zoom In"):
		zoom = clamp(zoom + (ZOOM_INCREMENT), MAX_ZOOM, MIN_ZOOM)
	elif Input.is_action_just_pressed("Zoom Out"):
		zoom = clamp(zoom - (ZOOM_INCREMENT), MAX_ZOOM, MIN_ZOOM)

func _control_position(delta: float) -> void:
	var input_direction = Input.get_vector(
		"Move Left", "Move Right", 
		"Move Up", "Move Down")
	if !input_direction == Vector2.ZERO:
		var rotated_direction := input_direction.rotated(rotation)
		position += rotated_direction * MOVE_SPEED * delta

func _control_rotation() -> void:
	if Input.is_action_just_pressed("Rotate"):
		rotate(PI/2.0)
