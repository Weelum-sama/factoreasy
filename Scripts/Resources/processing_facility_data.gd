extends FacilityData
class_name ProcessingFacilityData

@export var recipes: Array[Recipe] = []

func is_valid_input(item: Item) -> bool:
	if recipes.is_empty():
		return false
	for ingredient in recipes[0].input:
		if ingredient.item == item:
			return true
	return false
