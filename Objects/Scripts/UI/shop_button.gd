extends PanelContainer
class_name ShopButton

signal pressed(data: FacilityData)

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel
@onready var owned_label: Label = %OwnedLabel

var data: FacilityData

func setup(ore_data: OreNodeData, cost: int, owned: int) -> void:
	data = ore_data
	if data.texture:
		icon.texture = data.texture
	name_label.text = data.display_name
	update_label_cost(ore_data.cost)
	update_label_owned(owned)

func update_label_cost(cost: int) -> void:
	cost_label.text = "x%d" % cost

func update_affordability(can_afford: bool) -> void:
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.5)

func update_label_owned(owned: int) -> void:
	owned_label.text = "owned: %d" % owned

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(data)
