extends PanelContainer
class_name ContextMenuBase

var _tween: Tween

func _position_clamped(screen_pos: Vector2) -> void:
	position = screen_pos
	await get_tree().process_frame
	var viewport := get_viewport_rect().size
	position = Vector2(
		clamp(position.x, 0.0, viewport.x - size.x),
		clamp(position.y, 0.0, viewport.y - size.y)
	)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("Cancel"):
		var layer := get_parent() as ContextMenuLayer
		if layer:
			layer.close_top()
		get_viewport().set_input_as_handled()

func _play_open_tween(control: Control) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(control, "scale", Vector2(1.1, 1.1), .05).from(Vector2(0.0, 0.0))
	_tween.tween_property(control, "scale", Vector2(1.0, 1.0), .05)

func _play_close_tween(control: Control) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(control, "scale", Vector2(1.1, 1.1), .05).from(Vector2(1.0, 1.0))
	_tween.tween_property(control, "scale", Vector2(0.0, 0.0), .01)
