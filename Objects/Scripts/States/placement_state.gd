extends State
class_name PlacementState

var context: PlacementContext # Set by PlacementController before enter()
@export var placement_mode: Util.PLACEMENTMODE = Util.PLACEMENTMODE.NONE
var _tween: Tween

func enter() -> void:
	Util.set_current_placement_mode(placement_mode)

func _play_placement_tween(buildings: Array[Placeable]) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	for building in buildings:
		_tween.tween_property(building, "scale", Vector2(0.0, 0.0), .01)
		_tween.tween_property(building, "scale", Vector2(1.1, 1.1), .05)
		_tween.tween_property(building, "scale", Vector2(1.0, 1.0), .05)
		

func _play_pick_up_tween(building: Node2D) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(building, "scale", Vector2(1.1, 1.1), .05)

func _play_put_down_tween(building: Node2D) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(building, "scale", Vector2(1.0, 1.0), .05).from(Vector2(1.1, 1.1))
