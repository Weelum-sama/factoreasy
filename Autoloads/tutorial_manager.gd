extends Node

signal step_changed(tutorial: TUTORIALS, new_step: int)

enum TUTORIALS {
	BEGINNER_TUTORIAL
}

### BEGINNER TUTORIAL

signal beginner_tutorial_complete

enum BEGINNER_TUTORIAL {
	BUY_NODE,
	PLACE_NODE,
	ATTACH_EXTRACTOR,
	PLACE_BELT,
	FEED_SINK,
	DONE
}

var tutorial_current_step: BEGINNER_TUTORIAL = BEGINNER_TUTORIAL.BUY_NODE

func _ready() -> void:
	if tutorial_current_step != BEGINNER_TUTORIAL.DONE:
		init_beginner_tutorial()

func init_beginner_tutorial() -> void:
	GameState.node_purchased.connect(_on_node_purchased)
	GameState.inventory_changed.connect(_on_inventory_changed)
	GameState.coins_changed.connect(_on_coins_changed)

func _on_node_purchased(node_id: String, _amount: int) -> void:
	if tutorial_current_step != BEGINNER_TUTORIAL.BUY_NODE:
		return
	if node_id == "iron_ore_node":
		_advance(TUTORIALS.BEGINNER_TUTORIAL)

func _on_inventory_changed(resource_id: String, new_count: int) -> void:
	if tutorial_current_step != BEGINNER_TUTORIAL.PLACE_NODE:
		return
	if resource_id == "iron_ore_node" and new_count == 0:
		_advance(TUTORIALS.BEGINNER_TUTORIAL)

func notify_facility_placed(facility: Placeable) -> void:
	if tutorial_current_step == BEGINNER_TUTORIAL.ATTACH_EXTRACTOR and facility is Extractor:
		var cell := GridManager.world_to_cell(facility.global_position)
		var behind := cell + Util.get_behind_offset(facility.rotation)
		if GridManager.get_cell_occupant(behind) is OreNode:
			_advance(TUTORIALS.BEGINNER_TUTORIAL)

func notify_belt_placed(belt: Placeable) -> void:
	if tutorial_current_step != BEGINNER_TUTORIAL.PLACE_BELT:
		return
	var belt_cell := GridManager.world_to_cell(belt.global_position)
	
	for facility in get_tree().get_nodes_in_group("facilities"):
		if facility is Extractor:
			var extractor_cell := GridManager.world_to_cell(facility.global_position)
			var front := extractor_cell + Util.get_facing_offset(facility.rotation)
			if front == belt_cell:
				_advance(TUTORIALS.BEGINNER_TUTORIAL)

func _on_coins_changed(_new_amount: float) -> void:
	if tutorial_current_step == BEGINNER_TUTORIAL.FEED_SINK:
		_advance(TUTORIALS.BEGINNER_TUTORIAL)

### future tutorials pending



### Helpers

func _advance(tutorial: TUTORIALS) -> void:
	match tutorial:
		TUTORIALS.BEGINNER_TUTORIAL:
			tutorial_current_step += 1
			step_changed.emit(TUTORIALS.BEGINNER_TUTORIAL, tutorial_current_step)
			if tutorial_current_step == BEGINNER_TUTORIAL.DONE:
				beginner_tutorial_complete.emit()
