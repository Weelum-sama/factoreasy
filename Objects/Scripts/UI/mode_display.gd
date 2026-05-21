extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	Util.placement_mode_changed.connect(_on_placement_mode_changed)
	rich_text_label.text = _get_string_for_placement_mode(Util._current_placement_mode)

func _on_placement_mode_changed(new_mode: Util.PLACEMENTMODE) -> void:
	rich_text_label.text = _get_string_for_placement_mode(new_mode)

func _get_string_for_placement_mode(mode: Util.PLACEMENTMODE) -> String:
	match mode:
		Util.PLACEMENTMODE.FACILITY:
			return "placement mode"
		Util.PLACEMENTMODE.ORE_NODE:
			return "placement mode"
		Util.PLACEMENTMODE.SELECTION:
			return "selection mode"
		Util.PLACEMENTMODE.GROUP_MOVE:
			return "group move mode"
	return "regular mode"
