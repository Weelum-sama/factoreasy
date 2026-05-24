extends Node

var belts: Dictionary = {}

signal belt_items_updated

func _ready() -> void:
	TickManager.tick_occurred.connect(_tick)

func register_belt(cell: Vector2i, belt: Belt) -> void:
	belts[cell] = belt

func unregister_belt(cell: Vector2i) -> void:
	belts.erase(cell)

func _tick() -> void:
	_try_pull_from_facilities()
	_move_items()
	_try_push_to_facilities()
	belt_items_updated.emit()

func _try_pull_from_facilities() -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if not is_instance_valid(belt):
			continue
		if belt.belt_item != null:
			continue
		var source := GridManager.get_cell_occupant(belt.get_input_cell())
		if source is BaseFacility:
			var item : Item = source.peek_output()
			if item:
				source.take_item(item)
				var belt_item : BeltItem = BeltItem.new()
				belt_item.item = item
				belt.belt_item = belt_item

func _move_items() -> void:
	var moves: Dictionary = {}
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		var target: Belt = belts.get(belt.get_output_cell())
		if target and target.belt_item == null:
			moves[belt] = target
	for from_belt in moves:
		var to_belt: Belt = moves[from_belt]
		to_belt.belt_item = from_belt.belt_item
		from_belt.belt_item = null

func _try_push_to_facilities() -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		var target := GridManager.get_cell_occupant(belt.get_output_cell())
		if target is BaseFacility:
			target.receive_item(belt.belt_item.item)
			belt.belt_item = null
