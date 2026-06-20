extends Node2D

var belts: Dictionary = {}
@export var base_belt_speed: float = 30.0
var belt_speed: float = base_belt_speed
var _pending_deliveries: Array = []
var _lines: Array = []

signal belt_items_updated
signal moving_belts(belts: Array[Belt])
signal stop_moving_belts

func _ready() -> void:
	GameState.belt_upgrade_purchased.connect(_on_belt_upgrade_purchased)
	_on_belt_upgrade_purchased() # Makes sure belts have the correct speed on load

func _on_belt_upgrade_purchased() -> void:
	belt_speed = calculate_belt_speed()
	update_active_belts_speed()

func update_active_belts_speed() -> void:
	for belt in belts.values():
		belt.update_animation_speed()

func calculate_belt_speed() -> float:
	var level := GameState.get_upgrade_level("belts")
	return level * base_belt_speed

func register_belt(cell: Vector2i, belt: Belt) -> void:
	belts[cell] = belt
	AudioManager.play(AudioManager.SFX.PLACE, Vector2.ZERO, true)
	_rebuild_lines()

func unregister_belt(cell: Vector2i) -> void:
	belts.erase(cell)
	_rebuild_lines()

func _rebuild_lines() -> void:
	_lines.clear()
	var visited: Dictionary = {}
	for cell in belts:
		if visited.has(cell):
			continue
		var start := _find_line_start(cell, visited)
		var line := _build_line(start, visited)
		if not line.is_empty():
			_lines.append(line)

func _find_line_start(cell: Vector2i, visited: Dictionary) -> Vector2i:
	var current := cell
	var seen: Dictionary = {}
	while true:
		seen[current] = true
		var belt: Belt = belts.get(current)
		if belt == null:
			return current
		var prev := belt.get_input_cell()
		# Stop if prev isn't a belt, was already built or forms a cycle
		if not belts.has(prev) or visited.has(prev) or seen.has(prev):
			return current
		# Stop if prev belt doesn't point toward current
		var prev_belt: Belt = belts[prev]
		if prev_belt.get_output_cell() != current:
			return current
		current = prev
	return current

func _build_line(start: Vector2i, visited: Dictionary) -> Array:
	var line: Array[Vector2i] = []
	var current := start
	while belts.has(current) and not visited.has(current):
		line.append(current)
		visited[current] = true
		var belt: Belt = belts[current]
		var next := belt.get_output_cell()
		# Only extend the line if the next belt accepts input from us
		var next_belt: Belt = belts.get(next)
		if next_belt == null or next_belt.get_input_cell() != current:
			break
		current = next
	return line

func _process(delta: float) -> void:
	_advance_progress(delta)
	
	for line in _lines:
		_process_line(line)
	
	_advance_delieveries(delta)
	belt_items_updated.emit()

func _advance_progress(delta: float) -> void:
	for cell in belts:
		var belt: Belt = belts[cell]
		if belt.belt_item == null:
			continue
		belt.belt_item.progress = minf(
			belt.belt_item.progress + delta * belt.get_items_per_second(), 1.0
		)

func _process_line(line: Array) -> void:
	if line.is_empty():
		return
	
	for i in range(line.size() - 1, -1, -1):
		var cell: Vector2i = line[i]
		var belt: Belt = belts.get(cell)
		if belt == null:
			continue
		
		if belt.belt_item == null or belt.belt_item.progress < 1.0:
			belt.set_belt_state(Util.BELTSTATE.WORKING)
			continue
		
		var output_cell := belt.get_output_cell()
		
		# Try to push into a facility
		var occupant := GridManager.get_cell_occupant(output_cell)
		if occupant is BaseFacility:
			var facility := occupant as BaseFacility
			if facility.get_valid_input_cells().has(cell) and facility.can_receive_item(belt.belt_item.item):
				_pending_deliveries.append({
					"from_cell": cell,
					"to_cell": output_cell,
					"item": belt.belt_item.item,
					"progress": 0.0,
					"facility": facility
				})
				belt.belt_item = null
				belt.set_belt_state(Util.BELTSTATE.WORKING)
				continue
		
		# Try to move to the next belt in line - supports automatic splitting
		var destinations := _get_output_destinations(belt, cell)
		if destinations.is_empty():
			belt.set_belt_state(Util.BELTSTATE.CLOGGED)
			continue
		
		var moved := false
		for j in destinations.size():
			var try_cell := destinations[(belt._split_index + j) % destinations.size()]
			var try_belt: Belt = belts.get(try_cell)
			if try_belt != null and try_belt.belt_item == null:
				try_belt.belt_item = belt.belt_item
				try_belt.belt_item.previous_cell = cell
				try_belt.belt_item.current_cell = try_cell
				try_belt.belt_item.progress = 0.0
				belt.belt_item = null
				belt._split_index = (belt._split_index + 1) % destinations.size()
				belt.set_belt_state(Util.BELTSTATE.WORKING)
				moved = true
				break
		
		if not moved:
			belt.set_belt_state(Util.BELTSTATE.CLOGGED)
	
	# Try to pull from source facility into the first belt
	var first_cell: Vector2i = line[0]
	var first_belt: Belt = belts.get(first_cell)
	if first_belt != null and first_belt.belt_item == null:
		var input_cell := first_belt.get_input_cell()
		var source := GridManager.get_cell_occupant(input_cell)
		if source is BaseFacility:
			var facility := source as BaseFacility
			if facility.get_valid_output_cells().has(first_cell):
				var item: Item = facility.peek_output()
				if item:
					facility.take_item(item)
					var belt_item := BeltItem.new()
					belt_item.item = item
					belt_item.previous_cell = input_cell
					belt_item.current_cell = first_cell
					belt_item.progress = 0.0
					first_belt.belt_item = belt_item

func _advance_delieveries(delta: float) -> void:
	var completed: Array = []
	for delivery in _pending_deliveries:
		delivery.progress = minf(
			delivery.progress + delta * _get_belt_speed_for_cell(delivery.from_cell), 1.0
		)
		if delivery.progress >= 1.0 and is_instance_valid(delivery.facility):
			if delivery.facility.receive_item(delivery.item):
				completed.append(delivery)
	
	for delivered in completed:
		_pending_deliveries.erase(delivered)

func _get_belt_speed_for_cell(cell: Vector2i) -> float:
	var belt: Belt = belts.get(cell)
	return belt.get_items_per_second() if belt else 1.0

func cancel_deliveries_to(placeable: Placeable) -> void:
	_pending_deliveries = _pending_deliveries.filter(
		func(d): return d.facility != placeable
	)

func update_delivery_cells(old_cell: Vector2i, delta: Vector2i) -> void:
	for delivery in _pending_deliveries:
		if delivery.from_cell == old_cell or delivery.to_cell == old_cell:
			delivery.from_cell += delta
			delivery.to_cell += delta

func get_current_pending_deliveries() -> Array:
	return _pending_deliveries

func _get_output_destinations(belt: Belt, cell: Vector2i) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	
	# Forward direction is first priority
	var forward_cell := belt.get_output_cell()
	var forward_belt: Belt = belts.get(forward_cell)
	if forward_belt != null:
		results.append(forward_cell)
	
	# Check whether can split
	var offsets := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for offset in offsets:
		var neighbour_cell: Vector2i = cell + offset
		var neighbour: Belt = belts.get(neighbour_cell)
		if neighbour != null and neighbour.get_input_cell() == cell:
			results.append(neighbour_cell)
	return results
