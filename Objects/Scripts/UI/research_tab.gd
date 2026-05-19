extends VBoxContainer


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	for building_id in GameState.unlocked_buildings:
		var path := "res://Scripts/Resources/Facility Data/%s_data.tres" % building_id
		if not ResourceLoader.exists(path):
			continue
		var data: FacilityData = load(path)
		_add_entry(data, GameState.unlocked_buildings[building_id])

func _add_entry(data: FacilityData, is_unlocked: bool) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_unlocked:
		label.text = "%s\n Unlocked" % data.display_name
	else:
		label.text = "%s\n%d coins" % [data.display_name, data.research_cost]
	var button = Button.new()
	button.text = "Research" if not is_unlocked else ""
	button.visible = not is_unlocked
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func():
		if GameState.get_total_coins() >= data.research_cost:
			GameState.add_coins(-data.research_cost)
			GameState.unlock_building(data.building_id)
			_refresh()
			)
	row.add_child(label)
	row.add_child(button)
	add_child(row)

func _on_coins_changed(new_amount: float) -> void:
	_refresh()
