extends State
class_name PlacementState

var context: PlacementContext # Set by PlacementController before enter()
@export var placement_mode: Util.PLACEMENTMODE = Util.PLACEMENTMODE.NONE

func enter() -> void:
	Util.set_current_placement_mode(placement_mode)
