extends RefCounted
class_name PlacementContext

# Ghost
var ghost: Sprite2D = null
var ghost_parent: Node2D
var pending_rotation: float = 0.0

# Pending placement
var pending_data: FacilityData = null
var facility_scene: PackedScene = null
var consuming_facility_scene: PackedScene = null
const ORE_NODE_SCENE = preload("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
var ore_node_scene: PackedScene = null

# Selection
var selected_buildings: Array[Node] = []
var selection_box_start: Vector2 = Vector2.ZERO
var selection_box_active: bool = false

# Group move
var entered_from_selection: bool = false
var is_copy_mode: bool = false
var missing_ore_nodes: Dictionary = {}
var group_move_offsets: Array[Vector2i] = []

# Hold to pickup
var hold_timer: float = 0.0
var hold_candidate: Node = null
const HOLD_DURATION: float = 0.3
var pickup_building: Node = null

# Helpers
func get_building_from_mouse() -> Node:
	var cell := GridManager.world_to_cell(ghost_parent.get_global_mouse_position())
	return GridManager.get_cell_occupant(cell)

func create_ghost(data: FacilityData) -> void:
	destroy_ghost()
	ghost = Sprite2D.new()
	ghost.rotation = pending_rotation
	ghost.visible = false
	if data.texture:
		ghost.texture = data.preview_texture
	ghost_parent.add_child(ghost)

func destroy_ghost() -> void:
	if ghost:
		ghost.queue_free()
		ghost = null

func clear_selection() -> void:
	for building in selected_buildings:
		building.modulate = Color.WHITE
	selected_buildings.clear()

func rotate_offset_90(offset: Vector2i) -> Vector2i:
	return Vector2i(-offset.y, offset.x)
