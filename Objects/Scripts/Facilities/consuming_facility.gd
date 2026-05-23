extends Node2D
class_name ConsumingFacility

@export var facility_data: ConsumingFacilityData

func _ready() -> void:
	if facility_data == null:
		push_error("ConsumingFacility placed with no ConsumingFacilityData: " + name)
		return
	$Sprite2D.texture = facility_data.texture

func consume_item(item: Item) -> void:
	GameState.add_coins(item.sell_value)
