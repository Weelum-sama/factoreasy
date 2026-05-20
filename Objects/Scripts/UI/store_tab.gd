extends VBoxContainer


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.node_unlocked.connect(_on_node_unlocked)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	for node_id in GameState.unlocked_nodes:
		if not GameState.unlocked_nodes[node_id]:
			continue
		var path := "res://Scripts/Resources/Node Data/%s_data.tres" % node_id
		if ResourceLoader.exists(path):
			_add_entry(load(path))

func _add_entry(data: OreNodeData) -> void:
	var row := HBoxContainer.new()
	var icon := TextureRect.new()
	if data.texture:
		icon.texture = data.texture
		icon.custom_minimum_size = Vector2(32, 32)
	var label := Label.new()
	label.text = "%s\n%d coins" % [data.display_name, data.cost]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var button := Button.new()
	button.text = "buy"
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func():
		if GameState.get_total_coins() >= data.cost:
			GameState.add_coins(-data.cost)
			GameState.add_node_to_inventory(data.id)
			)
	row.add_child(icon)
	row.add_child(label)
	row.add_child(button)
	add_child(row)

func _on_coins_changed(new_amount: float) -> void:
	_refresh()

func _on_node_unlocked(_id: String) -> void:
	_refresh()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Test"):
		GameState.add_coins(100)
