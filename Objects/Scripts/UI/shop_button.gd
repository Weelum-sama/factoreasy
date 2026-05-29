extends PanelContainer
class_name  ShopButton

signal pressed(data: FacilityData)

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel

var data: FacilityData

func setup(ore_data: OreNodeData, cost: int) -> void:
	data = ore_data
	if data.texture:
		icon.texture = data.texture
	name_label.text = data.display_name
	cost_label.text = "x%d" % cost

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(data)
