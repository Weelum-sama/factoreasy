extends PanelContainer
class_name OreButton

signal pressed(data: OreNodeData)

@onready var icon: TextureRect = %Icon
@onready var count_label: Label = %CountLabel
@onready var name_label: Label = %NameLabel

var data: OreNodeData

func setup(ore_data: OreNodeData, count: int) -> void:
	data = ore_data
	if data.texture:
		icon.texture = data.texture
	name_label.text = data.display_name
	update_count(count)

func update_count(count: int) -> void:
	count_label.text = "x%d" % count

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(data)
