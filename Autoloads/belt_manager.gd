extends Node2D

var belts: Dictionary = {}
var _pending_deliveries: Array = []

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
		var output_cell := belt.get_output_cell()
		var target := GridManager.get_cell_occupant(output_cell)
		if target is BaseFacility:
			_pending_deliveries.append({
				"from_cell": cell,
				"to_cell": output_cell,
				"item": belt.belt_item.item,
				"progress": 0.0,
				"facility": target
			})
			belt.belt_item = null
		continue

func _get_belt_speed_for_cell(cell: Vector2i) -> float:
	var belt: Belt = belts.get(cell)
	if belt:
		return belt.get_items_per_second()
	return 1.0

func cancel_deliveries_to(facility: BaseFacility) -> void:
	_pending_deliveries = _pending_deliveries.filter(
		func(d): return d.facility != facility
	)

func _process(delta: float) -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		belt.belt_item.progress = min(
			belt.belt_item.progress + delta * belt.get_items_per_second(),
			 1.0
		)
	
	var completed := []
	for delivery in _pending_deliveries:
		delivery.progress = min(delivery.progress + delta * _get_belt_speed_for_cell(delivery.from_cell), 1.0)
		if delivery.progress >= 1.0:
			if is_instance_valid(delivery.facility):
				delivery.facility.receive_item(delivery.item)
			completed.append(delivery)
	for delivery in completed:
		_pending_deliveries.erase(delivery)
	
	_move_items()
	_try_push_to_facilities()
	belt_items_updated.emit()
