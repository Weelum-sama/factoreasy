extends Node2D

func _ready() -> void:
	GameState.factory_size_changed.connect(queue_redraw)

func _draw() -> void:
	var bounds := GameState.get_factory_bounds()
	var cell_size := GridManager.CELL_SIZE
	var grid_color := Color(1, 1, 1, 0.1)
	var border_color := Color(1, 1, 1, 0.4)
	
	for x in range(bounds.position.x, bounds.end.x + 1):
		var screen_x := x * cell_size
		var top := bounds.position.y * cell_size
		var bottom := bounds.end.y * cell_size
		draw_line(Vector2(screen_x, top), Vector2(screen_x, bottom), grid_color)
	
	for y in range(bounds.position.y, bounds.end.y + 1):
		var screen_y := y * cell_size
		var left := bounds.position.x * cell_size
		var right := bounds.end.x * cell_size
		draw_line(Vector2(left, screen_y), Vector2(right, screen_y), grid_color)
	
	var rect := Rect2i(
		Vector2(bounds.position) * cell_size,
		Vector2(bounds.size) * cell_size
	)
	draw_rect(rect, border_color, false, 2.0)
