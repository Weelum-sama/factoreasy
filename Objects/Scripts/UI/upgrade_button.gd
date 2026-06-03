extends PanelContainer
class_name UpgradeButton

signal upgrade_pressed(data: UpgradeData)

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel
@onready var level_label: Label = %LevelLabel

var data: UpgradeData

@export var cost_multiplier: float = 2.25

func setup(upgrade_data: UpgradeData) -> void:
	data = upgrade_data
	if data.texture:
		icon.texture = data.texture
	name_label.text = data.display_name
	description_label.text = data.description
	_refresh_labels()

func _refresh_labels() -> void:
	var level := GameState.get_upgrade_level(data.upgrade_id)
	var cost: int = data.get_cost(level)
	cost_label.text = "%d" % cost
	level_label.text = "lvl %d" % level

func update_affordability(can_afford: bool) -> void:
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.5)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		upgrade_pressed.emit(data)
