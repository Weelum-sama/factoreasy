extends Control
class_name ItemContextMenu

@onready var item_icon: TextureRect = %ItemIcon
@onready var value_label: Label = %ValueLabel
@onready var name_label: Label = %NameLabel

func setup(item: Item) -> void:
	if is_instance_valid(item):
		item_icon.texture = item.texture
		name_label.text = item.name
		value_label.text = str(item.sell_value)
