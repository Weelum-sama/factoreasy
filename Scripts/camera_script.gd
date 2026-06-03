extends Camera2D

const MIN_ZOOM: float = 3.5
const MAX_ZOOM: float = 0.25
const ZOOM_INCREMENT: float = 0.2
const MOVE_SPEED: float = 1000
const MIN_MOVE_SPEED: float = 500

const MIN_ZOOM_VECTOR: Vector2 = Vector2(MIN_ZOOM, MIN_ZOOM)
const MAX_ZOOM_VECTOR: Vector2 = Vector2(MAX_ZOOM, MAX_ZOOM)
const ZOOM_INCREMENT_VECTOR: Vector2 = Vector2(ZOOM_INCREMENT, ZOOM_INCREMENT)

var movement_vector: Vector2

func _process(delta: float) -> void:
	_control_zoom()
	_control_position(delta)
	_control_rotation()

func _control_zoom() -> void:
	if Input.is_action_just_pressed("Zoom In"):
		zoom = clamp(zoom + ZOOM_INCREMENT_VECTOR, MAX_ZOOM_VECTOR, MIN_ZOOM_VECTOR)
	elif Input.is_action_just_pressed("Zoom Out"):
		zoom = clamp(zoom - ZOOM_INCREMENT_VECTOR, MAX_ZOOM_VECTOR, MIN_ZOOM_VECTOR)

func _control_position(delta: float) -> void:
	var input_direction = Input.get_vector(
		"Move Left", "Move Right", 
		"Move Up", "Move Down")
	if input_direction != Vector2.ZERO:
		var rotated_direction := input_direction.rotated(rotation)
		var current_zoom: float = MAX_ZOOM / zoom.x
		var current_move_speed: float = clamp(current_zoom * MOVE_SPEED, MIN_MOVE_SPEED, MOVE_SPEED)
		position += rotated_direction * current_move_speed * delta

func _control_rotation() -> void:
	if Input.is_action_just_pressed("Rotate Camera"):
		rotate(PI/2.0)
