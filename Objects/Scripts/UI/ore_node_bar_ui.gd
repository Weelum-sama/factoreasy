extends Control

signal placement_requested(data: OreNodeData)

var _slots: Dictionary = {}

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
	
	for node_id in GameState.unlocked_nodes:
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
	var button := TextureButton.new()
	button.custom_minimum_size = Vector2(48, 48)
	button.texture_normal = data.texture
	button.tooltip_text = data.display_name
	button.pressed.connect(func():
		if GameState.has_node_in_inventory(data.id):
			placement_requested.emit(data)
	)
	$PanelContainer/SlotContainer.add_child(button)
	_slots[data.id] = button

func _update_slot_label(node_id: String, new_count: int) -> void:
	var button: TextureButton = _slots.get(node_id)
	if button:
		var data: OreNodeData = _load_node_data(node_id)
		if data:
			button.tooltip_text = "%s\nx%d" % [data.display_name, new_count]
