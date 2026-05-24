extends Node2D

func _ready() -> void:
	z_index = 1
	BeltManager.belt_items_updated.connect(queue_redraw)

func _draw() -> void:
	print("BeltRenderer global_position: ", global_position)
	for cell in BeltManager.belts:
		var belt: Belt = BeltManager.belts[cell]
		if belt.belt_item == null or belt.belt_item.item == null:
			continue
		if belt.belt_item.item.texture:
			var position := GridManager.cell_center(cell)
			draw_texture_rect(
				belt.belt_item.item.texture,
				Rect2(position - Vector2(8, 8), Vector2(16, 16)),
				false
			)
