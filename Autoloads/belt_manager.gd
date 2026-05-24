extends Node2D

var belts: Dictionary = {}

signal belt_items_updated

func _ready() -> void:
	TickManager.tick_occurred.connect(_economy_tick)

func register_belt(cell: Vector2i, belt: Belt) -> void:
	belts[cell] = belt

func unregister_belt(cell: Vector2i) -> void:
	belts.erase(cell)

func _economy_tick() -> void:
	_try_pull_from_facilities()

func _try_pull_from_facilities() -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if not is_instance_valid(belt):
			continue
		if belt.belt_item != null:
			continue
		var input_cell := belt.get_input_cell()
		var source := GridManager.get_cell_occupant(input_cell)
		if source is BaseFacility:
			var item : Item = source.peek_output()
			if item:
				source.take_item(item)
				var belt_item : BeltItem = BeltItem.new()
				belt_item.item = item
				belt_item.previous_cell = input_cell
				belt_item.current_cell = cell
				belt_item.progress = 0.0
				belt.belt_item = belt_item

func _move_items() -> void:
	var moves: Dictionary = {}
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		if belt.belt_item.progress < 1.0:
			continue
		var target: Belt = belts.get(belt.get_output_cell())
		if target and target.belt_item == null:
			moves[belt] = target
	
	var destinations := moves.values()
	
	for from_belt in moves:
		if from_belt in destinations:
			continue
		var to_belt: Belt = moves[from_belt]
		from_belt.belt_item.previous_cell = GridManager.world_to_cell(from_belt.global_position)
		from_belt.belt_item.current_cell = GridManager.world_to_cell(to_belt.global_position)
		from_belt.belt_item.progress = 0.0
		to_belt.belt_item = from_belt.belt_item
		from_belt.belt_item = null

func _try_push_to_facilities() -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		if belt.belt_item.progress < 1.0:
			continue
		var target := GridManager.get_cell_occupant(belt.get_output_cell())
		if target is BaseFacility:
			target.receive_item(belt.belt_item.item)
			belt.belt_item = null
		continue

func _process(delta: float) -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		belt.belt_item.progress = min(
			belt.belt_item.progress + delta * belt.get_items_per_second(),
			 1.0
		)
	
	_move_items()
	_try_push_to_facilities()
	belt_items_updated.emit()
