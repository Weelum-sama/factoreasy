extends Node
class_name State

signal transitioned(from_state: State, new_state: State)

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	pass
