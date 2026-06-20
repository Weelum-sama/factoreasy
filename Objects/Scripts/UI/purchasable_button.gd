extends PanelContainer
class_name PurchasableButton

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

var _tween: Tween

var data: Purchaseable

signal pressed(data: Purchaseable)

func setup_base(texture: Texture2D, display_name: String) -> void:
	if texture:
		icon.texture = texture
	name_label.text = display_name
	pivot_offset = Vector2(size.x/2, size.y/2)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_affordability(can_afford: bool) -> void:
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.5)

func _on_left_click() -> void:
	pressed.emit(data)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_left_click()
		_on_mouse_click()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_on_mouse_click_released()

func _on_mouse_entered() -> void:
	if modulate == Color.WHITE:
		reset_tween()
		_tween.tween_property(self, "modulate", Color.GRAY, 0.05)

func _on_mouse_exited() -> void:
	if modulate != Color(1, 1, 1, 0.5):
		reset_tween()
		_tween.tween_property(self, "modulate", Color.WHITE, 0.05)

func _on_mouse_click() -> void:
	reset_tween()
	_tween.tween_property(self, "scale", Vector2(0.98, 0.98), 0.01)

func _on_mouse_click_released() -> void:
	reset_tween()
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.01)

func reset_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
