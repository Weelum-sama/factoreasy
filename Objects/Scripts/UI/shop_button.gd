extends PurchasableButton
class_name ShopButton

signal pressed(data: FacilityData)

@onready var cost_label: Label = %CostLabel
@onready var owned_label: Label = %OwnedLabel

var data: FacilityData

func setup(ore_data: OreNodeData, cost: int, owned: int) -> void:
	data = ore_data
	setup_base(data.texture, data.display_name)
	update_label_cost(cost)
	update_label_owned(owned)

func update_label_cost(cost: int) -> void:
	cost_label.text = "x%d" % cost

func update_label_owned(owned: int) -> void:
	owned_label.text = "owned: %d" % owned

func _on_left_click() -> void:
	pressed.emit(data)
