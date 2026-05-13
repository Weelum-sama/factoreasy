extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var rect: Rect2

func get_global_rect():
	return Rect2(
		sprite_2d.global_position - sprite_2d.get_rect().size / 2, sprite_2d.get_rect().size
	)

func place_facility():
	sprite_2d.modulate.a = 1
