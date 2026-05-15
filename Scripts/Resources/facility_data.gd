extends Resource
class_name FacilityData

@export var id: String = ""
@export var display_name: String = ""
@export var texture: Texture2D
@export var building_id: String = ""

@export var input_slots: int = 1
@export var output_slots: int = 1

@export var recipes: Array[Recipe] = []

var active_recipe: int = 0

func get_active_recipe() -> Recipe:
	if recipes.is_empty():
		return null
	return recipes[active_recipe]
