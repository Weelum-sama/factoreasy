extends ContextMenuBase
class_name BeltContextMenu

@onready var _state_label: Label = %StateLabel
@onready var _item_icon: TextureRect = %ItemIcon
@onready var _item_label: Label = %ItemLabel
@onready var _progress_label: Label = %ProgressLabel

var _belt: Belt = null

func open(belt: Belt, screen_pos: Vector2) -> void:
	_belt = belt
	_refresh()
	visible = true
	_position_clamped(screen_pos)

func _process(_delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(_belt):
		visible = false
		return
	_refresh()

func _refresh() -> void:
	_state_label.text = "state: %s" % (
		"clogged" if _belt.belt_state == Util.BELTSTATE.CLOGGED else "working"
	)
	var belt_item := _belt.belt_item
	if belt_item == null or belt_item.item == null:
		_item_icon.texture = null
		_item_label.text = "empty"
		_progress_label.text = ""
	else:
		_item_icon.texture = belt_item.item.texture
		_item_label.text = belt_item.item.name
		_progress_label.text = "progress: %d%%" % int(belt_item.progress * 100.0)
