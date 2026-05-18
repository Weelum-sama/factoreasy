extends FacilityData
class_name ProducingFacilityData

@export var input_slots: int = 1
@export var output_slots: int = 1

@export var recipes: Array[Recipe] = []

var _active_recipe: int = 0

func set_active_recipe(value: int) -> void:
	_active_recipe = value

func get_active_recipe() -> Recipe:
	if recipes.is_empty():
		return null
	return recipes[_active_recipe]
