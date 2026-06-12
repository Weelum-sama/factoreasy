extends VBoxContainer

const RESEARCH_BUTTON = preload("res://Objects/Scenes/UI/research_button.tscn")

var _buttons: Dictionary = {}

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.building_unlocked.connect(_on_building_unlocked)
	GameState.research_unlocked.connect(_on_research_unlocked)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()
	for building_id in GameState.BUILDING_ORDER:
		var path := "res://Scripts/Resources/Facility Data/%s_data.tres" % building_id
		if not ResourceLoader.exists(path):
			continue
		if not GameState.unlocked_research[building_id]:
			continue
		var data: FacilityData = load(path)
		_add_entry(data, GameState.unlocked_buildings[building_id])

func _add_entry(data: FacilityData, is_unlocked: bool) -> void:
	var button: ResearchButton = RESEARCH_BUTTON.instantiate()
	add_child(button)
	button.setup(data, is_unlocked)
	button.research_pressed.connect(_on_research_pressed)
	_buttons[data.building_id] = button

func _check_research_unlocks(new_coins: float) -> void:
	for facility_id in GameState.BUILDING_ORDER:
		if GameState.unlocked_research[facility_id]:
			continue
		var data: FacilityData = GameState.facility_registry.get(facility_id)
		if data and new_coins >= data.research_unlock_threshold:
			GameState.unlock_research(facility_id)

func _on_research_pressed(data: FacilityData) -> void:
	if GameState.get_total_coins() >= data.research_cost and not GameState.unlocked_buildings[data.id]:
		GameState.add_coins(-data.research_cost)
		GameState.unlock_building(data.building_id)

func _on_building_unlocked(building_id: String) -> void:
	var button: ResearchButton = _buttons[building_id]
	if button:
		button.set_unlocked(true)

func _on_research_unlocked(_building_id: String) -> void:
	_refresh()

func _on_coins_changed(new_amount: float) -> void:
	_check_research_unlocks(new_amount)
	for building_id in _buttons.keys():
		if not GameState.unlocked_buildings.get(building_id, false):
			var button: ResearchButton = _buttons[building_id]
			var can_afford: bool = new_amount >= button.data.research_cost
			button.update_affordability(can_afford)
