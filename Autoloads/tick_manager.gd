extends Node

const TICK_RATE: float = 0.5

var _timer: float = 0.0
var _pending_coins: int = 0

signal tick_occurred
signal coins_accumulated(amount: int)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= TICK_RATE:
		_timer -= TICK_RATE
		_run_tick()

func _run_tick() -> void:
	tick_occurred.emit()
	if _pending_coins > 0:
		coins_accumulated.emit(_pending_coins)
		GameState.add_coins(_pending_coins)
		_pending_coins = 0

func add_pending_coins(amount: int) -> void:
	_pending_coins += amount
