extends Resource
class_name UpgradeData

@export var id: String = ""
@export var texture: Texture2D = null
@export var display_name: String = ""
@export var description: String = ""
@export var upgrade_id: String = ""
@export var upgrade_base_cost: int = 1000
@export var upgrade_cost_multiplier: float = 1.75

var upgrade_cost : int = upgrade_base_cost

func decide_upgrade_cost() -> void:
	var new_cost: int
	var level := GameState.get_upgrade_level(id)
	if level == 1:
		new_cost = upgrade_base_cost
	else:
		new_cost = roundi(upgrade_base_cost * level ** upgrade_cost_multiplier)
	upgrade_cost = new_cost
