extends Purchaseable
class_name UpgradeData

@export var id: String = ""
@export var texture: Texture2D = null
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var upgrade_id: String = ""

var upgrade_cost : int = base_cost

func decide_upgrade_cost() -> void:
	var new_cost: int
	var level := GameState.get_upgrade_level(id)
	if level == 1:
		new_cost = base_cost
	else:
		new_cost = roundi(base_cost * level ** cost_increase_multiplier)
	upgrade_cost = new_cost

func get_cost() -> int:
	return upgrade_cost
