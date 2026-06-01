extends Label

var _displayed_value: float = 0.0
var _tween: Tween = null
@export var tween_time: float = 1.0

func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_displayed_value = GameState.get_total_coins()
	text = _format(GameState.get_total_coins())

func _on_coins_changed(new_amount: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_display, _displayed_value, float(new_amount), tween_time)

func _set_display(value: float) -> void:
	_displayed_value = value
	text = _format(int(value))

func _format(amount: int) -> String:
	return ": %d" % amount
