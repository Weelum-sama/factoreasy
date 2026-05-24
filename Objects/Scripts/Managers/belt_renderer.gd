extends Node2D

func _ready() -> void:
	z_index = 1
	BeltManager.belt_items_updated.connect(queue_redraw)

func _draw() -> void:
	# Draw belt items
	for cell in BeltManager.belts:
		var belt: Belt = BeltManager.belts[cell]
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
	for delivery in BeltManager._pending_deliveries:
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
