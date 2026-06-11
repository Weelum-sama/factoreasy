extends PanelContainer
class_name ContextMenuBase

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
