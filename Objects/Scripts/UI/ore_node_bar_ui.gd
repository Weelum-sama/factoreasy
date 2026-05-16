extends Control

signal placement_requested(data: OreNodeData)

func _ready() -> void:
	GameState.inventory_changed.connect(_on_inventory_changed)
	_refresh_toolbar()

func _on_inventory_changed(node_id: String) -> void:
	_refresh_toolbar()

func _refresh_toolbar() -> void:
	for child in $PanelContainer/SlotContainer.get_children():
		child.queue_free()
	
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
		placement_requested.emit(data)
	)
	$PanelContainer/SlotContainer.add_child(button)
