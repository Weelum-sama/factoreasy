extends Control

@onready var label: Label = %Label

func _ready() -> void:
	Util.placement_mode_changed.connect(_on_placement_mode_changed)
	label.text = _get_string_for_placement_mode(Util._current_placement_mode)

func _on_placement_mode_changed(new_mode: Util.PLACEMENTMODE) -> void:
	label.text = _get_string_for_placement_mode(new_mode)

func _get_string_for_placement_mode(mode: Util.PLACEMENTMODE) -> String:
	match mode:
		Util.PLACEMENTMODE.FACILITY:
			return "PLACEMENT"
		Util.PLACEMENTMODE.ORE_NODE:
			return "PLACEMENT"
		Util.PLACEMENTMODE.SELECTION:
			return "SELECTION"
		Util.PLACEMENTMODE.GROUP_MOVE:
			return "GROUP MOVE"
		Util.PLACEMENTMODE.BELT:
			return "BELT"
	return "REGULAR"
