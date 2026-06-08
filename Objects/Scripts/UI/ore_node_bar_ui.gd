extends Control

signal placement_requested(data: OreNodeData)

var _slots: Dictionary = {}

const ORE_BUTTON = preload("res://Objects/Scenes/UI/ore_button.tscn")

func _ready() -> void:
	GameState.node_unlocked.connect(_on_node_unlocked)
	GameState.inventory_changed.connect(_on_inventory_changed)
	_refresh_toolbar()

func _on_node_unlocked(node_id: String) -> void:
	_refresh_toolbar()

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	if _slots.has(resource_id):
		_update_slot_label(resource_id, new_count)

func _refresh_toolbar() -> void:
	for child in $PanelContainer/SlotContainer.get_children():
		child.queue_free()
	_slots.clear()
	
	for node_id in GameState.NODE_ORDER:
		if not GameState.unlocked_nodes[node_id]:
			continue
		var data: OreNodeData = _load_node_data(node_id)
		if data:
			_add_slot(data)

func _load_node_data(node_id: String) -> OreNodeData:
	var path := "res://Scripts/Resources/Node Data/%s_data.tres" % node_id
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("No FacilityData found at: " + path)
	return null

func _add_slot(data: OreNodeData) -> void:
	var button: OreButton = ORE_BUTTON.instantiate()
	$PanelContainer/SlotContainer.add_child(button)
	var count: int = GameState.node_inventory.get(data.id, 0)
	button.setup(data, count)
	button.pressed.connect(func(_d):
		if GameState.has_node_in_inventory(data.id):
			placement_requested.emit(data)
	)
	_slots[data.id] = button
	GameState.inventory_changed.emit(data.id, GameState.node_inventory[data.id]) # Makes sure amount of ores in inventory are displayed from the start

func _update_slot_label(node_id: String, new_count: int) -> void:
	var button: OreButton = _slots.get(node_id)
	if button:
		button.update_count(new_count)
		button.modulate = Color(1, 1, 1, 1) if new_count > 0 else Color(1, 1, 1, 0.4)
