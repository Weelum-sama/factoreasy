extends Node

enum RESOURCE_TYPES {IRON_ORE, IRON_INGOT}
enum DIRECTION {UP, RIGHT, DOWN, LEFT}


enum PLACEMENTMODE { NONE, SELECTION, FACILITY, ORE_NODE, GROUP_MOVE, BELT }
var _current_placement_mode: PLACEMENTMODE

signal placement_mode_changed(new_mode: PLACEMENTMODE)

### Helpers

## Placement mode management

func set_current_placement_mode(mode: PLACEMENTMODE) -> void:
	_current_placement_mode = mode
	placement_mode_changed.emit(mode)

func get_current_placement_mode() -> PLACEMENTMODE:
	return _current_placement_mode

## Cell detection

func get_facing_offset(rotation: float) -> Vector2i:
	var angle := fmod(rotation - PI / 2 + TAU, TAU)
	if angle < PI / 4 or angle >= 7 * PI / 4:
		return Vector2i(1, 0)
	elif angle < 3 * PI / 4:
		return Vector2i(0, 1)
	elif angle < 5 * PI / 4:
		return Vector2i(-1, 0)
	else:
		return Vector2i(0, -1)

func get_behind_offset(rotation: float) -> Vector2i:
	var facing := get_facing_offset(rotation)
	return Vector2i(-facing.x, -facing.y)

func rotate_offset(offset: Vector2i, angle: float) -> Vector2i:
	var steps := (roundi(angle / (PI / 2.0)) % 4 + 4) % 4
	var result := offset
	for i in steps:
		result = Vector2i(-result.y, result.x)
	return result
