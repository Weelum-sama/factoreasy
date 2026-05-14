extends Node2D

func _draw() -> void:
	var cols := 30
	var rows := 20
	var cs := GridManager.CELL_SIZE
	var color := Color(1, 1, 1, 0.06)
	for x in range(cols + 1):
		draw_line(Vector2(x * cs, 0), Vector2(x * cs, rows * cs), color)
	for y in range(rows + 1):
		draw_line(Vector2(0, y * cs), Vector2(cols * cs, y * cs), color)
