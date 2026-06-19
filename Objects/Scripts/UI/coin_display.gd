extends Label

var _displayed_value: float = 0.0
var _tween: Tween = null
@export var tween_time: float = 1.0

func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_displayed_value = GameState.get_total_coins()
	text = format_number(GameState.get_total_coins())

func _on_coins_changed(new_amount: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_method(_set_display, _displayed_value, float(new_amount), tween_time)

func _set_display(value: float) -> void:
	_displayed_value = value
	text = format_number(int(value))

func format_number(n: float) -> String:
	if n >= 1_000_000_000_000_000:	return "cash overflow"
	if n >= 1_000_000_000_000:	return "%.2fT" % (n / 1_000_000_000_000.0)
	if n >= 1_000_000_000:		return "%.2fB" % (n / 1_000_000_000.0)
	if n >= 1_000_000:			return "%.2fM" % (n / 1_000_000.0)
	if n >= 1_000:				return "%.1fk" % (n / 1_000.0)
	return "%d" % n
