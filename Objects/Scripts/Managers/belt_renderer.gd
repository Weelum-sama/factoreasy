extends Node2D

var excluded_belts: Array[Belt]

func _ready() -> void:
	z_index = 1
	BeltManager.belt_items_updated.connect(queue_redraw)
	BeltManager.moving_belts.connect(_assign_excluded_belts)
	BeltManager.stop_moving_belts.connect(_reset_excluded_belts)

func _draw() -> void:
	if not BeltManager.belts:
		return
	# Draw belt items
	for cell in BeltManager.belts:
		var belt: Belt = BeltManager.belts[cell]
		if not is_instance_valid(belt):
			continue
		if not excluded_belts.is_empty() and excluded_belts.has(belt):
			continue
		if belt.belt_item == null or belt.belt_item.item == null:
			continue
		if not belt.belt_item.item.texture:
			continue
		var from_position := GridManager.cell_center(belt.belt_item.previous_cell)
		var to_position := GridManager.cell_center(belt.belt_item.current_cell)
		var draw_position := from_position.lerp(to_position, belt.belt_item.progress)
		draw_texture_rect(
			belt.belt_item.item.texture,
			Rect2(draw_position - Vector2(8, 8), Vector2(16, 16)),
			false
		)
		
	# Draw delieveries to facilities
	for delivery in BeltManager.get_current_pending_deliveries():
		if excluded_belts.has(GridManager.get_cell_occupant(delivery.from_cell)):
			continue
		var item: Item = delivery.item
		if not item.texture:
			continue
		var from_position := GridManager.cell_center(delivery.from_cell)
		var to_position := GridManager.cell_center(delivery.to_cell)
		var draw_position := from_position.lerp(to_position, delivery.progress)
		draw_texture_rect(
			item.texture,
			Rect2(draw_position - Vector2(8, 8), Vector2(16, 16)),
			false
		)

func _assign_excluded_belts(belts: Array[Belt]) -> void:
	excluded_belts = belts

func _reset_excluded_belts() -> void:
	excluded_belts.clear()
