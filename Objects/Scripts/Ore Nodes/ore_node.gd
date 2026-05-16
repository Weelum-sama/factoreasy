extends Node2D
class_name OreNode

@export var data: OreNodeData

func _ready() -> void:
	if data == null:
		push_error("OreNode placed with no OreNodeData: " + name)
		return
	$Sprite2D.texture = data.texture

func extract_item() -> Item:
	return data.item
