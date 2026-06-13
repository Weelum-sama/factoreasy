extends PanelContainer
class_name PurchasableButton

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

func setup_base(texture: Texture2D, display_name: String) -> void:
	if texture:
		icon.texture = texture
	name_label.text = display_name

func update_affordability(can_afford: bool) -> void:
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.5)

func _on_left_click() -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_left_click()

func format_number(n: float) -> String:
	if n >= 1_000_000_000_000_000:	return "cash overflow"
	if n >= 1_000_000_000_000:	return "%.2fT" % (n / 1_000_000_000_000.0)
	if n >= 1_000_000_000:		return "%.2fB" % (n / 1_000_000_000.0)
	if n >= 1_000_000:			return "%.2fM" % (n / 1_000_000.0)
	if n >= 1_000:				return "%.1fk" % (n / 1_000.0)
	return "%d" % n
