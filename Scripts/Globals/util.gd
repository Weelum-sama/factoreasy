extends Node

enum RESOURCE_TYPES {IRON_ORE, IRON_INGOT}
enum DIRECTION {UP, RIGHT, DOWN, LEFT}

## Placement mode
enum PLACEMENTMODE { NONE, SELECTION, FACILITY, ORE_NODE, GROUP_MOVE }
var _current_placement_mode: PLACEMENTMODE

signal placement_mode_changed(new_mode: PLACEMENTMODE)

func set_current_placement_mode(mode: PLACEMENTMODE) -> void:
	_current_placement_mode = mode
	placement_mode_changed.emit(mode)

func get_current_placement_mode() -> PLACEMENTMODE:
	return _current_placement_mode
