extends PurchasableButton
class_name UpgradeButton

@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel
@onready var level_label: Label = %LevelLabel

func setup(upgrade_data: UpgradeData) -> void:
	data = upgrade_data
	setup_base(data.texture, data.display_name)
	description_label.text = data.description
	_refresh_labels()

func _refresh_labels() -> void:
	var level := GameState.get_upgrade_level(data.upgrade_id)
	var cost: int = data.get_cost()
	cost_label.text = Util.format_number(float(cost))
	if data.upgrade_id == "belts":
		level_label.text = "speed: %d" % (level * 30)
	else:
		level_label.text = "lvl %d" % level
