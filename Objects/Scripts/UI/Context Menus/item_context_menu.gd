extends ContextMenuBase
class_name ItemContextMenu

@onready var _title_label: Label = %TitleLabel
@onready var _item_icon: TextureRect = %ItemIcon
@onready var _sell_label: Label = %SellLabel

func open(item: Item, screen_pos: Vector2) -> void:
	_title_label.text = item.name
	_item_icon.texture = item.texture
	_sell_label.text = "Sell value: %.1f" % item.sell_value
	visible = true
	_position_clamped(screen_pos)
