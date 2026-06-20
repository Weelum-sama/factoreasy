extends PurchasableButton
class_name ResearchButton

@onready var cost_label: Label = %CostLabel
@onready var h_box_container_locked: HBoxContainer = %HBoxContainerLocked
@onready var h_box_container_unlocked: HBoxContainer = %HBoxContainerUnlocked

func setup(facility_data: FacilityData, is_unlocked: bool) -> void:
	data = facility_data
	setup_base(data.texture, data.display_name)
	cost_label.text = str(data.base_cost)
	update_affordability(GameState.get_total_coins() >= data.base_cost)
	set_unlocked(is_unlocked)

func set_unlocked(is_unlocked: bool) -> void:
	h_box_container_unlocked.visible = is_unlocked
	h_box_container_locked.visible = !is_unlocked
	if is_unlocked:
		modulate = Color(1, 1, 1, 0.5)
