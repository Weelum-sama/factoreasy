extends FacilityData
class_name OreNodeData

@export var item: Item
@export var base_cost: int = 10
var price_increase: float = 1.15

var cost: int = base_cost

func update_purchase_cost() -> void:
	var amount_purchased := GameState.get_total_owned_of_ore(id) + 1
	var new_cost := roundi(base_cost * (price_increase ** amount_purchased))
	cost = new_cost if new_cost > 0 else base_cost
