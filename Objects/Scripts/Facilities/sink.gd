extends BaseFacility
class_name Sink

func tick() -> void:
	_try_sell()

func _try_sell() -> void:
	for item in input_buffer.keys():
		var amount: int = input_buffer[item]
		if amount <= 0:
			continue
		TickManager.add_pending_coins(item.sell_value * amount)
		input_buffer[item] = 0
