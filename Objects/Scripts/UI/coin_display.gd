extends Label

func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(GameState.get_total_coins())

func _on_coins_changed(new_amount: int) -> void:
	text = "Coins: %d" % new_amount
