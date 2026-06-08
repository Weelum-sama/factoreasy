extends PanelContainer
class_name ResearchButton

signal research_pressed(data: FacilityData)

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel

@onready var h_box_container_locked: HBoxContainer = %HBoxContainerLocked
@onready var h_box_container_unlocked: HBoxContainer = %HBoxContainerUnlocked

var data: FacilityData

func setup(facility_data: FacilityData, is_unlocked: bool) -> void:
	data = facility_data
	if data.texture:
		icon.texture = data.texture
	name_label.text = data.display_name
	cost_label.text = str(data.research_cost)
	update_affordability(GameState.get_total_coins() >= data.research_cost)
	set_unlocked(is_unlocked)

func set_unlocked(is_unlocked: bool) -> void:
	h_box_container_unlocked.visible = is_unlocked
	h_box_container_locked.visible = !is_unlocked
	if is_unlocked:
		modulate = Color(1, 1, 1, 0.5)

func update_affordability(can_afford: bool) -> void:
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.5)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			research_pressed.emit(data)
