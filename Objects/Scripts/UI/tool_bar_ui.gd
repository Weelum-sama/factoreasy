extends Control

signal placement_requested(data: FacilityData)

func _ready() -> void:
	GameState.building_unlocked.connect(_on_building_unlocked)
	_refresh_toolbar()

func _on_building_unlocked(building_id: String) -> void:
	_refresh_toolbar()

func _refresh_toolbar() -> void:
	for child in %SlotContainer.get_children():
		child.queue_free()
	
	for building_id in GameState.unlocked_buildings:
		if not GameState.unlocked_buildings[building_id]:
			continue
		var data: FacilityData = _load_facility_data(building_id)
		if data:
			_add_slot(data)

func _load_facility_data(building_id: String) -> FacilityData:
	var path := "res://Scripts/Resources/Facility Data/%s_data.tres" % building_id
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("No FacilityData found at: " + path)
	return null

func _add_slot(data: FacilityData) -> void:
	var button := TextureButton.new()
	button.texture_normal = data.texture
	button.tooltip_text = data.display_name
	button.pressed.connect(func():
		placement_requested.emit(data)
	)
	%SlotContainer.add_child(button)
