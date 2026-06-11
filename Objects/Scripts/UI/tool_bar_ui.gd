extends Control

signal placement_requested(data: FacilityData)

const FACILITY_BUTTON = preload("res://Objects/Scenes/UI/facility_button.tscn")

func _ready() -> void:
	GameState.building_unlocked.connect(_on_building_unlocked)
	_refresh_toolbar()

func _on_building_unlocked(building_id: String) -> void:
	_refresh_toolbar()

func _refresh_toolbar() -> void:
	for child in $PanelContainer/SlotContainer.get_children():
		child.queue_free()
	
	for building_id in GameState.BUILDING_ORDER:
		if not GameState.unlocked_buildings[building_id]:
			continue
		var data: FacilityData = _load_facility_data(building_id)
		if data:
			_add_slot(data)

func _load_facility_data(building_id: String) -> FacilityData:
	var path := "res://Scripts/Resources/Facility Data/%s_data.tres" % building_id
	if ResourceLoader.exists(path):
		return load(path)
	else:
		path = "res://Scripts/Resources/Consuming Facility Data/%s_data.tres" % building_id
		if ResourceLoader.exists(path):
			return load(path)
	push_warning("No Data found at: " + path)
	return null

func _add_slot(data: FacilityData) -> void:
	var button: FacilityButton = FACILITY_BUTTON.instantiate()
	$PanelContainer/SlotContainer.add_child(button)
	button.setup(data)
	button.pressed.connect(func(_d):
		placement_requested.emit(data)
	)
