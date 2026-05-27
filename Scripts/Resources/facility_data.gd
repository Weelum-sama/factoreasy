extends Resource
class_name FacilityData

@export var id: String = ""
@export var display_name: String = ""
@export var texture: Texture2D
@export var scene: PackedScene
@export var building_id: String = ""
@export var building_width: int = 1
@export var building_height: int = 1
@export var research_cost: int = 100

@export var input_directions: Array[Vector2i] = [] # Leave empty for all sides
@export var output_directions: Array[Vector2i] = [] # Leave empty for all sides
