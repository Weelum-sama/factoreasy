extends Resource
class_name Item

@export var name: String
@export var texture: Texture2D
@export var sell_value: float

func _to_string() -> String:
	return name
