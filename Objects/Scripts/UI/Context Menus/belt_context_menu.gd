extends ContextMenuBase
class_name BeltContextMenu

@onready var _state_label: Label = %StateLabel
@onready var _item_icon: TextureRect = %ItemIcon
@onready var _item_label: Label = %ItemLabel
@onready var _progress_label: Label = %ProgressLabel
@onready var item_row: HBoxContainer = %ItemRow

var _belt: Belt = null

func open(belt: Belt, screen_pos: Vector2) -> void:
	_belt = belt
	_refresh()
	visible = true
	_position_clamped(screen_pos)
	if belt.belt_item == null:
		return
	if item_row.gui_input.is_connected(_on_click):
		item_row.gui_input.disconnect(_on_click)
	item_row.gui_input.connect(_on_click.bind(belt.belt_item.item))
	
	item_row.mouse_entered.connect(func() -> void: item_row.modulate = Color(1.15, 1.15, 1.15))
	item_row.mouse_exited.connect(func() -> void: item_row.modulate = Color.WHITE)
	
	_play_open_tween(self)

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

func _on_click(event: InputEvent, item: Item) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var layer := get_parent() as ContextMenuLayer
		if layer:
			layer.open_item(item, get_viewport().get_mouse_position())
